class OnboardingsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_complete, only: [ :show, :update ]
  before_action :load_regions, only: [ :show, :update ]

  def show
    @current_step = current_step
  end

  def update
    case current_step
    when :profile
      handle_profile_step
    when :terms
      handle_terms_step
    else
      redirect_to root_path
    end
  end

  private

  def redirect_if_complete
    redirect_to root_path if current_user.complete?
  end

  def current_step
    return :profile unless current_user.profile_complete?
    return :terms unless current_user.terms_accepted?

    :complete
  end

  def profile_step_required?
    !current_user.profile_complete?
  end

  def step_number
    profile_step_required? ? (current_step == :profile ? 1 : 2) : 1
  end
  helper_method :step_number, :total_steps, :profile_step_required?

  def total_steps
    profile_step_required? ? 2 : 1
  end

  def handle_profile_step
    if current_user.update(profile_params)
      @current_step = current_step

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to onboarding_path }
      end
    else
      @current_step = :profile
      render :show, status: :unprocessable_entity
    end
  end

  def handle_terms_step
    if ActiveModel::Type::Boolean.new.cast(params[:terms_accepted])
      current_user.update!(terms_accepted_at: Time.current)
      redirect_to root_path, notice: "¡Bienvenido! Tu cuenta está lista."
    else
      @current_step = :terms
      flash.now[:alert] = "Debes aceptar los términos para continuar."
      render :show, status: :unprocessable_entity
    end
  end

  def profile_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :residence_commune_id,
      :work_commune_id,
      :study_commune_id
    )
  end

  def load_regions
    @regions = Region.order(:name)
  end
end
