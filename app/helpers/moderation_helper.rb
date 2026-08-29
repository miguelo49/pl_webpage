module ModerationHelper
  MODERATABLE_PARAM_TYPES = {
    "ForumThread" => "forum_thread",
    "Comment" => "comment",
    "News" => "news"
  }.freeze

  MODERATABLE_CLASS_BY_PARAM = {
    "forum_thread" => ForumThread,
    "comment" => Comment,
    "news" => News
  }.freeze

  def moderation_item_param_type(record)
    MODERATABLE_PARAM_TYPES.fetch(record.class.name)
  end

  def moderation_item_path_for(record)
    moderation_item_path(
      type: moderation_item_param_type(record),
      id: record.id
    )
  end
end
