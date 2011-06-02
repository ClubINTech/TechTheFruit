# Ce fichier contient les fonctions qui permettent de lisser une suite de points
# Author::    Clément Bethuys  (mailto:clement.bethuys@laposte.net)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Point"

# Permet de générer des B-splines qui sont une généralisation de Bezier
class Bspline

	public

	# Calcul la Bspline entre les points de "listePoints" en "mult" points espacés entre chacun de ces points et avec le degré spécifié
	def initialize(listePoints,mult=5,degre=3)
		listePoints.push(listePoints[listePoints.length() -1])
		listePoints.push(listePoints[listePoints.length() -1])
		n=degre
		@m= n + listePoints.length
		@tab=Array.new
		(n+1).times do
			@tab.push(0)
		end
		restant=@m+1-2*(n+1)
		for i in (1 .. restant)
			@tab.push(i.to_f/restant)
		end
		(n+1).times do
			@tab.push(1)
		end
		@resultat=Array.new
		for t in (0 .. @m*mult -1) do
		sum=Point.new(0,0)
			for i in (0 .. @m-n-1) do
				sum += listePoints[i]*b(i,n,t.to_f/(@m*mult))
			end
		@resultat.push(sum)
		end
		return @resultat
	end
	
	# Retourne la b-spline précédement calculée
	def get
		return @resultat
	end

	private
	
	# Renvoie le valeur du coefficient pour le point "i" avec le degré "d" et en "u" valeur du calcul
	def b(i,d,u)
		if(d==0)
			if(@tab[i]<= u and u<@tab[i+1])then return 1
			else return 0 end
		else
			val_1=0
			val_2=0
			if(@tab[i+d]-@tab[i]!= 0.0) then val_1 = ((u-@tab[i])*b(i,d-1,u)).to_f/(@tab[i+d]-@tab[i])end
			if(@tab[i+d+1]-@tab[i+1]!=0.0) then val_2 = ((@tab[i+d+1]-u)*b(i+1,d-1,u)).to_f/(@tab[i+d+1]-@tab[i+1])	end		
			return val_1 + val_2
		end
	end
end

# Permet de générer des courbes de Bezier
class Bezier

	public

	
	# On calcule "mult" points de la courbe à intervalle constant à partir des "v" points de contrôle
	def initialize v,mult

		@v=v
		@longeur=v.length-1
		n=@longeur*mult
		@listePoints=Array.new
		for i in (0 .. n)
			@listePoints.push(valeur(i.to_f/n))
		end
	end

	# Retourne la courbe de bezier précédement calculée
	def get
		return @listePoints
	end 

	private

	# Retourne la position de la courbe pour la valeur "u"
	def valeur(u)
		retour=Point.new(0,0)
		for i in (0 .. @longeur)
			retour = retour + @v[i]*coeffBernstein(i,@longeur,u)	
		end
		return retour	
	end

	# Retourne le coefficient de Bernstein 
	def coeffBernstein (p,n,u)
		return coeffBinome(p,n)*u**p*(1-u)**(n-p)	
	end

	# Retourne le coefficient du binome pour p<n
	def coeffBinome(p,n)
		return fact(n)/(fact(n-p)*fact(p))
	end

	# Calcule la factorielle. Méthode pas adaptée si l'on veux aller vite
	def fact(n)
		if n <= 0
			return 1
		else
			return n * fact(n-1)
		end
	end
end
