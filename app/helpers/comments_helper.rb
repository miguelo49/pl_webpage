module CommentsHelper
  def comment_form_url(initiative: nil, topic: nil, thread: nil)
    if initiative
      comments_initiative_path(initiative)
    else
      topic_thread_comments_path(topic, thread)
    end
  end
end
