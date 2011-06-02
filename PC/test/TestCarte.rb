#!/usr/bin/ruby -I../lib

require "test/unit"

require "Carte"

class TestCarte < Test::Unit::TestCase
        def setup
                @carte = Carte.new
        end
        
        def testPositionParDefaut
                assert_equal(Position.new(0, 0, 0), @carte.position)
                @carte.position = Position.new(10, 0, 10)
                assert_equal(Position.new(10, 0, 10), @carte.position)
        end
        
        def testAjoutPointPassage
                assert_equal(0, @carte.ajoutPointPassage(Point.new(0, 0)))
                assert_equal(1, @carte.ajoutPointPassage(Point.new(100, 0)))
                assert_equal(2, @carte.ajoutPointPassage(Point.new(0, 100)))
        end
        
        def testAjoutLiaison
                 @carte.ajoutPointPassage(Point.new(0, 0))
                 @carte.ajoutPointPassage(Point.new(100, 0))
                 @carte.ajoutLiaison(0, 1)
                 assert_equal([Point.new(100, 0)], @carte.parcours(Point.new(100, 0)))
                 
                 @carte.ajoutPointPassage(Point.new(0, 100))
                 @carte.ajoutPointPassage(Point.new(100, 100))
                 
                 @carte.ajoutLiaison(0, 2)
                 @carte.ajoutLiaison(0, 3)
                 @carte.ajoutLiaison(1, 3)
                 @carte.ajoutLiaison(2, 3)
                 
                 assert_equal([Point.new(100, 100)], @carte.parcours(Point.new(100, 100)))
                 
                 @carte.ajoutPointPassage(Point.new(200, 0))
                 @carte.ajoutLiaison(1, 4)
                 @carte.ajoutLiaison(3, 4)
                 
                 assert_equal([Point.new(100, 0), Point.new(200, 0)], @carte.parcours(Point.new(200, 0)))
        end
        
        def testPointLePlusProche
                @carte.ajoutPointPassage(Point.new(0, 0))
                @carte.ajoutPointPassage(Point.new(100, 0))
                @carte.ajoutLiaison(0, 1)
                parcours = @carte.parcours(Point.new(110, 1))
                assert_equal([Point.new(110, 1)], parcours)
        end
        
        def testAucunPointPassage
                assert_equal([Point.new(200, 0)], @carte.parcours(Point.new(200, 0)))
        end
end
