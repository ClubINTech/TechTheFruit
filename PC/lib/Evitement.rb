require "Log"

require "InterfaceEvitement"

class Evitement

	def initialize peripherique
		@log = Logger.instance

		if peripherique == nil
			raise "Pas de carte pour Evitement" 
		end

		@log.debug "Evitement sur " + peripherique if peripherique != nil

		@interface = InterfaceEvitement.new peripherique
	end

	def demarrer
	end

	def arreter
	end

	def ultrasons
		@interface.traitementUltrasons
	end

	def optiques
		@interface.traitementOptiques
	end

	def controleEtatHaut
		renvoie = ""
		pb = 0 #identificateur de problème
		if @interface.ultrasons[0]<=80
			renvoie = renvoie + "problème capteur HAvG, proximitée\n"
			pb = 1
		end
		if @interface.ultrasons[1]<=80
			renvoie = renvoie + "problème capteur HAvM, proximitée\n"
			pb = 1
		end
		if @interface.ultrasons[2]<=80
			renvoie = renvoie + "problème capteur HAvD, proximitée\n"
			pb = 1
		end
		if @interface.ultrasons[3]<=80
			renvoie = renvoie + "problème capteur HAr, proximitée\n"
			pb = 1
		end
		if pb == 0
			renvoie = renvoie + "à priori, il n'y a pas de problème avec les capteurs ultrason haut.\n"
		end
		renvoie
	end

	def controleEtatUS
		renvoie = ""
		renvoie = renvoie + controleEtatHaut
		renvoie
	end

	def presenceOranges
		@interface.traitementOptiques
		capteurs = @interface.optiques
		retour = ""
		if capteurs[1]==0 && capteurs[3]==0
			retour = retour + "Rien à gauche\n"
		else
			if capteurs[1]==1 && capteurs[3]==0
				retour = retour + "Une orange à gauche\n"
			else
				retour = retour + "Deux oranges à gauche\n"
			end
		end
		if capteurs[2]==0 && capteurs[4]==0
			retour = retour + "Rien à droite\n"
		else
			if capteurs[2]==1 && capteurs[4]==0
				retour = retour + "Une orange à droite\n"
			else
				retour = retour + "Deux oranges à droite\n"
			end
		end
		retour
	end

	def placeSurRailGauche
		@interface.traitementOptiques
		capteurs = @interface.optiques
		retour = 2
		if capteurs[1]==0 && capteurs[3]==0
			retour = retour#hahahahaha
		else
			if capteurs[1]==1 && capteurs[3]==0
				retour = retour - 1
			else
				retour = retour - 2
			end
		end
		retour
	end

	def placeSurRailDroit
		@interface.traitementOptiques
		capteurs = @interface.optiques
		retour = 2
		if capteurs[2]==0 && capteurs[4]==0
			retour = retour 
		else
			if capteurs[2]==1 && capteurs[4]==0
				retour = retour - 1
			else
				retour = retour - 2
			end
		end
		retour
	end

	def nombrePlaceSurRails
		retour = placeSurRailGauche + placeSurRailDroit
		retour
	end

	def nombreOranges
		@interface.traitementOptiques
		capteurs = @interface.optiques
		retour=capteurs[0]+capteurs[1]+capteurs[2]+capteurs[3]+capteurs[4]
		retour
	end

end
