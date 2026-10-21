module Admin
  class UsersController < BaseController
    include UserRoleManagement
    include UserDirectory

    before_action :set_user, only: [ :edit, :update ]

    def index
      authorize User, :index?
      load_users_directory
    end

    def edit
      authorize @user, :edit?
    end

    def update
      authorize @user, :update?

      @user.audit_actor = current_user
      assign_user_role_and_active(@user, allowed_roles: policy(@user).assignable_roles)
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
  end
end
