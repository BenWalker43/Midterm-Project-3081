require_relative "room"

class SuiteRoom < Room

    BASE_RATE = 80.00
    RATE_PER_NIGHT = 40.00
    SUITE_FEE = 75.00
    def initialize(room_number, nights)
        super(room_number, nights)
    end

    def cost_calculator
        BASE_RATE + (RATE_PER_NIGHT * @nights) + SUITE_FEE
    end

    def description
        "SuiteRoom: #{@nights} nights in Room #{@room_number}"
    end
  end