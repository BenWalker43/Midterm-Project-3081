#!/usr/bin/env ruby

# Add lib directory to load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require_relative '../lib/rooms/room'
require_relative '../lib/rooms/standard_room'
require_relative '../lib/rooms/suite_room'
require_relative '../lib/rooms/cabana_room'
require_relative '../lib/reservation'
require_relative '../lib/reservation_event'
require_relative '../lib/notifiers/text_notifier'
require_relative '../lib/notifiers/email_notifier'
require_relative '../lib/notifiers/front_desk_notifier'

puts "=" * 60
puts "  Hotel Reservation Management System Demo"
puts "=" * 60
puts

# Demo 1: Standard Room Reservation
puts "DEMO 1: Standard Room Booking"
puts "-" * 60

standard_room = StandardRoom.new(101, 2)
puts "Room Created: #{standard_room.description}"
puts "Cost for stay: $#{standard_room.cost_calculator}"
puts

# Create notifiers
text_notifier = TextNotifier.new("555-0123")
email_notifier = EmailNotifier.new("john@example.com")
front_desk = FrontDeskNotifier.new

# Create reservation
reservation1 = Reservation.new("John Smith", standard_room, [text_notifier, email_notifier, front_desk])
puts "Reservation created: #{reservation1.confirmation_number} (Guest: #{reservation1.guest_name})"
puts

# Update status - confirmed
puts "\n>>> Guest Status: CONFIRMED"
puts "-" * 60
reservation1.update_status("confirmed", "Front Desk")
puts

# Update status - checked in
puts "\n>>> Guest Status: CHECKED IN"
puts "-" * 60
reservation1.update_status("checked_in", "Room 101")
puts

# Show reservation details
puts "\n>>> Reservation Summary"
puts "-" * 60
puts "Current Status: #{reservation1.latest_status}"
puts "Total Cost: $#{standard_room.cost_calculator}"
puts "Event History:"
reservation1.event_history.each_with_index do |event, index|
  puts "  #{index + 1}. #{event.to_s}"
end
puts

# Demo 2: Cabana Room with Service Request
puts "\n" + "=" * 60
puts "DEMO 2: Cabana Room with Service Request"
puts "-" * 60

cabana_room = CabanaRoom.new(250, 4)
puts "Room Created: #{cabana_room.description}"
puts "Cost for stay: $#{cabana_room.cost_calculator}"
puts

# Only text and email for this guest
text_notifier2 = TextNotifier.new("555-0456")
email_notifier2 = EmailNotifier.new("sarah@example.com")

reservation2 = Reservation.new("Sarah Johnson", cabana_room, [text_notifier2, email_notifier2])
puts "Reservation created: #{reservation2.confirmation_number} (Guest: #{reservation2.guest_name})"
puts

# Guest journey
puts "\n>>> Guest Status: CONFIRMED"
puts "-" * 60
reservation2.update_status("confirmed", "Front Desk")
puts

puts "\n>>> Guest Status: CHECKED IN"
puts "-" * 60
reservation2.update_status("checked_in", "Room 250", "Early arrival, suite upgrade requested")
puts

puts "\n>>> Guest Status: SERVICE REQUESTED"
puts "-" * 60
reservation2.update_status("service_requested", "Pool Area", "Room service delivery")
puts

# Show reservation details
puts "\n>>> Reservation Summary"
puts "-" * 60
puts "Current Status: #{reservation2.latest_status}"
puts "Total Cost: $#{cabana_room.cost_calculator}"
puts "Total Events: #{reservation2.event_history.length}"
puts

# Demo 3: Suite Room with Multiple Status Updates
puts "\n" + "=" * 60
puts "DEMO 3: Suite Room - Full Journey with Do Not Disturb"
puts "-" * 60

suite_room = SuiteRoom.new(305, 3)
puts "Room Created: #{suite_room.description}"
puts "Cost for stay: $#{suite_room.cost_calculator}"
puts

# All notifiers
all_notifiers = [
  TextNotifier.new("555-0789"),
  EmailNotifier.new("michael@example.com"),
  FrontDeskNotifier.new
]

reservation3 = Reservation.new("Michael Chen", suite_room, all_notifiers)
puts "Reservation created: #{reservation3.confirmation_number} (Guest: #{reservation3.guest_name})"
puts

# Full guest journey
puts "\n>>> Guest Status: CONFIRMED"
puts "-" * 60
reservation3.update_status("confirmed", "Front Desk")
puts

puts "\n>>> Guest Status: CHECKED IN"
puts "-" * 60
reservation3.update_status("checked_in", "Room 305", "Late check-in after business meeting")
puts

puts "\n>>> Guest Status: DO NOT DISTURB"
puts "-" * 60
reservation3.update_status("do_not_disturb", "Room 305")
puts

puts "\n>>> Guest Status: CHECKED OUT"
puts "-" * 60
reservation3.update_status("checked_out", "Front Desk", "Early departure")
puts

# Show full reservation details
puts "\n>>> Final Reservation Summary"
puts "-" * 60
puts "Guest: #{reservation3.guest_name}"
puts "Confirmation: #{reservation3.confirmation_number}"
puts "Final Status: #{reservation3.latest_status}"
puts "Total Cost: $#{suite_room.cost_calculator}"
puts "Total Events: #{reservation3.event_history.length}"
puts "\nComplete Event Timeline:"
reservation3.event_history.each_with_index do |event, index|
  puts "  #{index + 1}. #{event.to_s}"
end
puts


