module Taggable
  extend ActiveSupport::Concern

  # probably refactor
  def content_present_and_changed?
    return true if (self.content.present? && self.content_changed?)
    false
  end

  def usertags_present?
    return true if self.content.scan(/(?<=\s|^)@[^\s]+/).any?
    false
  end

  # refactor, a lot of database calls, maybe add non-owned tags
  def add_or_update_owned_tags
    add_or_update_owned_hashtags
    add_or_update_owned_usertags
    # because if it is a post, tag_item is self and it will save at end
    tag_item.save if !self.is_a?(Post)
  end

  # maybe refactor, a lot of database calls with tag_item.tags_from(self.owner), can probably use recursion, some repeat code, maybe change so you can have periods or other characters in the hashtag
  def add_or_update_owned_hashtags
    content_hashtags = parse_hashtags(self.content.scan(/(?<=\s|^)#\w+/))
    owned_hashtag_list = tag_item.tags_from(self.owner)
    # here and owned_usertag_list automatically call uniq when +=
    owned_hashtag_list += content_hashtags
    #   owned_tag_list |= hashtags
    self.owner.tag(tag_item, :with => owned_hashtag_list.join(","), :on => :tags, :skip_save => true)
  end

  def add_or_update_owned_usertags
    content_usertags = parse_usertags(self.content.scan(/(?<=\s|^)@[^\s]+/))
    owned_usertag_list = tag_item.users_from(self.owner)
    owned_usertag_list += content_usertags
    self.owner.tag(tag_item, :with => owned_usertag_list.join(","), :on => :users, :skip_save => true)
  end

  def remove_owned_tags
    combined_owned_content = combine_owned_content_without_self_content
    remove_owned_hashtags(combined_owned_content)
    remove_owned_usertags(combined_owned_content)
    # precautionary, for now only called on comments so should always save
    tag_item.save if !self.is_a?(Post)
  end

  def remove_owned_hashtags(content)
    owned_hashtags = parse_hashtags(content.scan(/(?<=\s|^)#\w+/))
    self.owner.tag(tag_item, :with => owned_hashtags.join(","), :on => :tags, :skip_save => true)
  end

  def remove_owned_usertags(content)
    owned_usertags = parse_usertags(content.scan(/(?<=\s|^)@[^\s]+/))
    self.owner.tag(tag_item, :with => owned_usertags.join(","), :on => :users, :skip_save => true)
  end

  def notify_usertag_mentions
    # maybe refactor, worried about regex and @ picking up faulty usertags but all strings preceded by @ in self.content should be usertags after going through #parse_usertags when this method is called (after_save)
    content_usertags = self.content.scan(/(?<=\s|^)@[^\s]+/).map{|usertag| usertag.delete('@')}
    # uniq in case user is mentioned more than once in content
    content_usertags.uniq.each do |usertag|
      next if usertag == self.owner.name.downcase.split(" ").join(".")
      post_mention_create_notification(self, tag_item, User.find_by_name(usertag.split(".").join(" ").titleize))
    end
  end

  # maybe refactor, only called in #remove_owned_tags which is only called after a comment is deleted, see below
  def combine_owned_content_without_self_content
    content = ""
    # precautionary, only called on comment at the moment, should never go through first if statement
    if self.is_a?(Post)
      content += self.comments.where(owner: self.owner).pluck(:content).join(" ")
    else # a comment
      content += tag_item.content if tag_item.owner == self.owner
      content += " " + tag_item.comments.where.not(id: self.id).where(owner: self.owner).pluck(:content).join(" ")
    end
    return content
  end

  def parse_hashtags(hashtags)
    return hashtags.map{|hashtag| hashtag.downcase.delete('#')}.uniq
  end

  def parse_usertags(usertags)
    return usertags.map do |usertag|
      name = usertag.delete('@').split(".").join(" ").downcase.titleize
      if User.find_by_name(name)
        usertag.downcase.delete('@')
      else
        self.content.gsub!(usertag, "")
        next
      end
    # maybe refactor, compact to get rid of nil values (created if there is an erroneous usertag), uniq here and in parse_hashtags because of #remove_owned_hashtags&usertags call, owned_usertag&hashtag_list in #add_or_update_owned_hashtags&usertags automatically calls uniq (still trying to figure out how)
    end.compact.uniq
  end

  # assuming only post or comment, maybe refactor
  def tag_item
    return self.is_a?(Comment) ? self.commentable : self
  end

end
