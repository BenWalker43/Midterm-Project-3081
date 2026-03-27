class FrontDeskNotifier
  def notify(reservation, event)
    puts "----------------------------------------"
    puts "FRONT DESK ALERT"
    puts "----------------------------------------"
    puts "Reservation : #{reservation.confirmation_number}"
    puts "Status      : #{event.status}"
    puts "Location    : #{event.location}"
    puts "Time        : #{event.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "Notes       : #{event.notes}" if event.notes && !event.notes.empty?
    puts "----------------------------------------"
    puts instruction_for(event.status)
    puts "----------------------------------------"
  end

  private

  def instruction_for(status)
    {
      "confirmed" => "New reservation confirmed. Please prepare room assignment.",
      "checked_in" => "Guest has checked in. Notify housekeeping to remove turndown service.",
      "checked_out" => "Guest has checked out. Flag room for housekeeping.",
      "do_not_disturb" => "Do Not Disturb active. Hold all housekeeping visits for this room.",
      "service_requested" => "Guest has requested service. Dispatch nearest available staff member."
    }[status]
  end
end


