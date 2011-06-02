#include <avr/interrupt.h>
#include <avr/io.h>

#include <HardwareSerial.h>
#include <wiring.h>

#include "Manager.h"

/*
 * Fonction d'interruption sur les codeurs
 */

volatile char etatPins = 0;

ISR(PCINT2_vect)
{
    	unsigned char changementPins 	= (PIND & MASQUE) ^ etatPins; // un unsigned fera l'affaire -- Yann Sionneau
    	etatPins 		= PIND & MASQUE;
    
    	if (changementPins & ENCGA){
		if (etatPins & ENCGA) //front montant codeur 1 voix A
			(etatPins & ENCGB)?encodeurG++:encodeurG--;
	      	else                  //front descendant codeur 1 voix A
			(etatPins & ENCGB)?encodeurG--:encodeurG++;
	}

    	if (changementPins & ENCGB){
		if (etatPins & ENCGB) //front montant codeur 1 voix B
			(etatPins & ENCGA)?encodeurG--:encodeurG++;
		else                  //front descendant codeur 1 voix B
			(etatPins & ENCGA)?encodeurG++:encodeurG--;
	}
    
	if (changementPins & ENCDA){
		if (etatPins & ENCDA) //front montant codeur 2 voix A
			(etatPins & ENCDB)?encodeurD++:encodeurD--;
		else                  //front descendant codeur 2 voix A
			(etatPins & ENCDB)?encodeurD--:encodeurD++;
	}
 
	if (changementPins & ENCDB){
		if (etatPins & ENCDB) //front montant codeur 2 voix B
			(etatPins & ENCDA)?encodeurD--:encodeurD++;
	        else                  //front descendant codeur 2 voix B
			(etatPins & ENCDA)?encodeurD++:encodeurD--;
	}

}
/*
 * Fonction à exécuter à intervalle de temps régulier (~1kHz)
 * Ajouter un timer, priorité sur les interruptions
 */
void 
Manager::assPolaire()
{
	//static int stator1337 = 100; // TODO: Mettre static unsigned char stator1337 = 100; ? -- Yann Sionneau
	
	long int angle = 	encodeurG - encodeurD;
	long int distance = 	encodeurG + encodeurD;

	/*
	 * Reprise TechTheWave, priorité des interruptions
	 */
	 
	// Sauvegarde de TIMSK2
	//unsigned char savTIMSK2 = TIMSK2; // un unsigned fera l'affaire ! -- Yann Sionneau
	// Asservissement prioritaire sur l'envoi de la position
	//TIMSK2 &= ~(1<<TOIE2); 
	// Réactivation des interruptions pour les encodeurs
	sei();  

	assRotation.calculePositionIntermediaire(angle);
	assTranslation.calculePositionIntermediaire(distance);

	int pwmRotation = (activationAssAngle?assRotation.calculePwm(angle):0);
	int pwmTranslation = (activationAssDistance?assTranslation.calculePwm(distance):0);

	// Coefficient trouvé de manière empirique
	int pwmG = pwmTranslation + pwmRotation;
	int pwmD = pwmTranslation - pwmRotation;

	if (pwmG > PWM_MAX) 
		pwmG = PWM_MAX;
	else if (pwmG < -PWM_MAX) 
		pwmG = -PWM_MAX;

	if (pwmD > PWM_MAX) 
		pwmD = PWM_MAX;
	else if (pwmD < -PWM_MAX) 
		pwmD = -PWM_MAX;
	
	if (pwmG > 0) {
		// Direction gauche = 0
		// PWM gauche = pwmG
		PORTB &= ~PINDIRG;
		OCR1A = pwmG;
	}
	else {
		// Direction gauche = 1
		// PWM gauche = -pwmG
		PORTB |= PINDIRG; 
		OCR1A = -pwmG;
	}

	if (pwmD > 0) {
		// Direction droite = 0
		// PWM droite = pwmD
		PORTB &= ~PINDIRD;
		OCR1B = pwmD;
	}
	else {
		// Direction droite = 1
		// PWM droite = -pwmD
		PORTB |= PINDIRD;
        	OCR1B = -pwmD;
	}
		
	/*
	 * Reprise TechTheWave
	 */
	 
	// Réactivation des interruptions
	//cli();
	// Reprise de l'envoi de position
	//TODO je pense que c'est plutot TIMSK2 = savTIMSK2; pour la ligne suivante. -- Yann Sionneau
	//TIMSK2 |= savTIMSK2; 
}

