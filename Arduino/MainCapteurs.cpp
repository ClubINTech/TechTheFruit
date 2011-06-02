/**
 * \file MainCapteurs.cpp
 * \brief Permet de controler l'asservissement
 *
 * exécute les ordres qui lui sont passées, voici la liste des ordres :\n\n
 * "?" pour demaner quelle carte est-tu (ie 2)\n
 * "o" pour demander une mesure par optique\n
 * "u" pour demander une mesure par ultrason\n
 */

//Capteurs du bas avant : 
//const int pingPinBAvG = 6;
//const int pingPinBAvD = 3;
//Capteurs du bas arriere : 
//const int pingPinBArG = 10;
//const int pingPinBArD = 11;
//Capteurs du haut : 
const int pingPinHAvG = 7;
const int pingPinHAvD = 4;
const int pingPinHArG = 8;
const int pingPinHArD = 9;
//Capteurs optiques : 
const int optPinAvG = 5;
const int optPinAvD = 2;
const int optPinArG = 12;
const int optPinArD = 13;
const int optPinAvM = 6;
//tableau des valeurs
int id = 0;//identificateur du tableau à utiliser
int i;//pour les diverses boucles
int tableauUS0[]={0,0,0,0};
int tableauUS1[]={0,0,0,0};
int tableauUS2[]={0,0,0,0};
int tableauO0[]={0,0,0,0,0};
int tableauO1[]={0,0,0,0,0};
int tableauO2[]={0,0,0,0,0};
char c;//le caractère reçu

/**
 * \brief initialise la connection série à 57600 bauds et les différentes pins
 */
void setup() {
	// initialize serial communication:
	Serial.begin(57600);
	pinMode(optPinAvG, INPUT);
	pinMode(optPinAvD, INPUT);
	pinMode(optPinArG, INPUT);
	pinMode(optPinArD, INPUT);
	pinMode(optPinAvM, INPUT);
}

/**
 * \brief traite en permanence les commandes qui lui sont passées
 */
void loop()
{
	if (Serial.available()>0) {
		c = Serial.read();
		if (c=='u') {
			envoieUS();
		}
		if (c=='o') {
			envoieO();
		}
		if (c=='?') {
			Serial.println('2');
		}
	}
	else {
		raffraichissement();
	}
}

/**
 * \fn void raffraichissement()
 * \brief met à jour les tableaux des valeurs captées
 * 
 * raffraichissement des valeurs enregistrées, fonction lancée régulièrement par la loop().
 * 
 */
void raffraichissement() 
{
	//on raffraichie les valeurs
	if (id==0) {
		mesureUltrason(tableauUS0);
		mesureOptiques(tableauO0);
	}
	if (id==1) {
		mesureUltrason(tableauUS1);
		mesureOptiques(tableauO1);
	}
	if (id==2) {
		mesureUltrason(tableauUS2);
		mesureOptiques(tableauO2);
	}
	if (id<2){
		id++;
	}
	else {
		id=0;
	}
	delayMicroseconds(50);
}

/**
 * \fn void envoieUS()
 * \brief affiche les valeurs captées sur la console
 * 
 * lance les 3 séries de mesures ultrason et envoie les résultats
 * 
 */
void envoieUS() {
	//envoie par serie
	for (i=0;i<3;i++){
		Serial.print(tableauUS0[i]);
		Serial.print("-");
	}
	Serial.print(tableauUS0[3]);
	delayMicroseconds(50);
	Serial.print("\t");
	for (i=0;i<3;i++){
		Serial.print(tableauUS1[i]);
		Serial.print("-");
	}
	Serial.print(tableauUS1[3]);
	delayMicroseconds(50);
	Serial.print("\t");
	for (i=0;i<3;i++){
		Serial.print(tableauUS2[i]);
		Serial.print("-");
	}
	Serial.print(tableauUS2[3]);
	delayMicroseconds(50);
	Serial.println();
}

/**
 * \fn void envoieO()
 * \brief pas encore de courte descriptions
 *
 * lance les 3 séries de mesures optiques et envoie les résultats
 */
void envoieO() {
	//envoie par serie
	for (i=0;i<4;i++){
		Serial.print(tableauO0[i]);
		Serial.print("-");
	}
	Serial.print(tableauO0[4]);
	delayMicroseconds(50);
	Serial.print("\t");
	for (i=0;i<4;i++){
		Serial.print(tableauO1[i]);
		Serial.print("-");
	}
	Serial.print(tableauO1[4]);
	delayMicroseconds(50);
	Serial.print("\t");
	for (i=0;i<4;i++){
		Serial.print(tableauO2[i]);
		Serial.print("-");
	}
	Serial.print(tableauO2[4]);
	delayMicroseconds(50);
	Serial.println();
}

/**
 * \fn void mesureUltrason(int tableau[8])
 * \brief pas encore de courte descriptions
 *
 * fait un tour de mesure des capteurs ultrason
 */
void mesureUltrason(int tableau[8]) {
	int i;
	//prise des mesures
	//tableau[0] = mesureConv(pingPinBAvG);
	//tableau[1] = mesureConv(pingPinBAvD);
	//tableau[2] = mesureConv(pingPinBArG);
	//tableau[3] = mesureConv(pingPinBArD);
	tableau[0] = mesureConv(pingPinHAvG);
	tableau[1] = mesureConv(pingPinHAvD);
	tableau[2] = mesureConv(pingPinHArG);
	tableau[3] = mesureConv(pingPinHArD);
	for (i=0;i<4;i++){
		if (tableau[i]>5000){
			tableau[i]=0;
		}
	}
	//delai repos ;)
	delayMicroseconds(50);
}

/**
 * \fn long microsecondsToMillimeters(long microseconds)
 * \brief pas encore de courte descriptions
 *
 * fait la conversion entre le temps de retour (en µs) et la distance correspondant (en mm)
 */
long microsecondsToMillimeters(long microseconds)
{
	return (microseconds*10) / 29 / 2;
}

/**
 * \fn void mesureOptiques(int tableau[4]) 
 * \brief pas encore de courte descriptions
 *
 * fait un tour de mesure sur les capteurs optiques
 */
void mesureOptiques(int tableau[5]) {
	//prise des mesures
	tableau[0] = digitalRead(optPinAvM);
	tableau[1] = digitalRead(optPinAvG);
	tableau[2] = digitalRead(optPinAvD);
	tableau[3] = digitalRead(optPinArG);
	tableau[4] = digitalRead(optPinArD);
	//delai repos ;)
	delayMicroseconds(50);
}

/**
 * \fn long mesureConv (int pin) 
 * \brief pas encore de courte descriptions
 *
 * prise des mesures ultrasons + conversion en mm
 */
long mesureConv (int pin) {
	pinMode(pin, OUTPUT);
	digitalWrite(pin, LOW);
	delayMicroseconds(2);
	digitalWrite(pin, HIGH);
	delayMicroseconds(5);
	digitalWrite(pin, LOW);
	//lecture des mesures
	pinMode(pin, INPUT);
	return microsecondsToMillimeters(pulseIn(pin, HIGH, 14000));
}
