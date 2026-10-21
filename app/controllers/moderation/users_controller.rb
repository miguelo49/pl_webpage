module Moderation
  class UsersController < BaseController
    include UserRoleManagement

    before_action :set_user, only: [ :edit, :update ]

    def index
      authorize User, :index?
      @users = policy_scope(User).order(:last_name, :first_name, :email)
    end

    def edit
      authorize @user, :edit?
    end

    def update
      authorize @user, :update?

      @user.audit_actor = current_user
      assign_user_role_and_active(@user, allowed_roles: UserPolicy::MODERATOR_ASSIGNABLE_ROLES)
      ensure_commune_for_militant_role(@user)

      if @user.save
        redirect_to moderation_users_path, notice: "Usuario actualizado."
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
