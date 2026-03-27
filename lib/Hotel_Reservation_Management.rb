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

    def initialize(room_number, nights)
        super(room_number, nights)
        BASE_RATE = 80.00
        RATE_PER_NIGHT = 40.00  
    end

    def cost_calculator(nights)
        BASE_RATE + (RATE_PER_NIGHT * nights)
    end

class SuiteRoom < Room

    def initialize(room_number, nights)
        super(room_number, nights)
        BASE_RATE = 80.00
        RATE_PER_NIGHT = 40.00
        SUITE_FEE = 75.00
    end

    def cost_calculator(nights)
        BASE_RATE + (RATE_PER_NIGHT * nights) + SUITE_FEE
    end

class CabanaRoom < Room

    def initialize(room_number, nights)
        super(room_number, nights)
        BASE_RATE = 80.00
        RATE_PER_NIGHT = 40.00
        PEAK_MULTIPLIER = 1.5
    end

    def cost_calculator(nights)
        (BASE_RATE + (RATE_PER_NIGHT * nights)) * PEAK_MULTIPLIER
    end