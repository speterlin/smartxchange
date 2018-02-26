module Taggable
  extend ActiveSupport::Concern

  # probably refactor
  def content_present_and_changed?
    return true if (self.content.present? && self.content_changed?)
    false
  end

  # refactor, a lot of database calls, maybe add non-owned tags
  def update_owned_tags
    combined_content = combine_content
    update_owned_hashtags(combined_content)
    update_owned_usertags(combined_content)
    # because saving in before_update
    tag_item.save if !self.is_a?(Post)
  end

  # maybe refactor, can probably use recursion, some repeat code, maybe change so you can have periods or other characters in the hashtag
  def update_owned_hashtags(content)
    hashtags = parse_hashtags(content.scan(/#\w+/))
    #   owned_tag_list |= hashtags
    self.owner.tag(tag_item, :with => hashtags.join(","), :on => :tags, :skip_save => true)
  end

  def update_owned_usertags(content)
    usertags = parse_usertags(content.scan(/@[\w+\.?]+/))
    content_usertags = usertags - (usertags - self.content.gsub('@', '').split(" "))
    content_usertags.each do |usertag|
      next if usertag == self.owner.name.downcase.split(" ").join(".")
      post_mention_create_notification(self, tag_item, User.find_by_name(usertag.split(".").join(" ").titleize))
    end
    self.owner.tag(tag_item, :with => usertags.join(","), :on => :users, :skip_save => true)
  end

  def remove_owned_tags
    remove_owned_hashtags
    remove_owned_usertags
    # precautionary, for now only called on comments so should always save
    tag_item.save if !self.is_a?(Post)
  end

  def remove_owned_hashtags
    hashtags = parse_hashtags(self.content.scan(/#\w+/))
    owned_tag_list = tag_item.tags_from(self.owner)
    owned_tag_list -= hashtags
    self.owner.tag(tag_item, :with => owned_tag_list.join(","), :on => :tags, :skip_save => true)
  end

  def remove_owned_usertags
    usertags = parse_usertags(self.content.scan(/@[\w+\.?]+/))
    owned_user_list = tag_item.users_from(self.owner)
    owned_user_list -= usertags
    self.owner.tag(tag_item, :with => owned_user_list.join(","), :on => :users, :skip_save => true)
  end

  # refactor, if else statement to prevent stack loop error in parse_usertags after saving content
  def combine_content
    content = ""
    if self.is_a?(Post)
      content += self.content + " " + self.comments.where(owner: self.owner).pluck(:content).join(" ")
    else # a comment
      content += tag_item.content if tag_item.owner == self.owner
      content += " " + self.content + " " + tag_item.comments.where.not(id: self.id).where(owner: self.owner).pluck(:content).join(" ")
    end
    return content
  end

  def parse_hashtags(hashtags)
    return hashtags.map{|hashtag| hashtag.downcase.delete('#')}.uniq
  end

  # maybe refactor, self.save makes it start the process over again
  def parse_usertags(usertags)
    return usertags.map do |usertag|
      name = usertag.delete('@').split(".").join(" ").downcase.titleize
      if User.find_by_name(name)
        usertag.downcase.delete('@')
      else
        self.content.gsub!(usertag, "")
        self.save
        next
      end
    end.compact.uniq
  end

  # assuming only post or comment, maybe refactor
  def tag_item
    return self.is_a?(Comment) ? self.commentable : self
  end

end
