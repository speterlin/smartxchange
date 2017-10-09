# == Schema Information
#
# Table name: materials
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  attachment     :string           not null
#  owner_id       :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language       :string           default("Spanish"), not null
#  language_level :integer          default(3), not null
#

class Material < ApplicationRecord
  mount_uploader :attachment, AttachmentUploader

  validates :name, :attachment, :owner, :language, :language_level, presence: true
  validates :attachment, file_size: { less_than_or_equal_to: 5.megabytes }
  validates :owner_id, uniqueness: { scope: :name, message: "has already uploaded a document with this name" }
  validate :attachment_is_unique_to_owner

  after_commit :reindex_owner

  belongs_to :owner, class_name: 'User'

  protected

  def attachment_is_unique_to_owner
    # maybe refactor, causing an error when update from heroku rails console, can't find original_filename
    if self.attachment.file && Material.where(attachment: self.attachment.file.original_filename, owner_id: self.owner_id).where.not(id: self.id).count > 0
       errors.add :owner_id, "has already uploaded an attachment with the name #{self.attachment.file.original_filename}"
    end
  end

  def reindex_owner
    owner.reindex_async # asynchronously for better speed
  end

end
