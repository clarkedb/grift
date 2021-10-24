# frozen_string_literal: true

##
# A class to mock for testing Grift
#
class Target
  attr_reader :first_name, :last_name, :gullible, :knowledge

  def initialize(first_name: 'Tobias', last_name: 'Funke', gullible: true, secrets: [])
    @first_name = first_name
    @last_name = last_name
    @gullible = gullible
    @knowledge = []
    @secrets = secrets
  end

  def full_name
    [@first_name, @last_name].compact.join(' ')
  end

  def convince(fact)
    @knowledge.push(fact) if @gullible
  end

  def knows_secrets?
    !@secrets.empty?
  end

  def self.mimic(target)
    Target.new(first_name: target.first_name, last_name: target.last_name, gullible: false)
  end
end
