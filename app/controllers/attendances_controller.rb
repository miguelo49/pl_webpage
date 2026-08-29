class AttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event

  def create
    @attendance = @event.attendances.find_or_initialize_by(user: current_user)
    @attendance.status = :registered
    authorize @attendance

    if @attendance.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_path(@event), notice: "Te inscribiste al evento." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { redirect_to event_path(@event), alert: @attendance.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    @attendance = @event.attendances.find_by!(user: current_user)
    authorize @attendance
    @attendance.status = attendance_params[:status]

    if @attendance.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_path(@event), notice: attendance_notice }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update, status: :unprocessable_entity }
        format.html { redirect_to event_path(@event), alert: @attendance.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_event
    @event = Event.includes(:attendances).find(params[:event_id])
  end

  def attendance_params
    params.require(:attendance).permit(:status)
  end

  def attendance_notice
    case @attendance.status
    when "confirmed"
      "Asistencia confirmada."
    when "cancelled"
      "Inscripción cancelada."
    else
      "Inscripción actualizada."
    end
  end
end
