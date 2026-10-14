# frozen_string_literal: true

# Uses the installed grift gem the way a consumer would, so run it with plain
# `ruby` after `gem install`, not through Bundler or with lib on the load path.
require 'grift'

loaded_from = Grift.method(:mock).source_location.first
unless Gem.path.any? { |dir| loaded_from.start_with?(dir) }
  abort "grift was loaded from #{loaded_from}, not an installed gem"
end

class Widget
  def color
    'blue'
  end
end

Grift.mock(Widget, :color, 'red')
abort 'mocking did not replace the method' unless Widget.new.color == 'red'

Grift.restore_all_mocks
abort 'restoring did not bring back the method' unless Widget.new.color == 'blue'

puts "grift #{Grift::VERSION} works when installed (loaded from #{loaded_from})"
