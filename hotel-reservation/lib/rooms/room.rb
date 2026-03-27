class Room

    def initialize(room_number, nights)
        @room_number = room_number
        @nights = nights
    end

    def cost_calculator
        raise NotImplementedError
    end

    def description
        raise NotImplementedError
    end

end