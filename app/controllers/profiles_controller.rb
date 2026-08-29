class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to profile_path, notice: "Perfil actualizado correctamente." }
      end
    else
      @user.reload
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :avatar)
  end
end
