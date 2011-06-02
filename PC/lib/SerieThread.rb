# Ce fichier contient la classe SerieThread. Elle permet la communication avec
# le port série.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "thread"

require "serialport"

# Cette classe permet la communication avec le port série. 

class SerieThread

	# Initialisation à partir d'un périphérique et d'une vitesse de 
	# connexion
	def initialize(peripherique = "/dev/ttyUSB0", vitesse = 57600)
		port_str = peripherique
		baud_rate = vitesse
		data_bits = 8
		stop_bits = 1
		parity = SerialPort::NONE

		@sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
	end
	
	# Ecrit directement sur le port série
	def ecrire action
		@sp.write action + "\r\n"
	end
	
	# Lance un thread d'écoute du port série. A chaque nouvelle ligne, le
	# retour est envoyé à la fonction callback pour l'analyse.
	def demarrer
		@thread = Thread.new {
			retour = ""
			caractere = ""
			while true
				caractere = @sp.getc
				if caractere != nil
					retour << caractere.chr
					if caractere == 10
						retour = retour.split("\r\n").first
						callback retour
						retour = ""
					end
				end
			end
		}
	end
	
	# Fonction callback
	def callback retour
		puts retour
	end
	
	# Arrête le thread de lecture
	def arreter
		@thread.exit
	end
	
end
