# Gestion de l'asservissement en x, y
# ie les stratégies.
# Author::    Guillaume Rose  (mailto:guillaume.rose@gmail.com)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Float"
require "Fixnum"

require "Log"

require "Point"
require "Vecteur"

require "InterfaceAsservissement"

# Cette classe gère l'asservissement

class Asservissement

  # Précision du goTo : cercle à partir duquel on n'envoit plus de 
  # nouvelle consigne
  attr_accessor :precisionSimple,:sens

  # Précision du goTo : cercle à partir duquel on déblocage le déroulement
  # de la stratégie
  attr_accessor :precisionDouble

  # Initialise l'asservissement à partir d'un périphérique série, valeurs 
  # par défaut pour la précision
  def initialize peripherique, positionParDefaut = Position.new(0, 0, 0)
    @log = Logger.instance

    if peripherique == nil
      raise "Pas de carte pour Asservissement" 
    end

    @log.debug "Asservissement sur " + peripherique

    @precisionSimple = 50
    @precisionDouble = 20

    @drapeauArret = false

    @interface = InterfaceAsservissement.new peripherique, 57600, positionParDefaut
    @interface.demarrer

    #@interface.conversionTicksDistance = 9.50
    #@interface.conversionTicksAngle = 1530,9

    @interface.changerVitesse([3000, 3000])
    # @interface.changerAcceleration([10, 10])
    @interface.changerPWM([2000, 2046])
    # @interface.changerKp([0, 0])
    # @interface.changerKd([0, 0])

    @log.debug "Asservissement prêt"
    @sens = 1
  end

  # Position du robot
  def position
    @interface.position
  end

  # Reset l'Arduino et active l'odométrie
  def demarrer
    @log.debug "Activation de l'odométrie"
    @interface.activeOdometrie
  end

  # Arrête le robot
  def arreter
    @log.debug "Arrêt de l'asservissement"
    @interface.stopUrgence

    @log.debug "Désactivation de l'odométrie"
    @interface.desactiveOdometrie
  end

  # Reset l'odométrie, des consignes et des codeuses sur l'arduino
  def reset
    @interface.reset
  end

  # Remise à zéro de l'arduino, changement de la position du robot
  def remiseAZero nouvellePosition = Position.new(0, 0, 0)
    @log.debug "Remise à zéro des consignes et des codeuses"
    @interface.remiseAZero nouvellePosition
  end

  # Se déplace en absolu à la destination indiquée
  def goToEx destination, *condition
    begin
      @drapeauArret = false

      evaluationConditionArret(*condition)

      # Zone 51 ...
      v = Vecteur.new(position, destination)
      if v.norme < 500
        corrigeTrajectoire destination, :angulaire
      end

      corrigeTrajectoire destination	               

      i = 0
      @interface.changerPWM([2046,2046])
      while i < 200 && (distance = Vecteur.new(position, destination).norme) >= @precisionDouble
        # En cas de stop, on arrête de corriger la position
        # On sort alors du goTo
        evaluationConditionArret(*condition)

        if distance >= @precisionSimple
          corrigeTrajectoire destination
        end

        i += 1
        sleep 0.05
      end

      if i >= 200
        @log.debug "Problème pour atteindre la destination (timeout)"
        raise "timeout"
      end

      # tourneDe(destination.angle - position.angle, *condition)

      @log.debug "Fin Aller à : " + position.x.to_s + ", " + position.y.to_s

      return true
    rescue  RuntimeError => e
      puts "gotoEx"
      puts e
      if e.to_s.include? "blocageTrans"
        @log.debug "BlocageTrans"
        stopUrgence
        puts "stop urgence"
      end
      if e.to_s == "stop"
        @log.debug "Arret demandé"
        arret
      end
      if e.to_s == "timeout"
        @log.debug "Timeout"
      end
      raise e
    end
    true
  end

  def goTo *param
    begin
      goToEx *param
    rescue
      return false
    end
    true
  end

  def avancer distance
    @interface.changerPWM([2046,2046])
    puts "avancer",distance
    @interface.envoiConsigneDistance(distance)

  end

  def tourner angle
    @interface.changerPWM([3000,500])
    puts "tourner",angle
    @interface.envoiConsigneAngle(angle)

  end

  def returnPoint(debut,position,sens)
    vd = Vecteur.new(position,debut )
    vd = vd.normalise
    v = vd * 150
    o = vd.ortho	
    if sens == 0
      o = o * -1
    end
    o = o * 40
    vr = sum(v, o)
    npos = Position.new(position.x + vr.x,position.y + vr.y)
    return npos
  end

  def goToDep destination, *condition
    puts "goToDep"
    depart = position.clone
    begin
      goToEx destination, :blocageTranslation, *condition
    rescue  RuntimeError => e
      puts "goToDep",e
      @interface.changerPWM([1023,200])

      puts "reaction stop urgence"
      distRec = 150
      distRot = 0.2
      if e.to_s == "blocageTransAVG"
        @log.debug "Blocage AVG"
        #pos = position
        #npos = returnPoint(depart,pos,1)
        #puts "rescuePoint"
        #pos.prettyprint				
        #npos.prettyprint
        tourner distRot
        sleep 0.5	
        @interface.changerPWM([1023,1023])			
        avancer -distRec
        sleep 1
        #goTo npos, :bypass

      elsif e.to_s == "blocageTransAVD"
        @log.debug "Blocage AVD"
        tourner -distRot
        sleep 0.5	
        @interface.changerPWM([1023,1023])			
        avancer -distRec
        sleep 1

      elsif e.to_s == "blocageTransARG"
        @log.debug "Blocage ARG"
        tourner -distRot
        sleep 0.5
        @interface.changerPWM([1023,1023])				
        avancer distRec
        sleep 1

      elsif e.to_s == "blocageTransARD"
        @log.debug "Blocage ARD"
        tourner distRot
        sleep 0.5	
        @interface.changerPWM([1023,1023])			
        avancer distRec
        sleep 1
        #goTo npos, :bypass
      elsif e.to_s == "stop"
        @interface.changerPWM([1023,1023])
        return true
      end
      @interface.changerPWM([1023,1023])
      return false
    end
    return true
  end


  # Corrige la trajectoire pour atteindre la destination
  def corrigeTrajectoire destination, *condition
    v = Vecteur.new(position, destination)

    angleAFaire = (v.angle - position.angle).modulo2

    if (angleAFaire > Math::PI / 2) || (angleAFaire < -Math::PI / 2)
      consigneDistance = -1 * v.norme
      if consigneDistance > 0 
        @sens = 1
      else 
        @sens = -1
      end

      if (angleAFaire - Math::PI - position.angle).abs > Math::PI
        consigneAngle = (angleAFaire + Math::PI ).modulo2
      else
        consigneAngle = (angleAFaire - Math::PI).modulo2 
      end 
    else
      consigneDistance = v.norme
      consigneAngle = angleAFaire
    end

    if condition.empty?
      @interface.envoiConsigne consigneDistance, consigneAngle
    else
      tourneDe consigneAngle
    end
  end

  def evaluationConditionArret *item
    if !item.include?(:bypass)
      if item.empty?
        item = [:blocageTranslation]
      end
      raise "stop" if @drapeauArret == true
      item.each { |f|  
        send(f)
      }
    end
  end

  # Tourne relativement à la position du robot
  def tourneDe angleDonne
    @interface.changerPWM([3000, 700])
    @drapeauArret = false

    positionInitiale = position.angle

    evaluationConditionArret(:blocageRotation)

    @interface.envoiConsigneAngle angleDonne	               

    i = 0
    while i < 180 && (position.angle - positionInitiale - angleDonne).abs >= 0.05
      evaluationConditionArret(:blocageRotation)

      i += 1
      sleep 0.05
    end

    if i >= 180
      @log.debug "Problème pour atteindre la rotation (timeout)"
      raise "timeout"
    end

    @log.debug "Rotation finie"

    true
  end


  # Désactive l'asservissement
  def desactiveAsservissement
    @interface.desactiveAsservissementTranslation
    @interface.desactiveAsservissementRotation
  end

  # Désactive l'asservissement en translation
  def desactiveAsservissementTranslation
    @interface.desactiveAsservissementTranslation
  end

  # Désactive l'asservissement en rotation	
  def desactiveAsservissementRotation
    @interface.desactiveAsservissementRotation
  end

  # Renvoi l'état des codeuses
  def codeuses
    @interface.codeuses
  end

  def blocageTranslation
    raise "blocageTransAVD" if @interface.blocageTranslation == -1 #and @sens == 1
    raise "blocageTransAVG" if @interface.blocageTranslation == -2 #and @sens == 1
    raise "blocageTransARD" if @interface.blocageTranslation == 1 #and @sens == -1
    raise "blocageTransARG" if @interface.blocageTranslation == 2 #and @sens == -1
  end

  def blocageRotation
    raise "blocageROT" if @interface.blocageRotation != 0
  end

  def blocage
    blocageTranslation
    blocageRotation
  end


  def recalage
    @interface.changerVitesse([1300, 500])
    remiseAZero Position.new(310, 310, Math::PI/2)
    @interface.changerPWM([700, 2046])
    goTo Position.new(310, -2500, Math::PI/2) , :blocageTranslation
    goTo Position.new(310, -2500, Math::PI/2), :blocageTranslation
    sleep 0.5		
    remiseAZero Position.new(position.x, 170, Math::PI/2+0.0085)
    sleep 0.5
    # return true
    @interface.changerPWM([2046, 2046])
    goTo Position.new(position.x, 310), :bypass
    sleep 0.5
    position.prettyprint		
    tourneDe -Math::PI/2 
    @interface.changerPWM([700, 2046]) 
    goTo Position.new(-2500, position.y, 0), :blocageTranslation
    goTo Position.new(-2500, position.y, 0), :blocageTranslation
    sleep 0.5
    remiseAZero Position.new(170, position.y, 0.0085)
    sleep 0.5
    # return true
    @interface.changerPWM([2046,2046])
    # sleep 1  
    goTo Position.new(310, position.y, 0), :bypass                
    position.prettyprint		
    #goTo Position.new(310, 310, 0), :bypass
    sleep 0.5
    alignement Math::PI
    @interface.changerVitesse([2000, 1000])
    sleep 1
    position.prettyprint
  end	

  def recalage3
    @interface.changerVitesse([1300, 500])
    remiseAZero Position.new(310, -310, -Math::PI/2)
    @interface.changerPWM([300, 1023])
    goTo Position.new(310, 2500, -Math::PI/2) , :blocageTranslation
    goTo Position.new(310, 2500, -Math::PI/2), :blocageTranslation
    sleep 0.5		
    remiseAZero Position.new(position.x, -170, -Math::PI/2+0.0085)
    sleep 0.5
    # return true
    @interface.changerPWM([1023, 1023])
    goTo Position.new(position.x, -310), :bypass
    sleep 0.5
    position.prettyprint		
    tourneDe Math::PI/2 
    @interface.changerPWM([300, 1023]) 
    goTo Position.new(-2500, position.y, 0), :blocageTranslation
    goTo Position.new(-2500, position.y, 0), :blocageTranslation
    sleep 0.5
    remiseAZero Position.new(170, position.y, 0.0085)
    sleep 0.5
    # return true
    @interface.changerPWM([1023, 1023])
    # sleep 1  
    goTo Position.new(310, position.y, 0), :bypass                
    position.prettyprint		
    #goTo Position.new(310, 310, 0), :bypass
    sleep 0.5
    alignement Math::PI
    @interface.changerVitesse([2000, 1000])



    # @interface.changerVitesse([1000, 1000])
    # 
    # @interface.changerPWM([300, 1023])
    # 
    # goTo Position.new(-400, 0, 0), :blocageTranslation
    # sleep 1
    # goTo Position.new(-400, 0, 0), :blocageTranslation
    # remiseAZero Position.new(170, 0, 0)
    # sleep 1
    # @interface.changerPWM([1023, 1023])
    # # sleep 1  
    # goTo Position.new(285, -position.y, -Math::PI/2), :bypass
    # tourneDe -Math::PI/2 
    # @interface.changerPWM([300, 1023])
    # goTo Position.new(300, 2500, -Math::PI/2), :blocageTranslation
    # sleep 1
    # goTo Position.new(300, 2500, -Math::PI/2), :blocageTranslation
    # remiseAZero Position.new(position.x, -170, -Math::PI/2)
    # # sleep 1
    # @interface.changerPWM([1023, 1023])
    # goTo Position.new(position.x, -300, -Math::PI/2), :bypass
    # goTo Position.new(300, -300, 0)
    # 
    # @interface.changerVitesse([2000, 1000])
  end

  def recalage2 direction, sens, coordonneeReset, avancementMax = 1500
    positionIntermediaire = position.clone

    if direction == :x
      # Alignement
      positionIntermediaire.angle = positionIntermediaire.angle - (positionIntermediaire.angle % 2 * Math::PI)

      if positionIntermediaire.angle > Math::PI 
        positionIntermediaire.angle -= 2 * Math::PI
      end

      positionIntermediaire.prettyprint

      goTo positionIntermediaire

      # Recule ou avance sans asservissement rotation
      @interface.changerVitesse([1000, 1000])
      @interface.changerPWM([300, 1024])

      if sens == :positif
        positionIntermediaire.x += avancementMax
      else
        positionIntermediaire.x -= avancementMax
      end

      positionIntermediaire.prettyprint  

      goTo positionIntermediaire, :blocageTranslation

      sleep 1

      # On se cale bien 
      puts goTo positionIntermediaire, :blocageTranslation

      # Reset
      remiseAZero Position.new(coordonneeReset, position.y, position.angle)
    else
      positionIntermediaire.angle = positionIntermediaire.angle - (positionIntermediaire.angle % 2 * Math::PI) + (Math::PI / 2)

      if positionIntermediaire.angle > Math::PI 
        positionIntermediaire.angle -= 2 * Math::PI
      end

      goTo positionIntermediaire

      @interface.changerVitesse([1000, 1000])
      @interface.changerPWM([300, 1024])

      if sens == :positif
        positionIntermediaire.y += avancementMax
      else
        positionIntermediaire.y -= avancementMax
      end

      goTo positionIntermediaire, :blocageTranslation

      sleep 1

      goTo positionIntermediaire, :blocageTranslation

      remiseAZero Position.new(position.x, coordonneeReset, position.angle)
    end

    @interface.changerVitesse([3000, 3000])
    @interface.changerPWM([1023, 1023])
  end

  def arret
    @interface.stop
  end


  # Arrêt progressif du robot
  def stop
    @drapeauArret = true
    @log.debug "Appel fonction stop"
    # @interface.stop
  end

  # Arrêt brutal du robot
  def stopUrgence
    # @drapeauArret = true
    @interface.stopUrgence
  end

  # Sens de déplacement du robot (1 ou 0)
  def sens
    if @interface.sens == 20
      return 1
    end
    if @interface.sens == -20
      return -1
    end
    return 0
  end

  def changerVitesse(rotation, translation)
    @interface.changerVitesse([rotation, translation])
  end


  def alignement angle
    tourneDe((angle - position.angle).modulo2)
  end

end
