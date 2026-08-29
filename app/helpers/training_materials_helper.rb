module TrainingMaterialsHelper
  def read_by_current_user?(training_material)
    return false unless user_signed_in?

    training_material.read_marks.any? { |read_mark| read_mark.user_id == current_user.id }
  end
end
