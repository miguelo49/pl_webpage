class OnboardingsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_if_complete, only: [ :show, :update ]

  def show
    @current_step = current_step
  end

  def update
    if current_step == :terms
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
    return :terms unless current_user.terms_accepted?

    :complete
  end

  def step_number
    1
  end
  helper_method :step_number, :total_steps

  def total_steps
    1
  end

  def handle_terms_step
    if ActiveModel::Type::Boolean.new.cast(params[:terms_accepted])
      current_user.update!(terms_accepted_at: Time.current)
      redirect_to profile_path, notice: "¡Bienvenido! Completa tu perfil cuando puedas."
    else
      @current_step = :terms
      flash.now[:alert] = "Debes aceptar los términos para continuar."
      render :show, status: :unprocessable_entity
    end
  end
end
