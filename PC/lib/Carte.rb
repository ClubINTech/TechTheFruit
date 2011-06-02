# Ce fichier contient les fonctions qui permettent de modifier l'état de la carte
# et d'obtenir le chemin pour aller d'un point A à un point B
# Author::    Clément Bethuys  (mailto:clement.bethuys@laposte.net)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Dijkstra"
require "Point"
require "Vecteur"
require "Lissage"
require "Log"

# C'est l'aire de jeu, avec les fonctions pour la modifier et trouver son chemin dedans
# C'est une classe virtuelle, toujours appeler CarteTechTheFruit qui sa classe fille
class Carte
  
	public

	attr_accessor :listeObjets

	# Crée les structures permettant d'acceuillir les différents objets d'une classe fille
        def initialize
	 	@log = Logger.instance
		@liste=Array.new

		@liste_epis= Array.new
		@liste_tomates= Array.new
		@liste_zones_depart= Array.new
		@liste_pente= Array.new
		@liste_chemins= Array.new
		@listeObjets =[@liste_zones_depart,@liste_pente,@liste_epis,@liste_tomates,@liste_chemins]
		@graphe = Dijkstra.new
        end

	def goToPos(zoneA,zoneB,pas_intermediaire=true,lisser=false)
		goTo(@graphe.noeuds[zoneA],@graphe.noeuds[zoneB],pas_intermediaire=true,lisser=false)
	end

	# Renvoie le meilleur chemin non lissé pour aller de "posA" à "posB".
	# "posA" est la position de départ du robot et "posB" est la position d'arrivée
	def goTo(posA,posB,pas_intermediaire=true,lisser=false)
		@log.info "je vais de " + posA.inspect.to_s + " à " + posB.inspect.to_s
		zoneA=quelleZone(posA)
		zoneB=quelleZone(posB)
		if (zoneA==zoneB)
			@log.debug "on est dans la même zone"
			a=[posA,posB]
			if(onPeutPasCouper(posA,posB)) then a.insert(1,@graphe.noeuds[zoneA]) end
			@liste_chemins.push(Chemin.new(a))
			return a
		end	
		a=@graphe.chemin(zoneA,zoneB,pas_intermediaire)
		if(onPeutPasCouper(posA,a[0]))
			a.insert(0,@graphe.noeuds[zoneA])
		end
		a.insert(0,posA)
		if(onPeutPasCouper(posB,a[a.length-1]))
			a.push(@graphe.noeuds[zoneB])
		end
		a.push(posB)
		if(lisser)then a=Bspline.new(a).get
		else 
			if(@graphe.cosinus(Vecteur.new(a[0],a[1]),Vecteur.new(a[1],a[2]))>2)
			a-=[a[1]]
			end
			taille=a.length-1
			if(@graphe.cosinus(Vecteur.new(a[taille],a[taille-1]),Vecteur.new(a[taille-1],a[taille-2]))>2)
			a-=[a[taille-1]]
			end
		end 	
		#a-=[a.first]
		@liste_chemins.push(Chemin.new(a))
		return a
	end

	# Ajoute une tomate en à la position "position" si "securité"=true enlève toute autre tomate déjà présente dans un rayon "rayon"
        def ajouterTomate(position,securise=false,rayon=22)
		@log.info "j'ajoute une tomate"
		if(securise)
			enleverTomate(position,rayon)
		end
		@liste_tomates.push(Tomate.new(position))
        end
        
	# Enlève toute tomate à la position "position" présente dans un rayon "rayon"
	def enleverTomate(position,rayon=22)
		numTomate=numObjetLePlusProche(@liste_tomates,position,rayon)
		numTomate.each{ |num|
		@log.info "j'enlève une tomate"
		@liste_tomates.delete_at(num)
		}
	end
	
	# Ajoute une arrete entre deux noeuds déjà crées
        def ajouterArrete(noeudDepart,noeudArrivee)
		@graphe.ajoutArrete(noeudDepart,noeudArrivee)
        end

	# enlève une arrete entre deux noeuds
	def enleverArrete(noeudDepart,noeudArrivee)
		@graphe.suppArrete(noeudDepart,noeudArrivee)
        end
        
	# Ajoute un épis en à la position "position" si "securité"=true enlève tout autre épis déjà présent dans un rayon "rayon"
        def ajouterEpis(position, securise=false, rayon=22)
		@log.info "j'ajoute un épis"
		if(securise)
			enleverEpis(position,rayon)
		end
		@liste_epis.push(Epis.new(position))
        end
        
	# Enlève tout épis à la position "position" présente dans un rayon "rayon"
        def enleverEpis(position, rayon = 22)
		numEpis=numObjetLePlusProche(@liste_epis,position,rayon)
		numEpis.each{ |num|
		@log.info "j'enlève un épis"
		@liste_epis.delete_at(num)
		}
        end

	# Assigne la distance "distance" entre les zones "premier" et "second" 
	def modifierArrete(premier,second,difference,duree=false)
		@graphe.modifArrete(premier,second,difference,duree)
	end

	# Bloque toute entree dans la Zone ou "position" se trouve pour une durée "duree"
	def bloquerZone(position,duree)
		zone=quelleZone(position)
		if (!@liste.include?(zone))
		@liste.push(zone)
		@log.info "je bloque la zone numéro " + zone.to_s + " pour " + duree.to_s + " secondes"
		@graphe.arretes[zone].each_key{ |clef| modifierArrete(zone,clef,10000,duree)}

		if(zone<=24)
		@graphe.arretes[zone].each_key{ |clef| 
			if(clef>24 && clef!=5 && clef!=49) then @graphe.arretes[clef].each_key{ |arrete| modifierArrete(clef,arrete,10000,duree)} end
			}
		end
		Thread.new {
		sleep(duree)
		@liste.delete(zone)
		@log.info "j'ai débloque la zone " + zone.to_s
		}
		else
		@log.info "la zone " + zone.to_s + "est déjà bloquée ou elle était interdite "
		end
	end

	def estBloque? position
		if @liste.include?(quelleZone(position)) then return true else return false end
	end
	# Renvoie la liste des Objets appartenant à "listeObjets" qui sont "decalage" proche de la position "position"
	def numObjetLePlusProche(listeObjets,position,decalage)
		liste=Array.new
		listeObjets.each_index { |index|
			distance=Vecteur.new(listeObjets[index].position,position).norme
			if( distance < decalage)
				liste.push(index)
			end
		}
		return liste
	end

	# renvoie la zone dans laquelle position ce trouve
	def quelleZone(position)
		@graphe.quelleZone(position)
	end

	private

	# Rajoute le noeud numero "numero" qui a pour centre "position"
	# et une fonction "procedure" qui renvoie true uniquement si on lui passe un point à l'intérieur de cette zone
	def ajouterNoeud(numero,position,procedure)
		@graphe.ajoutNoeud(numero,position,procedure)
	end

	# Utilisée pour déterminer si le point "pos" est au dessus ou en dessous de la droite formée par (x1,y1) et (x2,y2).
	# Renvoie un nombre positif si c'est au dessus et négatif si c'est en dessous
	def f(pos,x1,y1,x2,y2)
		return y1 +(y2-y1).to_f/(x2-x1).to_f*(pos-x1)
	end
	
	# Renvoie true si entre "position" et "pointEntree" on est suceptible de rencontrer un épis.
	# Teste en "précision" points et tient compte d'une margeSupplémentaire
	def onPeutPasCouper(position,pointEntre,precision=10,margeSupplementaire=5)
		for i in (0 .. precision)
			barycentre=position*i.to_f/precision + pointEntre*(precision-i).to_f/precision
			if (not numObjetLePlusProche(@liste_epis,barycentre,25+170+margeSupplementaire).empty?)
				@log.debug "on peut pas couper"		
				return true
			end
		end
		@log.debug "on peut couper"
		return false
	end
end
