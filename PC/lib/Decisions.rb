require "Log"

require "Vecteur"
require "Position"

# Attention : 
# Prend la stratégie la plus proche en position et possible niveau timing et carte
# Aucune autre optimisation
# 
# TODO :
# Unicité des stratégies
# Prendre en compte le ratio temps passé/points
# Trier les stratégies par points rapportés

class Decisions

        def initialize
                @log = Logger.instance

                @strategies = []

                @robot = nil
                @carte = nil
        end

        attr_accessor :tempsRestant

        def tempsRestant
                @robot.tempsRestant
        end

        def position
                @robot.position
        end


        def donnerRessources robot, carte
                @robot = robot
                @carte = carte
        end

        def chargeRepertoire(chemin)
                raise "Pas d'éléments de jeu pour la prise de décisions" if @robot == nil || @carte == nil
                @log.debug("Chargement des stratégies de " + chemin)
                Dir.entries(chemin).each { |f|
                        if f.include? ".rb"
                                require chemin + f.to_s if f.include? ".rb"
                                charge Kernel.const_get(f.sub(".rb", "")).new
                        end
                }
                @log.debug("Stratégies chargées")
        end

        def charge s
                @log.debug("    " + s.class.to_s)
                s.donnerRessources(@robot, @carte)
                @strategies += [s]
        end

        def viderStrategies
                @strategies = []
        end

        def nombreStrategies
                @strategies.size
        end

        def meilleurChoix
                meilleureStrategie = nil
                distance = -1
                ratio = -1

                @strategies.each { |s| 
                        if s.condition
                                d = Vecteur.new(position, s.depart).norme
                                if s.temps <= tempsRestant && (distance == -1 ||  d < distance)
                                        meilleureStrategie = s
                                        distance = d
                                end
                        end
                }

                # meilleureStrategie = @strategies.first

                @log.debug("Meilleure stratégie : " + meilleureStrategie.class.to_s)

                meilleureStrategie
        end

end
