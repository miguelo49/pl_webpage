module Admin
  class ModeratorsController < BaseController
    ELIGIBLE_ROLES = %w[militant board_member].freeze
    RESTORE_ROLES = ELIGIBLE_ROLES.freeze
    LISTED_ROLES = (ELIGIBLE_ROLES + [ "moderator" ]).freeze

    before_action :set_user, only: [ :create, :destroy ]

    def index
      authorize :admin, :index?

      @selected_filter = selected_filter_param
      @users = filtered_users
    end

    def create
      authorize :admin, :update?

      unless eligible_for_moderator?(@user)
        redirect_to admin_moderators_path(filter: selected_filter_param), alert: "Solo militantes o directiva pueden ser moderadores."
        return
      end

      assign_moderator_role(@user)
    end

    def destroy
      authorize :admin, :update?

      unless @user.moderator?
        redirect_to admin_moderators_path(filter: selected_filter_param), alert: "Este usuario no es moderador."
        return
      end

      restore_role = params.require(:restore_role)
      unless RESTORE_ROLES.include?(restore_role)
        redirect_to admin_moderators_path(filter: selected_filter_param), alert: "Rol de restauración inválido."
        return
      end

      revoke_moderator_role(@user, restore_role: restore_role)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def filtered_users
      scope = User.where(role: roles_for_filter).order(:last_name, :first_name, :email)
      scope = scope.where(role: :moderator) if @selected_filter == "moderators"
      scope = scope.where(role: ELIGIBLE_ROLES) if @selected_filter == "eligible"
      scope
    end

    def roles_for_filter
      case @selected_filter
      when "moderators" then [ :moderator ]
      when "eligible" then ELIGIBLE_ROLES
      else LISTED_ROLES
      end
    end

    def selected_filter_param
      filter = params[:filter].presence
      return "all" unless filter.in?(%w[all eligible moderators])

      filter
    end

    def eligible_for_moderator?(user)
      user.militant? || user.board_member?
    end

    def assign_moderator_role(user)
      user.audit_actor = current_user
      ensure_commune_for_militant_role(user)

      if user.update(role: :moderator)
        redirect_to admin_moderators_path(filter: selected_filter_param), notice: "Rol de moderador asignado."
      else
        redirect_to admin_moderators_path(filter: selected_filter_param), alert: user.errors.full_messages.to_sentence
      end
    end

    def revoke_moderator_role(user, restore_role:)
      user.audit_actor = current_user
      ensure_commune_for_militant_role(user)

      if user.update(role: restore_role)
        redirect_to admin_moderators_path(filter: selected_filter_param), notice: "Rol de moderador revocado."
      else
        redirect_to admin_moderators_path(filter: selected_filter_param), alert: user.errors.full_messages.to_sentence
      end
    end

    def ensure_commune_for_militant_role(user)
      return unless user.militant_or_above?
      return if user.residence_commune_id.present?

      user.residence_commune = current_user.residence_commune || Commune.first
    end
  end
end
