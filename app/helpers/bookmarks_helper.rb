module BookmarksHelper
  def bookmark_path_for(bookmarkable, topic: nil)
    case bookmarkable
    when ForumThread
      bookmark_topic_thread_path(topic, bookmarkable)
    when TrainingMaterial
      bookmark_training_material_path(bookmarkable)
    else
      raise ArgumentError, "Unsupported bookmarkable: #{bookmarkable.class.name}"
    end
  end

  def bookmarked_by_current_user?(bookmarkable)
    return false unless user_signed_in?

    bookmarkable.bookmarks.any? { |bookmark| bookmark.user_id == current_user.id }
  end
end
