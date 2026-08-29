class ForumThread < ApplicationRecord
  include Moderatable

  self.table_name = "threads"

  belongs_to :topic
  belongs_to :user

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2,
    reported: 3,
    hidden: 4
  }, default: :pending

  validates :title, presence: true
  validates :body, presence: true

  before_validation :set_initial_status, on: :create

  scope :publicly_visible, -> { approved }

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reactions, as: :reactable, dependent: :destroy
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy
  has_one :news, inverse_of: :thread, dependent: :nullify

  def self.policy_class
    ThreadPolicy
  end

  def publicly_visible?
    approved?
  end

  private

  def set_initial_status
    self.status = auto_approved_on_create? ? :approved : :pending
  end

  def auto_approved_on_create?
    user.board_member? || user.moderator?
  end
end
