module ReadMarkHandling
  extend ActiveSupport::Concern

  private

  def toggle_read_mark(training_material)
    read_mark = training_material.read_marks.find_by(user: current_user)

    if read_mark
      read_mark.destroy!
    else
      training_material.read_marks.create!(user: current_user)
    end

    @training_material = training_material.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: training_materials_path) }
    end
  end
end
