require_relative "reservation_event"

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
    @room.cost_calculator()
  end

  private

  def generate_confirmation_number
    "RES#{Time.now.to_i}#{rand(1000..9999)}"
  end
end