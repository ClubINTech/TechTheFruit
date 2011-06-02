/**
 * \file MainActionneurs.cpp
 * \brief Permet de controler les actionneurs
 *
 * exécute les ordres qui lui sont passées, voici la liste des ordres :\n\n
 * "?" quelle carte est-tu (ie 1) \n
 * "a" lit la valeur du jumper \n
 * "b" allume la led \n
 * "c" arrete les actions \n
 * "d" range le bras, dangereux si rails pleins \n //11 bras rangés
 * "e" monte le bras, verrouillage oranges \n //01 bras montésc
 * "f" baisse le bras \n //10 bras en bas
 * "g" démarre le rouleau sens montant \n
 * "h" démarre le rouleau sens descendant \n
 * "i" stoppe le rouleau \n
 * "j" oriente les tomates vers la gauche \n
 * "k" oriente les tomates vers la droite \ni
 * "l" mesure du courant oranges\n
 * "m" mesure du courant rouleau\n
 * "n" lire position bras\n
 * "o" stoppe sélecteur
 * "p" place le sélecteur en position milieu
 */

#include <Servo.h> 
//**INIT DES PINS**
//Commandes moteurs : 
//oranges : 
const int pwmO = 3;//pin acceptant du pwm : 3-5-6-9-10-11
const int dirO = 2;
//rouleau : 
const int pwmR = 5;
const int dirR = 4;
//sélecteur :
const int sel = 6;
Servo selServo;
//jumper : 
const int jmp = 7;
//led : 
const int led = 8;
//Contrôle courant : 
const int ccO = 5;//oranges  
const int ccR = 0;//rouleau  
//capteurs bras oranges : 
const int brO1 = 13; 
//const int brO2 = 12;

//**INIT DES VALEURS**
//Bras des oranges : 
int posDemO = 0;//Position demandée : 0=rangé, 1=intermédiaire, 2=bas, autre=arrêt
int sensO = 1;//sens descente du bras des oranges
int sensOC = 0;//sens montant du bras des oranges
unsigned long previousMillisO = 0;//dernier changement d'état
int periodeO = 50;//periode de controle d'etat
int timerO = 0;//nombre de période de contrôle à considérer.
int tempsMaxO = 44;//temps d'attente (en nombre de période) ; 27<->1,35s, 44<->2,2s.
int tmpO = 0;//direction précédente de mouvementdu bras (info nécessaire au leverBras). 
//Oscillateur selecteur : 
char actifSel = 0;//etat d'activité du selecteur
int refSel = 72;//valeur autour de laquelle osciller.
int amplitude = 0;//amplitude du mouvement
int dernEtat = 72;//dernière position du sélecteur.
int periode = 250;//periode d'oscillation (millisecondes)
unsigned long previousMillis = 0;//dernier changement d'etat
int refG = 87;//référence de position gauche
int refD = 58;//référence de position droite
int refM = 72;//référence de position milieu

//Valeurs max des pwm
const int maxO = 128;//6V
const int maxR = 255;//24V

//derniers sens rouleau : 
int tmpR = 0;
//Valeur max des courants : 
const int maxC = 624;
const int maxMax = 400;//seuil spécial moteur oranges
//Compteur de dépassement en courant : 
int depO = 0, depR = 0; 

/**
 * \fn void setup()
 * \brief initialise la connection série à 57600 bauds
 */
void setup() {
	Serial.begin(57600);
	pinMode(pwmO,OUTPUT);
	pinMode(dirO,OUTPUT);
	pinMode(pwmR,OUTPUT);
	pinMode(dirR,OUTPUT);
	pinMode(led,OUTPUT);
	pinMode(sel,OUTPUT);
	digitalWrite(led,0);
	pinMode(jmp,INPUT);
	pinMode(ccO,INPUT);
	pinMode(ccR,INPUT);
	pinMode(brO1,INPUT);
	//pinMode(brO2,INPUT);
	selServo.attach(sel);

	// hack pwm interdit, overclock by Bobo pour accélérer le pwm des moteurs.
	TCCR2B &= ~(1 << CS20);
	TCCR2B &= ~(1 << CS22);
	TCCR2B |= (1 << CS21);
}

/**
 * \fn void loop()
 * \brief traitera en permanence les commandes qui lui sont passées
 */
