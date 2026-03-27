require_relative "room"

class CabanaRoom < Room
    BASE_RATE = 80.00
    RATE_PER_NIGHT = 40.00
    PEAK_MULTIPLIER = 1.5
    def initialize(room_number, nights)
        super(room_number, nights)
    end

    def cost_calculator
        (BASE_RATE + (RATE_PER_NIGHT * @nights)) * PEAK_MULTIPLIER
    end


    def description
        "CabanaRoom: #{@nights} nights in Room #{@room_number}"
    end
end