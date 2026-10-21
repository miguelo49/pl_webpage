module Admin
  class UsersController < BaseController
    include UserRoleManagement

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
      assign_user_role_and_active(@user)
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
