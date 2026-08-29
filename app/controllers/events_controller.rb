class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [ :show, :calendar ]

  def index
    authorize Event

    @selected_commune_id = params[:commune_id]
    @selected_event_type = selected_event_type_param
    @communes = Commune
      .where(id: Event.upcoming.select(:commune_id))
      .order(:name)
    @events = filtered_events
    @events_by_date = @events.group_by { |event| event.start_at.to_date }
  end

  def show
    authorize @event
    @attendance = @event.attendances.find_by(user: current_user)
  end

  def calendar
    authorize @event, :show?

    send_data @event.to_ics,
              filename: "#{@event.title.parameterize}.ics",
              type: "text/calendar",
              disposition: "attachment"
  end

  private

  def set_event
    @event = Event.includes(:organizer, :commune, :attendances).find(params[:id])
  end

  def filtered_events
    Event.upcoming
      .includes(:organizer, :commune)
      .by_commune(@selected_commune_id)
      .by_event_type(@selected_event_type)
  end

  def selected_event_type_param
    return unless params[:event_type].present?
    return unless Event.event_types.key?(params[:event_type])

    params[:event_type]
  end
end
