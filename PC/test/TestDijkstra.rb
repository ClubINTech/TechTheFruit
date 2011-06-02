#!/usr/bin/ruby -I../lib

require "test/unit"

require "Dijkstra"

class TestDijkstra < Test::Unit::TestCase

	def testLeNoeudNExistePas
		parcours = Dijkstra.new
                parcours.ajoutNoeud("a", "b", 5)
                assert_equal([], parcours.chemin("a", "d"))
	end

        def testPlusCourtChemin
                parcours = Dijkstra.new
                parcours.ajoutNoeud("a", "b", 5)
                parcours.ajoutNoeud("b", "c", 3)
                parcours.ajoutNoeud("c", "d", 1)
                parcours.ajoutNoeud("a", "d", 10)
                parcours.ajoutNoeud("b", "d", 2)
                parcours.ajoutNoeud("f", "g", 1)
                assert_equal(["a", "b", "d"], parcours.chemin("a", "d"))
        end
        
        def testSuppressionNoeud
        	parcours = Dijkstra.new
                parcours.ajoutNoeud("a", "b", 5)
                assert_equal(["a", "b"], parcours.chemin("a", "b"))
                assert parcours.supprimeNoeud("a")
                assert_equal([], parcours.chemin("a", "b"))
        end
        
        def testSuppressionNoeudComplexe
        	parcours = Dijkstra.new
                parcours.ajoutNoeud("a", "b", 2)
                parcours.ajoutNoeud("b", "c", 2)
                parcours.ajoutNoeud("a", "c", 5)
                assert_equal(["a", "b", "c"], parcours.chemin("a", "c"))
                assert parcours.supprimeNoeud("b")
                assert_equal(["a", "c"], parcours.chemin("a", "c"))
        end
        
        def testSuppressionNoeudInexistant
		parcours = Dijkstra.new
		assert !parcours.supprimeNoeud("b")
        end
        
end
