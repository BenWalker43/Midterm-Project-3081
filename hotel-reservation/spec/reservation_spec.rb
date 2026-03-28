require 'spec_helper'

describe 'Reservation' do
  let(:room) { StandardRoom.new(101, 3) }
  let(:text_notifier) { TextNotifier.new("555-1234") }
  let(:email_notifier) { EmailNotifier.new("guest@example.com") }
  let(:front_desk_notifier) { FrontDeskNotifier.new }

  # ========== INITIALIZE TESTS (Success Case) ==========
  describe '#initialize - Success Case' do
    it 'creates a reservation with a single notifier' do
      reservation = Reservation.new("John Smith", room, [text_notifier])
      
      expect(reservation.guest_name).to eq("John Smith")
      expect(reservation.confirmation_number).to start_with("RES")
      expect(reservation.latest_status).to eq("not_yet_confirmed")
    end

    it 'creates a reservation with multiple notifiers' do
      reservation = Reservation.new("Sarah", room, [text_notifier, email_notifier, front_desk_notifier])
      
      expect(reservation.guest_name).to eq("Sarah")
      expect(reservation.confirmation_number).to be_a(String)
    end

    it 'generates unique confirmation numbers' do
      res1 = Reservation.new("Guest1", room, [text_notifier])
      res2 = Reservation.new("Guest2", room, [text_notifier])
      
      expect(res1.confirmation_number).not_to eq(res2.confirmation_number)
    end

    it 'stores accessible guest_name and confirmation_number' do
      reservation = Reservation.new("Alice Johnson", room, [text_notifier])
      
      expect(reservation.guest_name).to eq("Alice Johnson")
      expect(reservation.confirmation_number).to be_a(String)
    end
  end

  # ========== INITIALIZE TESTS (Fail Case) ==========
  describe '#initialize - Fail Case' do
    it 'raises error when notifiers array is empty' do
      expect {
        Reservation.new("John", room, [])
      }.to raise_error(ArgumentError, "At least one notifier is required")
    end

    it 'raises error when notifiers is nil' do
      expect {
        Reservation.new("John", room, nil)
      }.to raise_error(ArgumentError, "At least one notifier is required")
    end
  end

  # ========== UPDATE_STATUS TESTS (Success Case) ==========
  describe '#update_status - Success Case' do
    it 'creates an event and calls all notifiers' do
      reservation = Reservation.new("John", room, [text_notifier, email_notifier])
      
      expect { reservation.update_status("confirmed", "Front Desk") }
        .to output(/Your reservation at Grand Hotel is confirmed/).to_stdout
    end

    it 'updates status for confirmed' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk")
      
      expect(reservation.latest_status).to eq("confirmed")
    end

    it 'updates status for checked_in' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("checked_in", "Room 101")
      
      expect(reservation.latest_status).to eq("checked_in")
    end

    it 'updates status with notes' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("checked_in", "Room 101", "Late arrival")
      
      history = reservation.event_history
      expect(history.last.notes).to eq("Late arrival")
    end

    it 'creates multiple status updates sequentially' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk")
      reservation.update_status("checked_in", "Room 101")
      reservation.update_status("checked_out", "Front Desk")
      
      expect(reservation.latest_status).to eq("checked_out")
      expect(reservation.event_history.length).to eq(3)
    end

    it 'handles all valid statuses' do
      valid_statuses = ["confirmed", "checked_in", "checked_out", "do_not_disturb", "service_requested"]
      reservation = Reservation.new("John", room, [text_notifier])
      
      valid_statuses.each do |status|
        reservation.update_status(status, "Location")
        expect(reservation.latest_status).to eq(status)
      end
    end
  end

  # ========== LATEST_STATUS TESTS (Success Case & Edge Cases) ==========
  describe '#latest_status - Success Case & Edge Cases' do
    it 'returns "not_yet_confirmed" when no events' do
      reservation = Reservation.new("John", room, [text_notifier])
      
      expect(reservation.latest_status).to eq("not_yet_confirmed")
    end

    it 'returns latest status after single update' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk")
      
      expect(reservation.latest_status).to eq("confirmed")
    end

    it 'returns most recent status after multiple updates' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk")
      reservation.update_status("checked_in", "Room 101")
      reservation.update_status("do_not_disturb", "Room 101")
      
      expect(reservation.latest_status).to eq("do_not_disturb")
    end
  end

  # ========== EVENT_HISTORY TESTS (Success Case & Edge Cases) ==========
  describe '#event_history - Success Case & Edge Cases' do
    it 'returns empty array when no events' do
      reservation = Reservation.new("John", room, [text_notifier])
      
      expect(reservation.event_history).to eq([])
    end

    it 'returns all events after multiple updates' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk")
      reservation.update_status("checked_in", "Room 101")
      
      expect(reservation.event_history.length).to eq(2)
    end

    it 'returns events with correct status and location' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk")
      reservation.update_status("checked_in", "Room 101")
      
      history = reservation.event_history
      expect(history[0].status).to eq("confirmed")
      expect(history[0].location).to eq("Front Desk")
      expect(history[1].status).to eq("checked_in")
      expect(history[1].location).to eq("Room 101")
    end

    it 'returns a copy of history (not original array)' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk")
      
      history1 = reservation.event_history
      history1.clear
      history2 = reservation.event_history
      
      expect(history2.length).to eq(1)
    end

    it 'maintains chronological order of events' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk")
      sleep(0.01)
      reservation.update_status("checked_in", "Room 101")
      
      history = reservation.event_history
      expect(history[0].timestamp).to be < history[1].timestamp
    end
  end

  # ========== TOTAL_COST TESTS (Success Case) ==========
  describe '#total_cost - Success Case' do
    it 'calculates cost for StandardRoom' do
      standard_room = StandardRoom.new(101, 3)
      reservation = Reservation.new("John", standard_room, [text_notifier])
      
      # Cost: 80 + (40 * 3) = 200
      expect(reservation.total_cost).to eq(200.00)
    end

    it 'calculates cost for SuiteRoom' do
      suite = SuiteRoom.new(204, 2)
      reservation = Reservation.new("John", suite, [text_notifier])
      
      # Cost: 80 + (40 * 2) + 75 = 235
      expect(reservation.total_cost).to eq(235.00)
    end

    it 'calculates cost for CabanaRoom' do
      cabana = CabanaRoom.new(250, 2)
      reservation = Reservation.new("John", cabana, [text_notifier])
      
      # Cost: (80 + (40 * 2)) * 1.5 = 240
      expect(reservation.total_cost).to eq(240.00)
    end
  end

  # ========== EDGE CASES ==========
  describe 'Edge Cases' do
    it 'handles guest name with special characters' do
      room = StandardRoom.new(101, 1)
      reservation = Reservation.new("O'Brien-Smith", room, [text_notifier])
      
      expect(reservation.guest_name).to eq("O'Brien-Smith")
    end

    it 'handles room with 1 night' do
      one_night_room = StandardRoom.new(99, 1)
      reservation = Reservation.new("John", one_night_room, [text_notifier])
      
      expect(reservation.total_cost).to eq(120.00) # 80 + (40 * 1)
    end

    it 'handles large number of nights' do
      many_nights = StandardRoom.new(101, 365)
      reservation = Reservation.new("John", many_nights, [text_notifier])
      
      expect(reservation.total_cost).to eq(14680.00) # 80 + (40 * 365)
    end

    it 'handles status updates with empty notes' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk", "")
      
      expect(reservation.event_history.last.notes).to eq("")
    end

    it 'handles status updates with nil notes' do
      reservation = Reservation.new("John", room, [text_notifier])
      reservation.update_status("confirmed", "Front Desk", nil)
      
      expect(reservation.event_history.last.notes).to be_nil
    end

    it 'handles many consecutive status updates' do
      reservation = Reservation.new("John", room, [text_notifier])
      
      10.times do |i|
        reservation.update_status("confirmed", "Location #{i}")
      end
      
      expect(reservation.event_history.length).to eq(10)
    end

    it 'maintains encapsulation - room not directly accessible' do
      reservation = Reservation.new("John", room, [text_notifier])
      
      # Should only have guest_name and confirmation_number as public attrs
      expect(reservation.respond_to?(:guest_name)).to be true
      expect(reservation.respond_to?(:confirmation_number)).to be true
      expect(reservation.respond_to?(:room)).to be false
    end
  end
end

