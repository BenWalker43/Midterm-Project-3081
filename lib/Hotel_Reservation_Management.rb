
class Room

    def initialize(room_number, nights)
        @room_number = room_number
        @nights = nights
    end

    def cost_calculator(nights)
        raise NotImplementedError
    end

    def description(room_number, nights)
        raise NotImplementedError
    end

end

class StandardRoom < Room

    BASE_RATE = 80.00
    RATE_PER_NIGHT = 40.00
    def initialize(room_number, nights)
        super(room_number, nights)  
    end

    def cost_calculator(nights)
        BASE_RATE + (RATE_PER_NIGHT * nights)
    end
end
class SuiteRoom < Room

    BASE_RATE = 80.00
    RATE_PER_NIGHT = 40.00
    SUITE_FEE = 75.00
    def initialize(room_number, nights)
        super(room_number, nights)
    end

    def cost_calculator(nights)
        BASE_RATE + (RATE_PER_NIGHT * nights) + SUITE_FEE
    end
  end
class CabanaRoom < Room
    BASE_RATE = 80.00
    RATE_PER_NIGHT = 40.00
    PEAK_MULTIPLIER = 1.5
    def initialize(room_number, nights)
        super(room_number, nights)
    end

    def cost_calculator(nights)
        (BASE_RATE + (RATE_PER_NIGHT * nights)) * PEAK_MULTIPLIER
    end
end


#reservation classes
class ReservationEvent
    attr_reader :status, :location, :timestamp, :notes

    def initialize(status, location, timestamp, notes)
        @status = status
        @location = location
        @timestamp = timestamp
        @notes = notes

    end

end

class Reservation
  attr_reader :guest_name, :confirmation_number

  def initialize(guest_name, room, notifiers)
    raise ArgumentError, "At least one notifier is required" if notifiers.nil? || notifiers.empty?

    @guest_name = guest_name
    @room = room
    @notifiers = notifiers
    @confirmation_number = generate_confirmation_number
    @events = []
  end

  
  def update_status(status, location, notes = nil)
    event = ReservationEvent.new(status, location, Time.now, notes)
    @events << event

    @notifiers.each do |notifier|
      notifier.notify(self, event)
    end
  end

  
  def latest_status
    return "not_yet_confirmed" if @events.empty?
    @events.last.status
  end

  
  def event_history
    @events.dup
  end

  
  def total_cost
    @room.cost_calculator
  end

  private

  def generate_confirmation_number
    "RES#{Time.now.to_i}#{rand(1000..9999)}"
  end
end



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

class EmailNotifier
  def initialize(guest_email)
    @guest_email = guest_email
  end

  def notify(reservation, event)
    subject, opening = template_for(event.status)

    puts "[Email to #{@guest_email}]:"
    puts "Subject: #{subject}\n\n"
    puts opening
    puts

    puts "Status   : #{event.status}"
    puts "Location : #{event.location}"
    puts "Time     : #{event.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "Notes    : #{event.notes}" if event.notes && !event.notes.empty?
  end

  private

  def template_for(status)
    {
      "confirmed" => [
        "Reservation Confirmed — #{status}", # NOTE: Reservation number should be injected by Reservation if required
        "We're pleased to confirm your upcoming reservation."
      ],
      "checked_in" => [
        "Welcome to Grand Hotel!",
        "Your room is ready. We hope you enjoy every moment of your stay."
      ],
      "checked_out" => [
        "Thank you for staying with us",
        "We hope you had a wonderful stay. Your visit means a lot to us."
      ],
      "do_not_disturb" => [
        "Do Not Disturb Activated",
        "Your Do Not Disturb preference has been recorded."
      ],
      "service_requested" => [
        "Service Request Received",
        "Thank you for reaching out. Our team will be with you shortly."
      ]
    }[status]
  end
end

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


