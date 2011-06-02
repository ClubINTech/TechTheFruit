# Ce fichier rajoute à la carte les données propres à la table de jeu initiale
# Author::    Clément Bethuys  (mailto:clement.bethuys@laposte.net)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Carte"
require "Objets"

require "Log"

# C'est la carte de techthefruit, avec au départ les épis, les tomates et tout autre objets positionné comme à la coupe
class CarteTechTheFruit < Carte
        
	public
	
	# Initialise la carte en ajoutant à l'intérieur les tomates, les épis ...
	# Crée également le graphe correspondant à la CarteTechTheFruit pour pouvoir y faire des calculs de pathfinding
        def initialize
		super()
		@log.sev_threshold = Logger::WARN
		initTomates
		initEpis
		initNoeuds
		initArretes
		initNoeudsEtArretesFaibles
		initZonesDepart
		initPente
		@log.sev_threshold = Logger::DEBUG
		@log.info "initialisation de la carte terminée"
	end
        
	private

	# Ajoute toutes les tomates sur la carte
	def initTomates
		ajouterTomate(Point.new(150,972))
		ajouterTomate(Point.new(2850,972))
		ajouterTomate(Point.new(600,1222))
		ajouterTomate(Point.new(1500,1222))
		ajouterTomate(Point.new(2400,1222))
		ajouterTomate(Point.new(150,1472))
		ajouterTomate(Point.new(1050,1472))
		ajouterTomate(Point.new(1950,1472))
		ajouterTomate(Point.new(2850,1472))
		ajouterTomate(Point.new(600,1722))
		ajouterTomate(Point.new(1500,1722))
		ajouterTomate(Point.new(2400,1722))

		# on ne pourra jamais avoir ces tomates
		#ajouterTomate(Point.new(1050,1972))
		#ajouterTomate(Point.new(1950,1972))
	end

	# Ajoute tous les épis sur la carte
	def initEpis
		ajouterEpis(Point.new(150,722))
		ajouterEpis(Point.new(150,722))
		ajouterEpis(Point.new(2850,722))
		ajouterEpis(Point.new(600,972))
		ajouterEpis(Point.new(2400,972))
		ajouterEpis(Point.new(150,1222))
		ajouterEpis(Point.new(1050,1222))
		ajouterEpis(Point.new(1950,1222))
		ajouterEpis(Point.new(2850,1222))
		ajouterEpis(Point.new(600,1472))
		ajouterEpis(Point.new(1500,1472))
		ajouterEpis(Point.new(2400,1472))
		ajouterEpis(Point.new(150,1722))
		ajouterEpis(Point.new(1050,1722))
		ajouterEpis(Point.new(1950,1722))
		ajouterEpis(Point.new(2850,1722))
		ajouterEpis(Point.new(600,1972))
		ajouterEpis(Point.new(1500,1972))
		ajouterEpis(Point.new(2400,1972))
	end

	# Défini les noeuds de la carte, leur numéro, position ainsi que leur étendus spaciale
	def initNoeuds
		procedure= []

		procedure[0]=proc { |position| x=position.x 
		y=position.y
		return (y<=722 and y<=f(x,150,722,670,522) and x<=670)}
		procedure[1]=proc { |position| x=position.x
		y=position.y
		return (x>670 and x<=1270 and y<=500)}
		procedure[2]=proc { |position| x=position.x
		y=position.y
		return (x>1730 and x<=2330 and y<=500)}
		procedure[3]=proc { |position| x=position.x
		y=position.y
		return (x>2330 and y<=f(x,2330,522,2850,722) and y<=722)}
		procedure[4]=proc { |position| x=position.x
		y=position.y
		return (y>f(x,150,722,670,522) and y>522 and y<=f(x,150,722,600,972) and y<=972 and x<=1050)}
		procedure[5]=proc { |position| x=position.x
		y=position.y
		return (x>1050 and x<=1950 and y>522 and y<=972)}
		procedure[6]=proc { |position| x=position.x
		y=position.y
		return (y<=f(x,2400,972,2850,722) and y<=972 and y>f(x,2850,722,2330,522) and y>522 and x>1950)}
		procedure[7]=proc { |position| x=position.x
		y=position.y
		return (y>722 and y<=1222 and y>f(x,150,722,600,972) and y<=f(x,600,972,150,1222))}
		procedure[8]=proc { |position| x=position.x
		y=position.y
		return (y>f(x,150,1222,600,972) and y>f(x,600,972,1050,1222) and y<=f(x,1050,1222,600,1472) and y<=f(x,600,1472,150,1222))}
		procedure[9]=proc { |position| x=position.x
		y=position.y
		return (y>972 and y<=f(x,600,972,1050,1222) and y<=f(x,1050,1222,1500,972))}
		procedure[10]=proc { |position| x=position.x
		y=position.y
		return (y<=f(x,1050,1222,1500,1472) and y<=f(x,1500,1472,1950,1222) and y>f(x,1950,1222,1500,972) and y>f(x,1500,972,1050,1222))}
		procedure[11]=proc { |position| x=position.x
		y=position.y
		return (y>972 and y<=f(x,1500,972,1950,1222) and y<=f(x,1950,1222,2400,972))}
		procedure[12]=proc { |position| x=position.x
		y=position.y
		return (y>f(x,1950,1222,2400,972) and y>f(x,2400,972,2850,1222) and y<=f(x,2850,1222,2400,1472) and y<=f(x,2400,1472,1950,1222))}
		procedure[13]=proc { |position| x=position.x
		y=position.y
		return (y>722 and y<=1222 and y>f(x,2850,722,2400,972) and y<=f(x,2400,972,2850,1222))}
		procedure[14]=proc { |position| x=position.x
		y=position.y
		return (y>1222 and y<=1722 and y>f(x,150,1222,600,1472) and y<=f(x,600,1472,150,1722))}
		procedure[15]=proc { |position| x=position.x
		y=position.y
		return (y>f(x,150,1722,600,1472) and y>f(x,600,1472,1050,1722) and y<=f(x,1050,1722,600,1972) and y<=f(x,600,1972,150,1722))}
		procedure[16]=proc { |position| x=position.x
		y=position.y
		return (y>f(x,600,1472,1050,1222) and y>f(x,1050,1222,1500,1472) and y<=f(x,1500,1472,1050,1722) and y<=f(x,1050,1722,600,1472))}
		procedure[17]=proc { |position| x=position.x
		y=position.y
		return (y>f(x,1050,1722,1500,1472) and y>f(x,1500,1472,1950,1722) and y<=f(x,1950,1722,1500,1972) and y<=f(x,1500,1972,1050,1722))}
		procedure[18]=proc { |position| x=position.x
		y=position.y
		return (y>f(x,1500,1472,1950,1222) and y>f(x,1950,1222,2400,1472) and y<=f(x,2400,1472,1950,1722) and y<=f(x,1950,1722,1500,1472))}
		procedure[19]=proc { |position| x=position.x 
		y=position.y
		return (y>f(x,1950,1722,2400,1472) and y>f(x,2400,1472,2850,1722) and y<=f(x,2850,1722,2400,1972) and y<=f(x,2400,1972,1950,1722))}
		procedure[20]=proc { |position| x=position.x
		y=position.y
		return (y>1222 and y<=1722 and y>f(x,2850,1222,2400,1472) and y<=f(x,2400,1472,2850,1722))}
		procedure[21]=proc { |position| x=position.x
		y=position.y
		return (y>1722 and x<=600 and y>f(x,150,1722,600,1972))}
		procedure[22]=proc { |position| x=position.x
		y=position.y
		return (x>600 and x<=1972 and y>f(x,600,1972,1050,1722) and y>f(x,1050,1722,1500,1972))}
		procedure[23]=proc { |position| x=position.x
		y=position.y
		return (x>1500 and x<=2400 and y>f(x,1500,1972,1950,1722) and y>f(x,1950,1722,2400,1972))}
		procedure[24]=proc { |position| x=position.x
		y=position.y
		return (x>2400 and y>1722 and y>f(x,2400,1972,2850,1722))}

		@listePosition=[]

		@listePosition[0]=Point.new(375,375)
		@listePosition[1]=Point.new(1000,250)
		@listePosition[2]=Point.new(2000,250)
		@listePosition[3]=Point.new(2625,375)
		@listePosition[4]=Point.new(600,722)
		@listePosition[5]=Point.new(1500,772)
		@listePosition[6]=Point.new(2400,722)
		@listePosition[7]=Point.new(350,972)
		@listePosition[8]=Point.new(600,1222)
		@listePosition[9]=Point.new(1050,972)
		@listePosition[10]=Point.new(1500,1222)
		@listePosition[11]=Point.new(1950,972)
		@listePosition[12]=Point.new(2400,1222)
		@listePosition[13]=Point.new(2650,972)
		@listePosition[14]=Point.new(350,1472)
		@listePosition[15]=Point.new(600,1722)
		@listePosition[16]=Point.new(1050,1472)
		@listePosition[17]=Point.new(1500,1722)
		@listePosition[18]=Point.new(1950,1472)
		@listePosition[19]=Point.new(2400,1722)
		@listePosition[20]=Point.new(2650,1472)
		@listePosition[21]=Point.new(300,1889)
		@listePosition[22]=Point.new(1050,1972)
		@listePosition[23]=Point.new(1950,1972)
		@listePosition[24]=Point.new(2700,1889)


		for i in (0 .. 24)
			ajouterNoeud(i,@listePosition[i],procedure[i])
		end
	end

	# Défini les noeuds ponctuels de la carte, leur numéro, position. Ils représentent des raccourcis dans la carte
	def initNoeudsEtArretesFaibles

		ajouterNoeud(59,Point.new(375,1847),proc{return false})
		ajouterArrete(59,21)
		ajouterArrete(59,15)
		ajouterNoeud(60,Point.new(2625,1847),proc{return false})
		ajouterArrete(60,24)
		ajouterArrete(60,19)

		ajouterNoeudFaibleEtLiaison(25,4,7,Point.new(375,847))
		ajouterNoeudFaibleEtLiaison(26,7,8,Point.new(375,1097))
		ajouterNoeudFaibleEtLiaison(27,8,14,Point.new(375,1347))
		ajouterNoeudFaibleEtLiaison(28,14,15,Point.new(375,1597))
		ajouterArrete(0,25)
		ajouterArrete(25,26)
		ajouterArrete(26,27)
		ajouterArrete(27,28)
		ajouterArrete(28,59)

		ajouterNoeudFaibleEtLiaison(29,4,9,Point.new(825,847))
		ajouterNoeudFaibleEtLiaison(30,9,8)
		ajouterNoeudFaibleEtLiaison(31,8,16)
		ajouterNoeudFaibleEtLiaison(32,16,15)
		ajouterNoeudFaibleEtLiaison(33,15,22)

		# on est trop gros pour passer
		enleverArrete(33,22)

		ajouterArrete(29,30)
		ajouterArrete(30,31)
		ajouterArrete(31,32)
		ajouterArrete(32,33)

		ajouterNoeudFaibleEtLiaison(34,5,9,Point.new(1275,847))
		ajouterNoeudFaibleEtLiaison(35,9,10)
		ajouterNoeudFaibleEtLiaison(36,10,16)
		ajouterNoeudFaibleEtLiaison(37,16,17)
		ajouterNoeudFaibleEtLiaison(38,17,22)

		# on est trop gros pour passer
		enleverArrete(38,22)

		ajouterArrete(34,35)
		ajouterArrete(35,36)
		ajouterArrete(36,37)
		ajouterArrete(37,38)
	
		ajouterNoeudFaibleEtLiaison(39,5,11,Point.new(1725,847))
		ajouterNoeudFaibleEtLiaison(40,11,10)
		ajouterNoeudFaibleEtLiaison(41,10,18)
		ajouterNoeudFaibleEtLiaison(42,18,17)
		ajouterNoeudFaibleEtLiaison(43,17,23)

		# on est trop gros pour passer
		enleverArrete(43,23)

		ajouterArrete(39,40)
		ajouterArrete(40,41)
		ajouterArrete(41,42)
		ajouterArrete(42,43)

		ajouterNoeudFaibleEtLiaison(44,6,11,Point.new(2175,847))
		ajouterNoeudFaibleEtLiaison(45,11,12)
		ajouterNoeudFaibleEtLiaison(46,12,18)
		ajouterNoeudFaibleEtLiaison(47,18,19)
		ajouterNoeudFaibleEtLiaison(48,19,23)

		# on est trop gros pour passer
		enleverArrete(48,23)

		ajouterArrete(44,45)
		ajouterArrete(45,46)
		ajouterArrete(46,47)
		ajouterArrete(47,48)

		ajouterNoeudFaibleEtLiaison(49,6,13,Point.new(2625,847))
		ajouterNoeudFaibleEtLiaison(50,13,12,Point.new(2625,1097))
		ajouterNoeudFaibleEtLiaison(51,12,20,Point.new(2625,1347))
		ajouterNoeudFaibleEtLiaison(52,20,19,Point.new(2625,1597))
		ajouterArrete(3,49)
		ajouterArrete(49,50)
		ajouterArrete(50,51)
		ajouterArrete(51,52)
		ajouterArrete(52,60)

		ajouterNoeudFaibleEtLiaison(53,0,1)
		ajouterNoeudFaibleEtLiaison(54,0,4)
		ajouterNoeudFaibleEtLiaison(55,4,5)
		ajouterNoeudFaibleEtLiaison(56,5,6)
		ajouterNoeudFaibleEtLiaison(57,6,3)
		ajouterNoeudFaibleEtLiaison(58,3,2)
	end

	# permet d'ajouter un noeud poncuel et les laisons avec les vrai noeuds qui l'on définie
	def ajouterNoeudFaibleEtLiaison(son_num,num1,num2,*pos)
		if(!pos.empty?)
			milieu=pos.first
		else
			milieu=(@listePosition[num1]+ @listePosition[num2])/2
		end
		ajouterNoeud(son_num,milieu,proc {return false})
		ajouterArrete(son_num,num1)
		ajouterArrete(son_num,num2)
	end

	# Renseigne avec quels sont les autres noeuds est en contact le noeud d'ID "numero"
	# regarder si c'est interessant de garder
	def initArretes
		ajouterArrete(4,9)
		modifierArrete(4,9,-20)
		ajouterArrete(5,9)
		modifierArrete(5,9,-20)
		ajouterArrete(5,11)
		modifierArrete(5,11,-20)
		ajouterArrete(6,11)
		modifierArrete(6,11,-20)
	end

	# Rajoute les zones de départ bleu et jaune à la carte
	def initZonesDepart
		@liste_zones_depart[0]= Zone_Depart.new(Point.new(0,0),Point.new(500,500),"bleu")
		@liste_zones_depart[1]= Zone_Depart.new(Point.new(2500,0),Point.new(500,500),"jaune")
	end

	# Rajoute la pente à la carte
	def initPente
		@liste_pente[0]=Pente.new(Point.new(770,0),Point.new(2230,500))
	end
end
