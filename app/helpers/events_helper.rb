module EventsHelper
  def capacity_label_for(event)
    return "Cupos ilimitados" if event.unlimited_capacity?

    remaining = event.remaining_capacity
    "Quedan #{remaining} de #{event.capacity} cupos"
  end
end
