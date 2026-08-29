class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [ :show ]

  def show
    authorize @event
    @attendance = @event.attendances.find_by(user: current_user)
  end

  private

  def set_event
    @event = Event.includes(:organizer, :commune, :attendances).find(params[:id])
  end
end
