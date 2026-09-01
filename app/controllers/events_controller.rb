class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [ :show, :calendar ]

  def index
    authorize Event

    @selected_commune_id = params[:commune_id]
    @selected_event_type = selected_event_type_param
    @communes = Commune.in_territory
    @events = filtered_events
    @events_by_date = @events.group_by { |event| event.start_at.to_date }
  end

  def show
    authorize @event
    @attendance = @event.attendances.find_by(user: current_user)
  end

  def new
    @event = Event.new
    authorize @event
    @communes = Commune.in_territory
  end

  def create
    @event = Event.new(event_params.merge(organizer: current_user, status: initial_event_status))
    authorize @event
    @communes = Commune.in_territory

    if @event.save
      notice = @event.approved? ? "Evento publicado correctamente." : "Evento enviado a moderación."
      redirect_to event_path(@event), notice: notice
    else
      render :new, status: :unprocessable_entity
    end
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
    policy_scope(Event)
      .includes(:organizer, :commune)
      .by_commune(@selected_commune_id)
      .by_event_type(@selected_event_type)
  end

  def selected_event_type_param
    return unless params[:event_type].present?
    return unless Event.event_types.key?(params[:event_type])

    params[:event_type]
  end

  def event_params
    params.require(:event).permit(
      :title,
      :description,
      :location,
      :start_at,
      :end_at,
      :event_type,
      :commune_id,
      :capacity
    )
  end

  def initial_event_status
    if current_user.board_member? || current_user.technical_admin?
      :approved
    else
      :pending
    end
  end
end
