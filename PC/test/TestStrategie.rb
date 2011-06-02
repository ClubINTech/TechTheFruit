#!/usr/bin/ruby -I../lib

require "test/unit"

require "Position"
require "Strategie"

class TestStrategie < Test::Unit::TestCase
        def setup
                @robot = nil
                @carte = nil
                @s = Strategie.new(10, 1200, Position.new(10, 0, Math::PI))
        end
        
        def testTempsRequis
                assert_equal(10, @s.temps)
        end
        
        def testPointsGagnes
                assert_equal(1200, @s.points)
        end
        
        def testExecuteSequence
                assert_equal(1, @s.sequence)
        end
        
        def testPointDepart
                assert_equal(Position.new(10, 0, Math::PI), @s.depart)
        end
        
        def testCondition
                assert_equal(true, @s.condition)
        end
end
