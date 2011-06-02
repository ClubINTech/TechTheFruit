# Ce fichier contient la classe d'interfaçage des actionneurs.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "SerieSimple"

# Cette classe hérite des fonctions basiques de gestion d'une liaison série.

class InterfaceActionneurs < Serie

  # Initialise avec un périphérique à une certaine vitesse
  def initialize(peripherique = "/dev/ttyUSB0", vitesse = 57600)
    super(peripherique, vitesse)
  end

  # Allume la led du jumper
  def allumerLed
    commande "b"
  end

  # Retourne l'état de l'interrupteur jack déclenchant le lancement du 
  # robot
  def etatJumper
    commande("a").to_i
  end

  # Envoi la commande pour lever la fourche
  def leveFourche
    commande "e"
  end

  # Envoi la commande pour baisser la fourche
  def baisseFourche
    commande "f"
  end

  # Envoi la commande pour rentrer complètement la fourche
  def rangeFourche
    commande "d"
  end

  def stopUrgence
    commande "c"
  end

  def rouleauDirect
    commande "g"
  end

  def rouleauIndirect
    commande "h"
  end

  def stopRouleau
    commande "i"
  end

  def selecteurGauche
    commande "j"
  end

  def selecteurDroite
    commande "k"
  end

  def selecteurMilieu
    commande "p"
  end

  def stopSelecteur
    commande "o"
  end

end
