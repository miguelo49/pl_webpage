module BookmarkHandling
  extend ActiveSupport::Concern

  private

  def toggle_bookmark(bookmarkable)
    bookmark = bookmarkable.bookmarks.find_by(user: current_user)

    if bookmark
      bookmark.destroy!
    else
      bookmarkable.bookmarks.create!(user: current_user)
    end

    @bookmarkable = bookmarkable.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: topic_thread_path(@topic, @thread)) }
    end
  end
end
