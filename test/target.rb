# frozen_string_literal: true

##
# A class to mock for testing Grift
#
class Target
  attr_reader :first_name, :last_name, :gullible, :knowledge

  def self.mimic(target, gullible: false)
    Target.new(first_name: target.first_name, last_name: target.last_name, gullible: gullible)
  end

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

  def change_name(first_name: nil, last_name: nil)
    @first_name = first_name if first_name
    @last_name = last_name if last_name
  end

  def act
    yield
  end

  def ==(other)
    @first_name == other.first_name &&
      @last_name == other.last_name &&
      @gullible == other.gullible &&
      @knowledge == other.knowledge &&
      knows_secrets? == other.knows_secrets?
  end

  protected

  def gullible?
    @gullible
  end

  private

  def wipe_memory
    @knowledge = []
    @secrets = []
  end
end
