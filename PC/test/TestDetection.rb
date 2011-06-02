#!/usr/bin/ruby -I../lib

require "test/unit" 

require "Detection"

class TestDetection < Test::Unit::TestCase

	def setup
		@detectionPeripherique = Detection.new $identifiantArduino
	end
	
	def testAssociation
		assert_equal @detectionPeripherique.association.size, @detectionPeripherique.identifiant.size
	end
	
end