void loop() {
	char c=0;
	unsigned long currentMillis = millis();
	if (Serial.available()!=0) {
		c=Serial.read();
		switch (c) {
			case '?' :
				Serial.println("1");
				break;
			case 'a' :
				lireJumper();
				break;
			case 'b' :
				allumerLed();
				Serial.println("1");
				break;
			case 'c' :
				arreteTout();
				Serial.println("1");
				actifSel = 0;
				posDemO = 4;
				break;
			case 'd' :
				rangeBras();
				Serial.println("1");
				break;
			case 'e' :
				monteBras();
				Serial.println("1");
				break;
			case 'f' :
				baisseBras();
				Serial.println("1");
				break;
			case 'g' :
				demarreRouleauHaut();
				Serial.println("1");
				actifSel = 1;
				break;
			case 'h' :
				demarreRouleauBas();
				Serial.println("1");
				actifSel = 1;
				break;
			case 'i' :
				stoppeRouleau();
				Serial.println("1");
				actifSel = 0;
				break;
			case 'j' :
				tomateGauche();
				Serial.println("1");
				actifSel = 1;
				break;
			case 'k' :
				tomateDroite();
				Serial.println("1");
				actifSel = 1;
				break;
			case 'l' :
				Serial.println(analogRead(ccO));
				break;
			case 'm' : 
				Serial.println(analogRead(ccR));
				break;
			case 'n' : 
				lirePositionBras();
				break;
			case 'o' : 
				actifSel = 0;
				Serial.println("1");
				break;
			case 'p' : 
				tomateMilieu();
				Serial.println("1");
				break;

		}
	}
	//les raffraichissement pour le contrôle des courants.(Rouleau)
	controleCourantRouleau();
	//Oscillations selecteur tomates
        if (currentMillis - previousMillis >= periode){
		if (actifSel !=0 ){
		        previousMillis = currentMillis;
			oscilleSel();
		}
                //Serial.print(analogRead(ccR));
                //Serial.print("\t");
                //Serial.println(tmpR);
	}
	//mouvement bras
	if (currentMillis - previousMillisO >= periodeO){
		if (timerO > 0){
			timerO--;
		}
		else{
			timerO = 0;
			if (posDemO == 2){
				stoppeBras();
			}
		}
		previousMillisO = currentMillis;
		bougeBras(posDemO);
	}
}

/**
 * \fn void lireJumper()
 * \brief revoie l'état du jumper à l'eeepc
 * 
 * lie l'état (branché ou non) du jumper pour déclencher le démarrage du robot.
 * 
 */
void lireJumper() {
	Serial.println(digitalRead(jmp));
}

/**
 * \fn void allumerLed()
 * \brief allume la led
 * 
 * allume la led pour montrer que le robot est prêt à partir.
 * 
 */
void allumerLed() {
	digitalWrite(led,1);
}

/**
 * \fn void arreteTout()
 * \brief arrête tous les actionneurs
 * 
 * met tous les pwm à 0, ce qui stoppe les actionneurs
 * 
 */
void arreteTout() {
	analogWrite(pwmO,0);
	analogWrite(pwmR,0);
}

/**
 * \fn void rangeBras()
 * \brief Fait rentrer le bras dans sa position rentrée dans le robot.
 * 
 * Quelle que soit la position actuelle du bras, il retourne dans sa position haute à partir de la valeur mesurée par le potar.
 * 
 */
void rangeBras() {
	posDemO = 0;
}

/**
 * \fn void monteBras()
 * \brief Fait monter le bras dans sa position prise d'oranges
 * 
 * Quelle que soit la position actuelle du bras, il va dans sa position prise d'oranges à partir de la position mesurée par le potar.
 * 
 */
void monteBras() {
	posDemO = 1;
        if (digitalRead(brO1) == 0){
          tmpO = 0;
        }
        else {
          tmpO = 1;
        }
}

/**
 * \fn void baisseBras()
 * \brief Fait descendre le bras dans sa position basse
 * 
 * Quelle que soit la position actuelle du bras, il va dans sa position basse à partir de la position mesurée par le potar.
 * 
 */
void baisseBras() {
	posDemO = 2;
	timerO = tempsMaxO;
}

/**
 * \fn int controleCourantOrange()
 * \brief Controle le non dépassement du seuil anti-grillage du pont en H des oranges.
 * 
 * Mesure et vérifie que le courant traversant le pont en H du bras des oranges ne dépasse pas le seuil choisi.
 * 
 * \return code d'erreur : 1 en cas de dépassement, 0 sinon.
 */
int controleCourantOrange(){
	if (analogRead(ccO)>maxMax) {
		depO++;
	}
	else {
		if (depO!=0){
			depO--;
		}
		else {
			depO=0;
		}
	}
	if (depO>=20) {
		stoppeBras();
		//Serial.println("pb courant");
		return 1;
	}
	return 0;
}

/**
 * \fn void bougeBras(int posDemO)
 * \brief Fait bouger les bras
 *
 * Fait bouger les bras pour les faire aller dans la position demandée
 *
 * \param posDemO Position demandée 
 *
 */
