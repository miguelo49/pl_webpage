module Moderation
  class ItemsController < BaseController
    DECISIONS = {
      "approve" => :approved,
      "reject" => :rejected,
      "hide" => :hidden
    }.freeze

    before_action :set_item

    def update
      authorize :moderation, :resolve?

      if reject_without_reason?
        @entry = Queue.entry_for(@item)
        @error_message = "Debes indicar un motivo de rechazo."
        respond_to do |format|
          format.turbo_stream { render :update, status: :unprocessable_entity }
          format.html { redirect_to moderation_root_path, alert: @error_message }
        end
        return
      end

      @item.moderated_by = current_user
      @item.moderation_rejection_reason = params[:rejection_reason]

      if @item.update(status: DECISIONS.fetch(params[:decision]))
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to moderation_root_path, notice: "Contenido moderado." }
        end
      else
        @entry = Queue.entry_for(@item)
        @error_message = @item.errors.full_messages.to_sentence
        respond_to do |format|
          format.turbo_stream { render :update, status: :unprocessable_entity }
          format.html { redirect_to moderation_root_path, alert: @error_message }
        end
      end
    end

    private

    def set_item
      model = ModerationHelper::MODERATABLE_CLASS_BY_PARAM.fetch(params[:type])
      @item = model.find(params[:id])
    end

    def reject_without_reason?
      params[:decision] == "reject" && params[:rejection_reason].to_s.strip.blank?
    end
  end
end
