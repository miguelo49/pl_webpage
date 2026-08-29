module ReactionsHelper
  def react_path_for(reactable, topic: nil, thread: nil, initiative: nil)
    case reactable
    when ForumThread
      react_topic_thread_path(topic, reactable)
    when Comment
      if initiative
        react_initiative_comment_path(initiative, reactable)
      else
        react_topic_thread_comment_path(topic, thread, reactable)
      end
    when News
      react_news_path(reactable)
    when Initiative
      react_initiative_path(reactable)
    else
      raise ArgumentError, "Unsupported reactable: #{reactable.class.name}"
    end
  end

  def reacted_by_current_user?(reactable)
    return false unless user_signed_in?

    reactable.reactions.any? { |reaction| reaction.user_id == current_user.id }
  end
end
