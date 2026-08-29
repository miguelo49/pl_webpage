class TrainingMaterial < ApplicationRecord
  ACCEPTED_PDF_TYPE = "application/pdf"

  belongs_to :training_category

  has_one_attached :pdf
  has_one_attached :cover_image

  has_many :read_marks, dependent: :destroy
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true
  validates :date, presence: true
  validates :training_category, presence: true
  validate :acceptable_pdf
  validate :acceptable_cover_image

  scope :by_category, ->(category_id) {
    category_id.present? ? where(training_category_id: category_id) : all
  }

  scope :search_by, ->(query) {
    sanitized_query = query.to_s.strip
    if sanitized_query.blank?
      all
    else
      pattern = "%#{sanitize_sql_like(sanitized_query)}%"
      where("title ILIKE :pattern OR array_to_string(tags, ' ') ILIKE :pattern", pattern: pattern)
    end
  }

  scope :library_order, -> { order(date: :desc, created_at: :desc) }

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
