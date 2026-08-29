module ReactionsHelper
  def react_path_for(reactable, topic: nil, thread: nil)
    case reactable
    when ForumThread
      react_topic_thread_path(topic, reactable)
    when Comment
      react_topic_thread_comment_path(topic, thread, reactable)
    when News
      react_news_path(reactable)
    else
      raise ArgumentError, "Unsupported reactable: #{reactable.class.name}"
    end
  end

  def reacted_by_current_user?(reactable)
    return false unless user_signed_in?

    reactable.reactions.any? { |reaction| reaction.user_id == current_user.id }
  end
end
