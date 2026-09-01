class Topic < ApplicationRecord
  NEWS_SLUG = "news"

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  scope :ordered, -> { order(:position, :name) }
  scope :for_forum, -> { where.not(slug: NEWS_SLUG) }

  has_many :threads, class_name: "ForumThread", dependent: :restrict_with_error

  def news_topic?
    slug == NEWS_SLUG
  end

  def system_topic?
    news_topic?
  end

  def self.news_topic
    find_or_create_by!(slug: NEWS_SLUG) do |topic|
      topic.name = "Noticias"
      topic.description = "Discusión asociada a noticias publicadas."
      topic.position = 9
    end
  end
end
