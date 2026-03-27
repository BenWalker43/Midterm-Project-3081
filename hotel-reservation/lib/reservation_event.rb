class ReservationEvent
    attr_reader :status, :location, :timestamp, :notes

    def initialize(status, location, timestamp, notes)
        @status = status
        @location = location
        @timestamp = timestamp
        @notes = notes

    end


    def to_s
        result = "[#{@timestamp.strftime('%Y-%m-%d %H:%M:%S')}] #{@status} at #{@location}"
        result += " - Notes: #{@notes}" if @notes && !@notes.empty?
        result
    end
end