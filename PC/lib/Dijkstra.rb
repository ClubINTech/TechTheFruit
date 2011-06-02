# ce fichier contient les fonctions permettant de trouver le plus court chemin
# en utilisant l'algorithme de Dijkstra
# Author::    Clément Bethuys  (mailto:clement.bethuys@laposte.net)
# Copyright:: Copyright (c) 2010 INTech - TechTheFruit
# License::   GPL

require "Point"
require "Vecteur"
require "Log"

# C'est l'algorithme de pathfinding en lui même. On peut modifier le graphe qu'il utilise et lui demander ce
# pour quoi il est fait c'est à dire le plus court chemin d'un noeud A à un noeud B
class Dijkstra
        
	public 

	attr_accessor :noeuds ,:dedans ,:arretes

	# Crée le graphe qui est composée de noeuds et d'arretes
        def initialize
		@log = Logger.instance
		@nn=61
		@noeuds=Array.new
		@dedans=Array.new
		@arretes=Array.new(@nn) { Hash.new }
        end

	# Rajoute le noeud numero "numero" qui a pour centre "position"
	# et une fonction "procedure" qui renvoie true uniquement si on lui passe un point à l'intérieur de cette zone
        def ajoutNoeud(numero,position,procedure)
		@noeuds[numero]=position
		@dedans[numero]=procedure
        end

	# Ajoute une arrete entre deux noeuds déjà crées et calcul automatiquement la longueur de l'arrete
        def ajoutArrete(premier,second)
                @arretes[premier][second]=Vecteur.new(@noeuds[premier],@noeuds[second]).norme.to_i
		@arretes[second][premier]=Vecteur.new(@noeuds[premier],@noeuds[second]).norme.to_i
        end

	# Assigne la distance "distance" entre les zones "premier" et "second" 
	def modifArrete(premier,second,difference,duree=false)
                @arretes[premier][second]+=difference
		@arretes[second][premier]+=difference
		if(duree!=false)
		Thread.new {
		sleep(duree)
	        @arretes[premier][second]-=difference
		@arretes[second][premier]-=difference	
		}
		end
	end

	# Supprime une arrete
        def suppArrete(premier,second)
        	@arretes[premier].delete(second)
		@arretes[second].delete(premier)
        end
	
	# "La" fonction appelée par la carte qui renvoie une liste des points pour aller de la zone "n_depart" à la zone "n_arrive"
	def chemin(n_depart,n_arrive,pas_intermediaire)
		t = parcours(n_depart,n_arrive).map!{ |numero| @noeuds[numero]}
		if(pas_intermediaire) then t=enleverIntermediaires(t) end
		return t
	end

	# Trouve dans quelle Zone ce trouve le point "position"
	def quelleZone(position)

		@dedans.each_index {|i|
		if @dedans[i].call(position) then return i end}
		# apparement on est dans aucune zone
		@log.error "on est dans le caca, aucune zone en x=" + position.x.to_s + " y=" + position.y.to_s
	end

	# Enlève le maximum de points intermédiaires (ceux qui sont alignés).
	def enleverIntermediaires(chemin)
	        return chemin
		chemin.pop
		chemin-=[chemin.first]
		retour=Array.new
		retour.push(chemin[0])
		for i in (0 ..chemin.length-3)
			if(cosinus(Vecteur.new(chemin[i+1],chemin[i]),Vecteur.new(chemin[i+2],chemin[i+1]))<0.97)
				retour.push(chemin[i+1])
			end
		end
		if chemin.length-1>0 then retour.push(chemin.last) end
		@log.debug "après avoir enlevé les points intermédiaires = " + retour.inspect.to_s
		return retour
	end

	# renvoi le sinus entre 2 vecteurs a et b
	def cosinus (a,b)
		return (a.x*b.x+a.y*b.y).to_f/(a.norme*b.norme)
	end

	private

	# algorithme de dijstra qui trouve le plus petit chemin entre deux zones
	# où "n_depart" est le numéro de la zone de départ et "n_arrive" celui de l'arrivée
	def parcours(n_depart,n_arrive)

		liste_distances = Array.new
		liste_parcours = Array.new
		liste_predecesseurs = Array.new(@nn){Array.new}

		# on initialise le graphe
		for i in (0 .. @nn-1)
			liste_distances[i]=-1 # -1 représente l'infini
			liste_parcours[i]=false # la distance min de chaque noeud au noeud initial n'est pas encore connue ...
		end
		liste_distances[n_depart]=0 # ... sauf pour le noeud initial qui a une distance a lui même nulle
                # @log.debug "n_arrive=" + n_arrive.to_s
		# tant qu'on a pas la distance min jusqu'au noeud d'arrivé
		while liste_parcours[n_arrive]==false
			i=minfalse(liste_distances,liste_parcours)
			if i==-1
				@log.error "il n'existe pas de chemins pour aller jusqu'a " + n_arrive.to_s + " (on part de " + n_depart.to_s + ")"
				return n_depart # valeur de retour a ne pas utilisée
				end
			liste_parcours[i]=true

			# on modifie le poids des arretes en fonction de la direction du robot
				@arretes[i].each_key{ |zone|
				vecteur=0
				liste_predecesseurs[i].each { |predecesseurs|
					valeur=norme1reduite(@noeuds[zone] - @noeuds[predecesseurs])
					if(valeur>vecteur) then vecteur=valeur	end	
				}
				@arretes[i][zone]-= vecteur
				}

			# on calcule la distance des noeuds atteignablent, si la distance au noeud de départ est plus petite 
			# en passant par notre noeud. On met à jour la distance de ce noeud au noeud de départ et on dit
			# que le plus court chemin vient de nous dans liste_predecesseurs
			@arretes[i].each_key{ |zone|
				if (liste_distances[zone]<0 or liste_distances[zone]>@arretes[i][zone]+liste_distances[i])
					liste_distances[zone]=@arretes[i][zone]+liste_distances[i]
					liste_predecesseurs[zone].clear
					liste_predecesseurs[zone].push(i)
				elsif (liste_distances[zone]<0 or liste_distances[zone]==@arretes[i][zone]+liste_distances[i])
					liste_distances[zone]=@arretes[i][zone]+liste_distances[i]
					liste_predecesseurs[zone].push(i)
				end
			}

			# on rétablie le poids des arretes pour pas tout chambouller
				@arretes[i].each_key{ |zone|
				vecteur=0
				liste_predecesseurs[i].each { |predecesseurs|
					valeur=norme1reduite(@noeuds[zone] - @noeuds[predecesseurs])
					if(valeur>vecteur) then vecteur=valeur	end	
				}
				@arretes[i][zone]+= vecteur
				}
		end

		# chemin est la liste des noeud qu'il faut parcourir pour aller jusqu'au noeud final
		# on sait qu'elle se termine par "n_arrive", grace à la liste des prédécesseurs on remonte jusqu'a "n_depart"
		chemin=Array.new
		elemprecedant=n_arrive
		elemcourant=liste_predecesseurs[n_arrive].first
		chemin.push(elemprecedant)
		chemin.push(elemcourant)
		while elemcourant!=n_depart
			# ici on fait attention à prendre le meilleur chemin dans la liste des prédécesseurs
			max=0
			numero_max=nil
			liste_predecesseurs[elemcourant].each { |predecesseur|
			valeur=norme1reduite(@noeuds[elemprecedant] - @noeuds[predecesseur])
			if(valeur>max)then
				max=valeur
				numero_max=predecesseur
			end
			}
			elempredecesseur=elemcourant
			elemcourant= numero_max
			chemin.push(elemcourant)
		end
		chemin.reverse!
		@log.debug "le chemin issu de Dijkstra " + chemin.inspect.to_s
		return chemin
	end

	# Renvoie le noeuds que l'on a pas encore parcouru qui est le plus proche en distance du noeud de départ
	def minfalse(liste_distances,liste_parcours)
		distancemin=-1 # au début on a pas trouvé donc c'est l'infini
		numero=-1 # la fonction renverrait -1 si on a parcouru tout le disjtra
		i=0
		for i in (0 .. @nn-1)
			if liste_parcours[i]==false and liste_distances[i]>=0 and (distancemin<0 or distancemin>liste_distances[i])
				distancemin=liste_distances[i]
				numero=i
			end
		end
		# on renvoie le numéro du noeud le plus proche du noeud initial
		return numero
	end

	# Calcule une norme 1 divisée par 100
	def norme1reduite p
		return abs(p.x/100)+abs(p.y/100)
	end

	# Retourne la valeur absolue de "n"
	def abs n
		if n>=0 then return n
		else return -n
		end
	end

	# Rajoute touts les points de passages entre les différentes zones du chemin "chemin"
	def rajouterPointPassage(chemin)
		nbInsertion=0
		for i in (1 .. chemin.length() -1)
			chemin.insert(i+nbInsertion,pointSortie(chemin[i+nbInsertion-1],chemin[i+nbInsertion]))
			nbInsertion+=1
		end
		return chemin
	end

	# Trouve l'intersection entre la droite formé par les deux noeuds "entree" et "sortie" et la ligne de séparation entre les deux zones
	def pointSortie(entree,sortie,precision=5)
		zoneEntree=quelleZone(entree)
		a=entree
		b=sortie
	
		precision.times do 
			if(quelleZone((a+b)/2)==zoneEntree) then a=(a+b)/2
			else b=(a+b)/2 end
		end
		return a.to_i
	end
end
