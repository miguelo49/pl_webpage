class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_regions, only: [ :show, :update ]
  before_action :load_bookmarked_threads, only: [ :show, :update ]

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
    params.require(:user).permit(
      :first_name,
      :last_name,
      :avatar,
      :residence_commune_id,
      :work_commune_id,
      :study_commune_id
    )
  end

  def load_regions
    @regions = Region.order(:name)
  end

  def load_bookmarked_threads
    @bookmarked_threads = bookmarked_threads_for(current_user)
  end

  def bookmarked_threads_for(user)
    ForumThread
      .joins(:bookmarks)
      .where(bookmarks: { user_id: user.id })
      .includes(:topic, :user)
      .order("bookmarks.created_at DESC")
  end
end
