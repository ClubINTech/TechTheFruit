require "Log"

require "Robot"
require "Decisions"
require "CarteTechTheFruit"

class RobotMagique

        def initialize(positionInitiale, listeEvenements, repStrategie, couleur)
                @carte = CarteTechTheFruit.new               
                @robot = Robot.new(couleur, positionInitiale) 
                @robot.demarrer

                @couleur = couleur

                @evenements = listeEvenements.new(@robot, @carte)

                @decisions = Decisions.new
                @decisions.donnerRessources(@robot, @carte)
                @decisions.chargeRepertoire repStrategie
                
                @log = Logger.instance
        end

        def demarrer 
		#@robot.baisseFourche
                @robot.actionneursStopUrgence
                @robot.rangeFourche
                
                # Bleu : recalage3 et changer signe angle + y
                @robot.recalage
                
                @robot.attendreJumper

                @robot.demarrerTimer
                @evenements.demarrer

                while @robot.tempsRestant > 0
                        while @evenements.blocageStrategie != false
                                sleep 0.5
                        end
                        
                        strategie = @decisions.meilleurChoix
                        if strategie == nil
                                @log.info "Plus de stratégies"
                                break
                        end
                        
                        #strategieEnCours = Thread.new { 
                                strategie.sequence 
                        #}
                        
                        #@evenements.attacheStrategie(strategieEnCours)
                        
                        #strategieEnCours.join
                end

                @robot.arreterTimer

                @evenements.arreter
                @robot.arreter
        end

end