/*
 * Initialisation des pins
 */
Manager::Manager() 
{
}

void
Manager::init()
{
	activationAssDistance = true;
	activationAssAngle = true;
	
	/*
	 * Réglage des pins (codeurs)
	 */
	pinMode(PORTB2, INPUT);
	pinMode(PORTB3, INPUT);
	pinMode(PORTB4, INPUT);
	pinMode(PORTB5, INPUT);
	
	digitalWrite(PORTB2, HIGH);
	digitalWrite(PORTB3, HIGH);
	digitalWrite(PORTB4, HIGH);
	digitalWrite(PORTB5, HIGH);

	// Initialisation de l'interruption
	PCICR |= (1 << PCIE2);
  	PCMSK2 |= (1 << PCINT18) | (1 << PCINT19) | (1 << PCINT20) | (1 << PCINT21);
	
	/*
	 * Réglage des PWM
	 */

	pinMode(DIRG, OUTPUT);
	pinMode(PWMG, OUTPUT);
	
	pinMode(DIRD, OUTPUT);
	pinMode(PWMD, OUTPUT);
	
	digitalWrite(PWMG, 0);
	digitalWrite(PWMD, 0);
	
	digitalWrite(DIRG, 0);
	digitalWrite(DIRD, 0);

	// Fast PWM
	TCCR1A = (1 << WGM11) | (1 << WGM10);
	TCCR1B = (1<<CS10); 			// Divise la fréq du timer par1
	TCCR1A |= (1 << COM1A1); 		// Timer de base, 2 ports spéciaux pour les créneaux
	TCCR1A |= (1 << COM1B1);
	 
	/*
	 * Initialisation du timer de l'asservissement @ 1kHz
	 */
	TCCR2A |= (1 << CS22) | (0 << CS21) | (0 << CS20);
	TCCR2A |= (0 << WGM21) |(0 << WGM20);
	TIMSK2 |= (1 << TOIE2) | (0 << OCIE2A);
	
	assRotation.changeKp(15);
	assRotation.changeAcc(21);
	assRotation.changeVmax(3000);
	assRotation.changePWM(1024);
	assRotation.changeKd(35);
	
	assTranslation.changeKp(12);
	assTranslation.changeAcc(20);
	assTranslation.changeVmax(3000);
	assTranslation.changePWM(1024);
	assTranslation.changeKd(40);
}

/*
 * Définit la nouvelle consigne en angle et distance (en tics)
 */
void 
Manager::changeConsigne(long int distanceDonnee, long int angleDonne)
{
	assTranslation.changeConsigne(distanceDonnee);
	assRotation.changeConsigne(angleDonne);
}

void
Manager::changeConsigneAngle(long int angleDonne)
{
	assRotation.changeConsigne(angleDonne);
}

void 
Manager::changeConsigneDistance(long int distanceDonnee)
{
	assTranslation.changeConsigne(distanceDonnee);
}

void 
Manager::switchAssDistance()
{
	activationAssDistance = !activationAssDistance;
}

void 
Manager::switchAssAngle()
{
	activationAssAngle = !activationAssAngle;
}

void
Manager::reset()
{
	cli();
	encodeurG = 0;
	encodeurD = 0;
	assRotation.reset();
	assTranslation.reset();
	sei();
}
/*
 * Portion à modifier 
 * Réduire le préscaler à 500Hz
 */
 
unsigned char stator1 = 1; // un unsigned fera l'affaire ! -- Yann Sionneau

ISR(TIMER2_OVF_vect)
{
	if (stator1 == 0) {
		manager.assPolaire();
		stator1 = 1;
	}
	else {
		stator1--; // TODO: mettre stator1 = 0; à la place ? -- Yann Sionneau
	}
}


volatile long int encodeurG = 0;
volatile long int encodeurD = 0;

Manager manager;

