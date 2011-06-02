#!/usr/bin/ruby -I../lib

require "test/unit"

require "Strategie"
require "Decisions"

class TestDecisions < Test::Unit::TestCase
        
        def setup
                @s1 = FausseStrategie1.new
                @s2 = FausseStrategie2.new                
                @s3 = FausseStrategie3.new
                @s4 = FausseStrategie4.new
                 
                @decisions = Decisions.new
        end
        
        def testViderStrategies
                @decisions.viderStrategies
                assert_equal(0, @decisions.nombreStrategies)
        end
        
        def testChargerStrategies
                @decisions.viderStrategies
                assert_equal(0, @decisions.nombreStrategies)
                @decisions.charge @s1
                assert_equal(1, @decisions.nombreStrategies)
                @decisions.charge @s2
                assert_equal(2, @decisions.nombreStrategies)
        end
        
        def testDefinirPosition
                p = Position.new(10, 10, 0)
                q = Position.new(400, 110, Math::PI/2)
                @decisions.position = p
                assert_equal(p, @decisions.position)
                @decisions.position = q
                assert_equal(q, @decisions.position)
        end
        
        def testMeilleurChoixPosition
                @decisions.viderStrategies
                assert_equal(nil, @decisions.meilleurChoix)
                @decisions.charge @s1
                @decisions.charge @s2
                @decisions.position = Position.new(0, 0, Math::PI)
                assert_equal(@s1, @decisions.meilleurChoix)
                @decisions.position = Position.new(450, 100, 0)
                assert_equal(@s2, @decisions.meilleurChoix)
        end
        
        def testTempsRestantParDefaut
                assert_equal(90, Decisions.new.tempsRestant)
        end
        
        def testDefinirTempsRestant
                @decisions.tempsRestant = 90
                assert_equal(90, @decisions.tempsRestant)
                @decisions.tempsRestant = 10
                assert_equal(10, @decisions.tempsRestant)
        end
        
        def testMeilleurChoixTemps
                @decisions.charge @s1
                @decisions.charge @s2
                @decisions.tempsRestant = 15
                @decisions.position = Position.new(450, 100, 0)
                assert_equal(@s1, @decisions.meilleurChoix)
        end
        
        def testChoixStrategiePossible
                @decisions.charge @s4
                @decisions.charge @s1
                @decisions.tempsRestant = 15
                @decisions.position = Position.new(450, 100, 0)
                assert_equal(@s1, @decisions.meilleurChoix)
        end
end

class FausseStrategie1 < Strategie
       
        def initialize
                super(10, 100, Position.new(0, 0, 0))
        end
        
        def sequence
                1
        end
        
end

class FausseStrategie2 < Strategie
       
        def initialize
                super(20, 100, Position.new(500, 100, Math::PI))
        end
        
        def sequence
                1
        end
        
end

class FausseStrategie3 < Strategie
       
        def initialize
                super(20, 300, Position.new(100, 0, 0))
        end
        
        def sequence
                1
        end
        
end

class FausseStrategie4 < Strategie
       
        def initialize
                super(10, 100, Position.new(0, 0, 0))
        end
        
        def sequence
                1
        end
        
        def condition
                false
        end  
        
end
