# frozen_string_literal: true

##
# A class to mock for testing Grift
#
class Mark < Target
  attr_reader :status

  def initialize(first_name: 'Tobias', last_name: 'Funke', gullible: true, secrets: [])
    super

    @status = 0
  end

  def upgrade(increase = 1)
    @status += increase
  end
end
