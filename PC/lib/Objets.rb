# Ce fichier contient l'ensemble des objets présents sur la table,
# leur caractéristiques ainsi qu'une fonction pour les afficher
# Author::    Clément Bethuys  (mailto:clement.bethuys@laposte.net)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Point"
#require "sdl"

# Objet Chemin qui possède une fonction d'impression par la SDL
class Chemin

	public 

	attr_accessor :listePoints

	# Garde la liste de points passée en tant structure de classe pour pouvoir ensuite l'afficher
	def initialize(listePoints)
		@listePoints=listePoints
	end

	# affiche une ligne entre chaque points de la listePoints
	# pour l'instant le trait est toujours d'un pixel de large
	# le parametre diviseur permet de représenter la table de 3000 points en 3000/diviseurs points 
	# pour une affichage (par la SDL) qui ne dépasse pas la taille de l'ecran du pc
	def afficher(ecran,diviseur)
		couleur=ecran.mapRGB(255,0,0)
		noir=ecran.mapRGB(0,0,0)
		rayon=20
		taille=@listePoints.length
		for i in (0 .. taille-2)
			ecran.drawLine(@listePoints[i].x/diviseur,@listePoints[i].y/diviseur,@listePoints[i+1].x/diviseur,@listePoints[i+1].y/diviseur,couleur)
		end
		for i in (0 .. taille-1)
			ecran.drawFilledEllipse(@listePoints[i].x/diviseur,@listePoints[i].y/diviseur,rayon/diviseur,rayon/diviseur,noir)
		end
	end
end

# Objet Epis qui possède une fonction d'impression par la SDL
class Epis

	public

	attr_accessor :position
	
	# Initialise un épis à la position "position" et possédant le rayon passé
	def initialize(position,rayon=25+170)
		@position= position
		@rayon=rayon
	end

	# Affiche un cercle mis à la bonne taille grace à l'utilisation de "diviseur" (voir classe chemin)
	def afficher(ecran,diviseur)
		couleur=ecran.mapRGB(0,0,0)
		ecran.drawFilledEllipse(@position.x/diviseur,@position.y/diviseur,@rayon/diviseur,@rayon/diviseur,couleur)
	end
end

# Objet Tomate qui possède une fonction d'impression par la SDL
class Tomate

	public

	attr_accessor :position

	# Initialise une tomate à la position "position" et possédant le rayon passé
	def initialize(position,rayon=50)
		@position= position
		@rayon=rayon
	end

	# Affiche un cercle mis à la bonne taille grace à l'utilisation de "diviseur" (voir classe chemin)
	def afficher(ecran,diviseur)
		couleur=ecran.mapRGB(255,0,0)
		ecran.drawFilledEllipse(@position.x/diviseur,@position.y/diviseur,@rayon/diviseur,@rayon/diviseur,couleur)
	end
end

# Objet Pente qui possède une fonction d'impression par la SDL
class Pente

	public

	# Crée un rectangle qui aura pour coin gauche "position_1" et pour coin droit "position_2"
	def initialize(position_1,position_2)
		@position= position_1
		@taille= position_2 -position_1
	end

	# Affiche un rectangle mis à la bonne taille grace à l'utilisation de "diviseur" (voir classe chemin)
	def afficher(ecran,diviseur)
		couleur=ecran.mapRGB(128,0,0)
		ecran.fillRect(@position.x/diviseur,@position.y/diviseur,@taille.x/diviseur,@taille.y/diviseur,couleur)
	end
end

# Objet Zone_Depart qui possède une fonction d'impression par la SDL
class Zone_Depart

	public

	# La couleur désirée lors de l'affichage est spécifiée lors de l'initialisation
	def initialize(position_1,position_2,couleur)
		@position= position_1
		@taille= position_2 - position_1
		@couleur_voulue=couleur		
	end

	# Affiche un rectangle mis à la bonne taille grace à l'utilisation de "diviseur" (voir classe chemin)
	def afficher(ecran,diviseur)
		if @couleur_voulue=="jaune"
			couleur=ecran.mapRGB(255,255,0)
		else
			couleur=ecran.mapRGB(0,0,255)
		end
		ecran.fillRect(@position.x/diviseur,@position.y/diviseur,@taille.x/diviseur,@taille.y/diviseur,couleur)
	end
end
