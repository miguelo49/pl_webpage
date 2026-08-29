class TrainingMaterial < ApplicationRecord
  ACCEPTED_PDF_TYPE = "application/pdf"

  belongs_to :training_category

  has_one_attached :pdf
  has_one_attached :cover_image

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true
  validates :date, presence: true
  validates :training_category, presence: true
  validate :acceptable_pdf
  validate :acceptable_cover_image

  def self.policy_class
    TrainingMaterialPolicy
  end

  private

  def acceptable_pdf
    return unless pdf.attached?

    unless pdf.content_type == ACCEPTED_PDF_TYPE
      errors.add(:pdf, "must be a PDF")
    end
  end

  def acceptable_cover_image
    return unless cover_image.attached?

    unless cover_image.content_type.in?(User::ACCEPTED_AVATAR_TYPES)
      errors.add(:cover_image, "must be a JPEG, PNG, WebP, or GIF")
    end
  end
end
