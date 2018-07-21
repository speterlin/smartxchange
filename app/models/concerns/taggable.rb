module Taggable
  extend ActiveSupport::Concern

  def content_present_and_changed?
    return true if (self.content.present? && self.content_changed?)
    false
  end

  def usertags_present?
    return true if self.content.scan(/(?<=\s|^)@[^\s]+/).any?
    false
  end

  # maybe refactor regex so you can have periods or other characters in the hashtag
  def hashtags_present?
    return true if self.content.scan(/(?<=\s|^)#\w+/).any?
    false
  end

  # maybe refactor, a lot of regex and database calls when post/comment doesn't affect hashtags/usertags
  def add_or_update_owned_tags
    owned_content_without_self_content = combine_owned_content_without_self_content
    add_or_update_owned_hashtags(self.content + " " + owned_content_without_self_content)
    add_or_update_owned_usertags(owned_content_without_self_content)
  end

  def add_or_update_owned_hashtags(content)
    owned_hashtags = parse_hashtags(content.scan(/(?<=\s|^)#\w+/))
    # owned_hashtag_list = tag_item.tags_from(self.owner)
    # owned_hashtag_list += content_hashtags # += here automatically calls uniq on resulting array
    self.owner.tag(tag_item, :with => owned_hashtags.join(","), :on => :tags, :skip_save => true)
  end

  def add_or_update_owned_usertags(other_owned_content)
    # precautionary to seperate self_content and other_owned_content, should never have erroneous usertag in already created content and if so, unlikely that it would replace good content in self.content, also case of going through previous usertags and that user is deleted, would try to replace it in self.content to no avail
    self_content_usertags = parse_usertags(self.content.scan(/(?<=\s|^)@[^\s]+/), true)
    other_owned_usertags = parse_usertags(other_owned_content.scan(/(?<=\s|^)@[^\s]+/))
    owned_usertags = (self_content_usertags + other_owned_usertags).uniq # could also |= which adds unique
    self.owner.tag(tag_item, :with => owned_usertags.join(","), :on => :users, :skip_save => true)
  end

  # only called in before_destroy in comment.rb
  def remove_owned_tags
    hashtags_present, usertags_present = hashtags_present?, usertags_present?
    if hashtags_present || usertags_present
      owned_content_without_self_content = combine_owned_content_without_self_content
      remove_owned_hashtags(owned_content_without_self_content) if hashtags_present
      remove_owned_usertags(owned_content_without_self_content) if usertags_present
      # since before_save not called when destroying object
      save_tag_item
    end
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
    # maybe refactor, worried about regex and @ picking up faulty usertags but all strings preceded by whitespace and @ in self.content should be usertags after going through regex and #parse_usertags when this method is called (before_update, after_create)
    content_usertags = self.content.scan(/(?<=\s|^)@[^\s]+/).map{|usertag| usertag.delete('@')}
    # uniq in case user is mentioned more than once in content
    content_usertags.uniq.each do |usertag|
      next if usertag == self.owner.name.downcase.split(" ").join(".")
      post_create_notification(self, tag_item, User.find_by_name(usertag.split(".").join(" ").titleize), true)
    end
  end

  # maybe refactor, need this because tag_item.users/tags stores unique usertags/hashtags, if -= deleted usertag/hashtag from this list and there are still tags for that usertag/hashtag in remaining comments/post, will result in incorrect 0 tags for that usertag/hashtag
  def combine_owned_content_without_self_content
    content = ""
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

  # maybe refactor self_content_only logic, but good that gsub! is only called if self_content_only since this is a computational heavy action
  def parse_usertags(usertags, self_content_only = false)
    return usertags.map do |usertag|
      name = usertag.delete('@').split(".").join(" ").downcase.titleize
      if User.find_by_name(name)
        usertag.downcase.delete('@')
      else
        self.content.gsub!(usertag, "") if self_content_only
        next
      end
    # maybe refactor, compact to get rid of nil values (created if there is an erroneous usertag), uniq here and in parse_hashtags because of #remove_owned_hashtags&usertags call, owned_usertag&hashtag_list in #add_or_update_owned_hashtags&usertags automatically calls uniq (still trying to figure out how)
    end.compact.uniq
  end

  # maybe refactor, assuming tags are only in post or comment and tag_item can only be post
  def tag_item
    @tag_item ||= self.is_a?(Comment) ? self.commentable : self
  end

  def save_tag_item
    # also precautionary - should only be called when self is a comment, because if it is a post, tag_item is self and it will save at end
    tag_item.save unless self == tag_item # could also do if !self.is_a?(Post) but this way we use @tag_item which should be already set
  end

end
