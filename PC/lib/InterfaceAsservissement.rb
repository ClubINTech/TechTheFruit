# Ce fichier contient la classe d'interfaçage de l'asservissement. Elle permet 
# une communication avec l'Arduino d'asservissement.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "SerieThread"
require "Log"

require "Position"

# Cette classe convertit les consignes en commandes en ticks. Elle hérite des
# fonctions permettant la liaison série.
#--
#  * Ajouter des mutex entre callback et l'envoi de position (problème de timing possible)
#++

class InterfaceAsservissement < SerieThread

  # Contient la position du robot à chaque instant
  attr_accessor :position, :sens

  # Constantes permettant la conversion en coordonnées polaires et 
  # cartésiennes
  attr_accessor :conversionTicksDistance, :conversionTicksAngle

  attr_reader :PWM, :Vitesse

  # * Initialise la liaison série avec un périphérique à une vitesse donnée
  # * Définit les valeurs par défaut aux constantes
  def initialize(peripherique = "/dev/ttyUSB0", vitesse = 57600, positionParDefaut = Position.new(0, 0, 0))
    super(peripherique, vitesse)

    @log = Logger.instance

    @position = positionParDefaut
    @sens = 1

    @conversionTicksDistance = (9.6769 * 1)
    @conversionTicksAngle = 1528.735

    @offsetAngulaire = positionParDefaut.angle
    @offsetG = @conversionTicksAngle * positionParDefaut.angle / 2
    @offsetD = -1 * @offsetG

    @encodeurPrecedentG = @offsetG
    @encodeurPrecedentD = @offsetD

    @blocageTranslation = 0
    @blocageRotation = 0

    @skip = false

    @commandeAngle = ""
    @commandeDistance = ""

    @vecteurDeplacement = Vecteur.new

    @PWM = [1023, 1023]
    @Vitesse = [3000, 3000]
  end

  # Surcharge de la fonction callback héritée de SerieThread afin de 
  # calculer à chaque nouvelle réception de données la nouvelle position
  # du robot.
  def callback retour
    if @skip
      donnees = retour.split(" ")
      @skip = false if donnees[0].to_i.abs <= 10 && donnees[1].to_i.abs <= 10
    else
      donnees = retour.split(" ")

      return false if donnees.size != 4

      encodeurG = @offsetG + -1 * (donnees[0].to_i)
      encodeurD = @offsetD + 1  * (donnees[1].to_i)

      @blocageTranslation = donnees[3].to_i
      @blocageRotation = donnees[2].to_i

      distance = (encodeurG - @encodeurPrecedentG + encodeurD - @encodeurPrecedentD) / @conversionTicksDistance

      return false if distance > 1000

      anciennePosition = @position.clone

      @position.x += distance * Math.cos(@position.angle)
      @position.y += distance * Math.sin(@position.angle)

      ancienVecteurDeplacement = @vecteurDeplacement
      # puts @vecteurDeplacement.inspect
      @vecteurDeplacement = Vecteur.new(anciennePosition, @position)

      v = Vecteur.new
      v.x = Math.cos(@position.angle)
      v.y = Math.sin(@position.angle)

      signe = v.produitScalaire(@vecteurDeplacement)
      if signe >= 0
        @sens += 1 if @sens < 20
      else
        @sens -= 1 if @sens > -20
      end

      # puts @sens

      @position.angle = (encodeurG - encodeurD) / (@conversionTicksAngle)

      # puts donnees.inspect
      #puts @position.inspect

      @encodeurPrecedentG = encodeurG
      @encodeurPrecedentD = encodeurD
      # @log.debug "Réception codeuses : " + donnees.inspect
    end
  end

  # Envoi d'une consigne en distance et en angle au robot relatif par
  # rapport à sa position courante
  def envoiConsigne distance, angle		
    a = ((angle - @offsetAngulaire) * @conversionTicksAngle + @encodeurPrecedentG - @encodeurPrecedentD).to_i
    d = (distance * @conversionTicksDistance + @encodeurPrecedentG + @encodeurPrecedentD).to_i

    distanceFormate, angleFormate, commandeDistance, commandeAngle = formatageConsigne d, a

    # if @commandeAngle != commandeAngle + angleFormate
    ecrire commandeAngle + angleFormate
    @commandeAngle = commandeAngle + angleFormate
    # end
    # if @commandeDistance != commandeDistance + distanceFormate
    ecrire commandeDistance + distanceFormate
    @commandeDistance = commandeDistance + distanceFormate
    # end
  end

  # Envoi d'une consigne en distance et en angle absolue
  def envoiConsigneBrute distance, angle
    distanceFormate, angleFormate, commandeDistance, commandeAngle = formatageConsigne distance, angle

    # if @commandeAngle != commandeAngle + angleFormate
    ecrire commandeAngle + angleFormate
    @commandeAngle = commandeAngle + angleFormate
    # end
    # if @commandeDistance != commandeDistance + distanceFormate
    ecrire commandeDistance + distanceFormate
    @commandeDistance = commandeDistance + distanceFormate
    # end
  end

  # Envoi d'une consigne en angle
  def envoiConsigneAngle angle
    a = ((angle - @offsetAngulaire) * @conversionTicksAngle + @encodeurPrecedentG - @encodeurPrecedentD).to_i
    distanceFormate, angleFormate, commandeDistance, commandeAngle = formatageConsigne 0, a

    # if @commandeAngle != commandeAngle + angleFormate
    ecrire commandeAngle + angleFormate
    @commandeAngle = commandeAngle + angleFormate
    # end
  end

  # Envoi d'une consigne en distance
  def envoiConsigneDistance distance
    d = (distance * @conversionTicksDistance + @encodeurPrecedentG + @encodeurPrecedentD).to_i
    distanceFormate, angleFormate, commandeDistance, commandeAngle = formatageConsigne d, 0

    # if @commandeDistance != commandeDistance + distanceFormate
    ecrire commandeDistance + distanceFormate
    @commandeDistance = commandeDistance + distanceFormate
    # end
  end

  # Demande au robot d'activer l'envoi des données de roues codeuses sur
  # la liaison série
  def activeOdometrie
    ecrire "c"
  end

  # Désactive l'envoi de données
  def desactiveOdometrie
    ecrire "d"
  end

  # Bascule l'état de l'asservissement d'un état vers un autre 
  # (tout ou rien)
  def desactiveAsservissementRotation
    ecrire "h"
  end

  def desactiveAsservissementTranslation
    ecrire "i"
  end

  def desactiveAsservissement
    ecrire "h"
    ecrire "i"
  end

  # Reset du périphérique
  # * Désactivation de l'odométrie
  # * Remise à zéro des consignes et des codeuses
  def reset
    desactiveOdometrie
    ecrire "j"
  end

  # Remise à zéro des codeuses et de la consigne
  def remiseAZero nouvellePosition
    ecrire "j"

    @skip = true

    @position = nouvellePosition

    @offsetAngulaire = nouvellePosition.angle
    @offsetG = (@conversionTicksAngle * nouvellePosition.angle / 2).to_i
    @offsetD = (-1 * @offsetG).to_i

    @encodeurPrecedentG = @offsetG.to_i
    @encodeurPrecedentD = @offsetD.to_i
  end

  # Formate les consignes afin de les transmettre
  def formatageConsigne distance, angle
    if angle > 0
      commandeAngle = "g"
    else
      commandeAngle = "b"
      angle *= -1
    end

    if distance > 0
      commandeDistance = "f"
    else
      commandeDistance = "a"
      distance *= -1
    end

    [distance.to_i.to_s.rjust(8, "0"), angle.to_i.to_s.rjust(8, "0"), commandeDistance, commandeAngle]
  end

  # Renvoi l'état des codeuses gauche et droite
  def codeuses
    [@encodeurPrecedentG, @encodeurPrecedentD]
  end

  # Renvoi l'état des asservissements
  def blocage
    [@blocageTranslation, @blocageRotation]
  end

  # Renvoi vrai si l'asservissement en translation est bloqué
  def blocageTranslation
    @blocageTranslation
  end

  # Renvoi vrai si l'asservissement en rotation est bloqué
  def blocageRotation
    @blocageRotation
  end

  # Arrêt progressif du robot
  def stop
    ecrire "n"
  end

  # Arrêt brutal du robot
  def stopUrgence
    ecrire "o"
  end

  # Change la vitesse du robot (rotation, translation)
  def changerVitesse(valeur)
    valeur = [0, 0] if valeur.size != 2
    ecrire "r" + valeur[0].to_s.rjust(8, "0")
    ecrire "l" + valeur[1].to_s.rjust(8, "0")
    @Vitesse = valeur
  end

  # Change l'accélération du robot (rotation, translation)
  def changerAcceleration(valeur)
    valeur = [0, 0] if valeur.size != 2
    ecrire "q" + valeur[0].to_s.rjust(8, "0")
    ecrire "k" + valeur[1].to_s.rjust(8, "0")
  end

  # Change la valeur du PWN (rotation, translation)
  def changerPWM(valeur)
    valeur = [0, 0] if valeur.size != 2
    ecrire "t" + valeur[0].to_s.rjust(8, "0")
    ecrire "p" + valeur[1].to_s.rjust(8, "0")
    @PWM = valeur
  end

  # Change la valeur de KP (rotation, translation)
  def changerKp(valeur)
    valeur = [0, 0] if valeur.size != 2
    ecrire "s" + valeur[0].to_s.rjust(8, "0")
    ecrire "m" + valeur[1].to_s.rjust(8, "0")
  end

  # Change la valeur de KP (rotation, translation)
  def changerKd(valeur)
    valeur = [0, 0] if valeur.size != 2
    ecrire "v" + valeur[0].to_s.rjust(8, "0")
    ecrire "u" + valeur[1].to_s.rjust(8, "0")
  end

end
