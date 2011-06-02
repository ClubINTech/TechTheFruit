# Ce fichier contient la classe Vecteur.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Point"

# Cette classe définit les fonctions de base sur les vecteurs.

class Vecteur

	# Un vecteur est défini par son dx et dy
	attr_accessor :x, :y
	
	# Initialisation avec 2 points, départ et arrivée.
	def initialize p = Point.new, q = Point.new
		@x = q.x - p.x
		@y = q.y - p.y
	end
	
	# Calcule la norme du vecteur
	def norme
		Math.sqrt(@x**2 + @y**2)
	end

	# Calcule l'angle du vecteur par rapport à l'axe (Ox)
	def angle
		Math.atan @y, @x
	end
	
	def produitScalaire v
	       (@x * v.x) + (@y * v.y)
	end
	
	def normalise
	       n = norme
		v = Vecteur.new()
		v.x = (@x / n)
		v.y = (@y/n)
		v
	end
	
	def *(k)
		v = Vecteur.new()
		v.x = @x*k
		v.y =  @y*k
		v
	end
	
	def ortho
	        v = Vecteur.new()
		v.y = @x
		v.x = @y*-1
		v
	end

	def +(vect)
		v = Vecteur.new()
		v.x = @x + vect.x
		v.y = @y + vect.y 
	end

	def -(vect)
		v = Vecteur.new()
		v.x =  vect.x - @x
		v.y =  vect.y - @y
		v 
	end



end

def sum(v1,v2)
	v = Vecteur.new()
	v.x = v1.x + v2.x
	v.y = v1.y + v2.y 
	v
end

def diff(v1,v2)
	v = Vecteur.new()
	v.x = v1.x + v2.x
	v.y = v1.y + v2.y
	v
end
