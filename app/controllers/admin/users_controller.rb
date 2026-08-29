module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :edit, :update ]

    def index
      authorize :admin, :index?
      @users = User.order(:last_name, :first_name, :email)
    end

    def edit
      authorize :admin, :edit?
    end

    def update
      authorize :admin, :update?

      @user.audit_actor = current_user
      @user.assign_attributes(user_params)
      ensure_commune_for_militant_role(@user)

      if @user.save
        redirect_to admin_users_path, notice: "Usuario actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:role, :active)
    end

    def ensure_commune_for_militant_role(user)
      return unless user.militant_or_above?
      return if user.residence_commune_id.present?

      user.residence_commune = current_user.residence_commune || Commune.first
    end
  end
end
