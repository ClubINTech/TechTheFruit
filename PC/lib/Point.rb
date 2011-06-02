# Ce fichier contient la classe Point.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

# Cette classe définit les fonctions de base pour le calcul sur les coordonnées
# d'un point.

class Point
 
 	# Un point est défini par son abscisse et son ordonnée
	attr_accessor :x, :y
 
 	# Initialisation avec un x et y donné
	def initialize x = 0, y = 0
		@x = x
		@y = y
	end
 
 	# Somme des abscisses et des ordonnées de 2 points
	def + q
		Point.new((@x + q.x), (@y + q.y))
	end
	
 	# Produit d'un point par une constante
	def * k
		Point.new((@x * k), (@y * k))
	end
	
	def - q
	        Point.new((@x - q.x), (@y - q.y))
	end
	
 	# Division d'un point par une constante
	def / k
		self.*(1.0/k)
	end
	
	# Test d'égalité de 2 points
	def == p
		(p.x == @x && p.y == @y)
	end
	
	# Affiche les attributs d'un point
	def prettyprint
	        puts "x = " + x.to_s + ", y = " + y.to_s
	end
	
	def to_i
	        @x = @x.to_i
	        @y = @y.to_i
                self
	end
	
	def symetrie
	       Point.new(@x, -1 * @y)
	end
	
	
 
end
