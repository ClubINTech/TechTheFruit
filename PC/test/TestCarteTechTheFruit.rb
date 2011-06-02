#!/usr/bin/ruby -I../lib

require "test/unit"

require "CarteTechTheFruit"

class TestTechTheFruit < Test::Unit::TestCase
        def setup
                @carte = CarteTechTheFruit.new
        end
        
        def testPremier
                assert(true, "Failure message.")
        end
end