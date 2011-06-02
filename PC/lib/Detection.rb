# Détection des périphériques
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Log"

require "SerieSimple"

# La classe Détection permet d'associer un Arduino à chaque service ie
# l'asservissement, les actionneurs et l'évitement

class Detection

	# Contient l'association service - périphérique série
	attr_reader :association
	
	# Contient l'association caractère renvoyé par ? - service
	attr_reader :identifiant
	
	# Lance l'association à partir d'un hash d'identification
	def initialize identifiant = { 0 => "BlocMoteur" }
		@log = Logger.instance
		
		@identifiant = identifiant
		self.associe
	end
	
	# Association des périphériques
	def associe
		@association = {}
		peripheriques = `ls -1 /dev/ttyUSB* 2> /dev/null`
		@log.debug "Association des périphériques"
		for p in peripheriques.split("\n")
		        @log.debug "Qui est " + p + " ?"
			liaisonSerie = Serie.new p
			retour = liaisonSerie.commande "?"
			@association[@identifiant[retour.to_i]] = p
		end
		@association
	end
	
	# Retourne le périphérique associé à un service
	def peripheriqueAssocie partie
		@association[partie]
	end
	
end
