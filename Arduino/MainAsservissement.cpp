/**
 * \file MainAsservissement.cpp
 * \brief Permet de controler l'asservissement
 *
 * exécute les ordres qui lui sont passées, voici la liste des ordres :\n\n
 * "?" pour demaner quelle carte est-tu (ie 0) \n
 * "a" change l'angle \n
 * "b" change la distance \n
 * "c" active l'envoie de la position \n
 * "d" désactive l'envoie de la position \n
 * "e" réinitialise la position \n
 * "f" change l'angle mais en négatif \n
 * "g" change la distance mais en négatif \n
 * "h" change AssDistance d'état \n
 * "i" change AssAngle d'état \n
 * "j" reset \n
 * "k" change l'accélération maximale \n
 * "l" change le Vmax \n
 * "n" stop tout mouvement \n
 */

#include <Asservissement.h>
#include <EnvoiPosition.h>
#include <LectureSerie.h>
#include <Manager.h>

/**
 * \brief initialise la connection série à 57600 bauds
 */
void setup() {
	Serial.begin(57600);
        manager.init();
}



void loop() {

	lectureSerie.traitement();

}
