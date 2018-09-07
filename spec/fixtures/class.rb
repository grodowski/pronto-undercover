# frozen_string_literal: true

class BaconClass
  def self.bar
    puts "BaconClass\x87"
  end

  def foo
    puts 'Covered line'
    puts 'BaconClass#f'
  end

  class BaconChildClass
    def foo_child
      puts 'BaconClass::BaconChildClass#lol'
    end
  end
  private_constant :BaconChildClass
end
