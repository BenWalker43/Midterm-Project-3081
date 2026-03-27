require_relative "room"

class StandardRoom < Room

    BASE_RATE = 80.00
    RATE_PER_NIGHT = 40.00
    def initialize(room_number, nights)
        super(room_number, nights)  
    end

    def cost_calculator
        BASE_RATE + (RATE_PER_NIGHT * @nights)
    end

    def description
        "StandardRoom: #{@nights} nights in Room #{@room_number}"
    end
end