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
      format.html { redirect_back(fallback_location: topic_thread_path(@topic, @thread)) }
    end
  end
end
