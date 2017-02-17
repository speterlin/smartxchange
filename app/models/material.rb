# == Schema Information
#
# Table name: materials
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  attachment :string           not null
#  owner_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Material < ApplicationRecord
  validates :name, :attachment, :owner, presence: true
  validates :owner_id, uniqueness: { scope: :name, message: "has already uploaded a document with this name" }
  # validate :attachment_is_unique_to_owner

  belongs_to :owner, class_name: 'User'
  # mount_uploader :attachment, AttachmentUploader

  # def attachment_is_unique_to_owner
  #   if self.attachment.file && Material.where(attachment: self.attachment.file.original_filename, owner_id: self.owner_id).where.not(id: self.id).count > 0
  #      errors.add :owner_id, "has already uploaded an attachment with the name #{self.attachment.file.original_filename}"
  #   end
  # end

end