void bougeBras(int posDemO){
	if (posDemO == 0){//on monte
		digitalWrite(dirO,sensOC);
		analogWrite(pwmO,maxO);
		controleCourantOrange();
	}
	else if (posDemO == 1) {//y faut voir...
		if (tmpO == 0 && digitalRead(brO1) == 1) {
			stoppeBras();
		}
		else if (tmpO == 1 && digitalRead(brO1)==0) {
			stoppeBras();
		}
		if (digitalRead(brO1)==0){
			digitalWrite(dirO,sensOC);
			analogWrite(pwmO,maxO);
			controleCourantOrange();
			tmpO = 0;
			//Serial.println("on monte");
		}
		else {//je descends
			digitalWrite(dirO,sensO);
			analogWrite(pwmO,maxO);
			controleCourantOrange();
			tmpO = 1;
			//Serial.println("on descend");
		}
	}
	else if (posDemO==2) {//on descend
		digitalWrite(dirO,sensO);
		analogWrite(pwmO,maxO);
		controleCourantOrange();
	}
	else {//on s'arrête
		stoppeBras();
	}
}

/**
 * \fn void stoppeBras()
 * \brief Arrête le bras
 * 
 * Quoiqu'il fasse, le bras s'arrête.
 * 
 */
void stoppeBras(){
	posDemO=4;
	analogWrite(pwmO,0);
}

/**
 * \fn void demarreRouleauBas()
 * \brief Fait tourner le rouleau, sens descendant
 * 
 * Active le pwm du rouleau avec comme sens celui descendant (si le cablage est bien fait). 
 * 
 */
void demarreRouleauBas() {
	digitalWrite(dirR,0);
	analogWrite(pwmR,maxR);
	tomateGauche();
	tmpR = 0;
}

/**
 * \fn void demarreRouleauHaut()
 * \brief Fait tourner le rouleau, sens montant
 * 
 * Active le pwm du rouleau avec comme sens celui montant (si le cablage est bien fait). 
 * 
 */
void demarreRouleauHaut() {
	digitalWrite(dirR,1);
	analogWrite(pwmR,maxR);
	tomateDroite();
	tmpR = 1;
}

/**
 * \fn int controleCourantRouleau()
 * \brief Controle le non dépassement du seuil anti-grillage du pont en H des oranges.
 * 
 * Mesure et vérifie que le courant traversant le pont en H du bras des oranges ne dépasse pas le seuil choisi.
 * 
 * \return code d'erreur : 1 en cas de dépassement, 0 sinon.
 */
int controleCourantRouleau(){
	if (analogRead(ccR)>maxMax) {
		depR++;
	}
	else {
		if (depR!=0){
			depR--;
		}
		else {
			depR=0;
		}
	}
	if (depR>=10) {
		//stoppeRouleau();//on coupe avant de tout griller
		analogWrite(pwmR,0);
		delay(50);//on lui laisse le temps de s'arrêter
		if (tmpR==0) {
			//demarreRouleauHaut();
                        digitalWrite(dirR,1);
		}
		if (tmpR==1) {
			//demarreRouleauBas();
                        digitalWrite(dirR,0);
		}
		delay(500);//on tente de le débloquer
		//stoppeRouleau();
		analogWrite(pwmR,0);
		delay(50);//on lui laisse le temps de s'arrêter
		if (tmpR==0){
			//demarreRouleauBas();
                        digitalWrite(dirR,0);
		}
		if (tmpR==1){
			//demarreRouleauHaut();
                        digitalWrite(dirR,1);
		}
		return 1;
	}
	return 0;
}

/**
 * \fn void stoppeRouleau()
 * \brief Arrête le rouleau
 * 
 * Quoi qu'il fasse (y compris blocage) le rouleau s'arrête de tourner.
 * 
 */
void stoppeRouleau() {
	analogWrite(pwmR,0);
}

/**
 * \fn void tomateGauche()
 * \brief envoie les tomates vers la gauche
 * 
 * Active le pwm du moteur sélecteur pour envoyer les tomate vers la gauche.
 * 
 */
void tomateGauche() {
	amplitude = 5;
	refSel = refG;
}

/**
 * \fn void tomateDroite()
 * \brief envoie les tomates vers la droite
 * 
 * Active le pwm du moteur sélecteur pour envoyer les tomates vers la droite. 
 * 
 */
void tomateDroite() {
	amplitude = 5;
	refSel = refD;
}

/**
 * \fn void tomateMilieu()
 * \brief envoie les tomates vers la droite
 * 
 * Active le pwm du moteur sélecteur pour envoyer les tomates vers la droite. 
 * 
 */
void tomateMilieu() {
	amplitude = 0;
	refSel = refM;
}


/**
 * \fn void oscilleSel()
 * \brief fait osciller le bras en continu
 *
 * Fait osciller le bras en continue
 *
 */
void oscilleSel(){
	if (dernEtat == refSel - amplitude){
		dernEtat = refSel + amplitude;
	}
	else {
		dernEtat = refSel - amplitude;
	}
	selServo.write(dernEtat);
}

/** 
 * \fn void lirePositionBras()
 * \brief lie et envoie la position actuelle des bras
 * 
 * Lie et envoie le code de la position actuelle des bras.
 * 
 */
void lirePositionBras() {
	Serial.print(digitalRead(brO1));
	Serial.print("\t");
	//Serial.println(digitalRead(brO2));
}
