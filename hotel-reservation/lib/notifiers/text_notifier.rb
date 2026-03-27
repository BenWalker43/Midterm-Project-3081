class TextNotifier
  def initialize(phone_number)
    @phone_number = phone_number
  end

  def notify(reservation, event)
    puts "[SMS to #{@phone_number}]: #{message_for(event.status)}"
  end

  private

  def message_for(status)
    {
      "confirmed" => "Your reservation at Grand Hotel is confirmed. See you soon!",
      "checked_in" => "You're checked in! Enjoy your stay at Grand Hotel.",
      "checked_out" => "Thanks for staying with us. Safe travels!",
      "do_not_disturb" => "Do Not Disturb is active for your room.",
      "service_requested" => "We've received your service request and are on our way."
    }[status]
  end
end