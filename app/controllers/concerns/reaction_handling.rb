module ReactionHandling
  extend ActiveSupport::Concern

  private

  def toggle_reaction(reactable)
    reaction = reactable.reactions.find_by(user: current_user)

    if reaction
      reaction.destroy!
    else
      reactable.reactions.create!(user: current_user)
    end

    @reactable = reactable.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: reaction_fallback_location(reactable)) }
    end
  end

  def reaction_fallback_location(reactable)
    case reactable
    when News
      news_path(reactable)
    when ForumThread
      topic_thread_path(@topic, reactable)
    when Comment
      topic_thread_path(@topic, @thread)
    else
      root_path
    end
  end
end
