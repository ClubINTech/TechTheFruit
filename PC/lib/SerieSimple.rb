# Ce fichier contient la classe Serie. Elle permet une communication simple avec
# le port série.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "serialport"

# Cette classe permet la communication avec le port série. 

class Serie
	
	# Initialisation à partir d'un périphérique et d'une vitesse de 
	# connexion
	def initialize(peripherique = "/dev/ttyUSB0", vitesse = 57600)
		port_str = peripherique
		baud_rate = vitesse
		data_bits = 8
		stop_bits = 1
		parity = SerialPort::NONE

		@sp = SerialPort.new(
			port_str, 
			baud_rate, 
			data_bits, 
			stop_bits, 
			parity
		)
	end
	
	# Ecrit directement sur le port série
	def ecrire action
		@sp.write action + "\r\n"
	end
	
	# Lit une ligne provenant de la liaison série
	def lire
		retour = ""
		begin
			if ((caractere = @sp.getc) != nil) 
				retour << caractere.chr
			end
		end while caractere != 10
		retour.split("\r\n").first
	end
	
	# Ecrit une commande cmd sur le périphérique et retourne les 
	# informations renvoyées par le périphérique.
	# Le processus est bloquant.
	def commande cmd
		self.ecrire cmd
		self.lire
	end
	
end
