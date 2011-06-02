# Gestion des actionneurs
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Log"

require "InterfaceActionneurs"

# Cette classe contient les fonctions permettant de gérer les actionneurs

class Actionneurs
	
	# Initialise l'asservissement à partir d'un périphérique série
	def initialize peripherique
		@log = Logger.instance
		
		if peripherique == nil
			raise "Pas de carte pour Actionneurs" 
		end
		
		@log.debug "Actionneurs sur " + peripherique
		
		@interface = InterfaceActionneurs.new peripherique
	end
	
	# Démarre le service
	def demarrer
	end
	
	# Arrête le service
	def arreter
		stopRouleau
		stopSelecteur
	        @interface.stopUrgence
	end
	
	# Reset le service
	def reset
	
	end
	
	# Allume la led du jumper
	def allumerLed
	        @interface.allumerLed
	end
	
	# Retourne l'état du jumper, prise jack
	def etatJumper
		@interface.etatJumper
	end
		
	# Vide les oranges en baissant la fourche
	def baisseFourche
		@interface.baisseFourche
	end
	
	# Attrape les oranges en relevant la fourche
	def leveFourche
		@interface.leveFourche
	end

	# Attrape les oranges en relevant la fourche
	def rangeFourche
		@interface.rangeFourche
	end
	
	def stopUrgence
                @interface.stopUrgence
	end
	
        def rouleauDirect
                @interface.rouleauDirect
        end
        
        def rouleauIndirect
		puts "Rouleau indirect"
                @interface.rouleauIndirect
        end
        
        def stopRouleau
                @interface.stopRouleau
        end
        
        def selecteurGauche
                @interface.selecteurGauche
        end
        
        def selecteurDroite
                @interface.selecteurDroite
        end

	def selecteurMilieu
		@interface.selecteurMilieu
	end

	def stopSelecteur
		@interface.stopSelecteur
	end

end
