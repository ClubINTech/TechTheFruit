#include <avr/interrupt.h>
#include <avr/io.h>

#include <HardwareSerial.h>

#include "EnvoiPosition.h"
#include "Manager.h"

EnvoiPosition::EnvoiPosition() 
{
	TCCR0A |= (1 << CS02) | (0 << CS01) | (1 << CS00);
	OCR0A = 128;
	
	TCNT0 = 0;
}

/*
 * Fonction à exécuter dans un timer
 */
void 
EnvoiPosition::boucle()
{
	/*
	 * Envoi de encodeurG, encodeurD si actif = 1
	 * Pour blocageDetecte, le passage de assRotation et assTranslation en public est moche
	 */
}

/*
 * Active le timer
 */
void 
EnvoiPosition::active()
{
	actif = true;
	TIMSK0 |=  (1 << OCIE0A);
}

/*
 * Désactive le timer
 */
void 
EnvoiPosition::desactive()
{
	actif = false;
	TIMSK0 &= ~(1 << OCIE0A);
}

void 
EnvoiPosition::intToHex(unsigned char *data)
{
	unsigned char c;
//	int i; Inutile de stoquer les nombres de 0 à 3 sur 2 octets (2 registres sur avr) :) -- Yann Sionneau
	unsigned char i; 
	
	for (i = 3; i >= 0; i--) {
		c = (data[i] & 0xF0) >> 4;
		
		if (c <= 9)
			Serial.write(c + '0');
		else
			Serial.write(c - 10 + 'A');
			
		c = data[i] & 0xF;
		
		if (c <= 9)
			Serial.write(c + '0');
		else
			Serial.write(c - 10 + 'A');
	}
}

/*
 * Portion à modifier
 * Utiliser : EnvoiPosition::boucle()
 */
 
// Division par 4 du temps de cette interruption @ 57600 bauds (pareil à 9600..)
// TODO: Peut-on passer cette variable en unsigned ? les avr ont plus de facilité avec les non signés :) -- Yann Sionneau
char stator = 3;

long int bufferG;
long int bufferD;

ISR(TIMER0_COMPA_vect)
{
	if (stator == 0) {
		stator = 3;
		bufferG = encodeurG;
		bufferD = encodeurD;		
		sei();
		Serial.print(bufferG);
		Serial.print(" ");
		Serial.print(bufferD);
		Serial.print(" ");
		
		if (manager.assTranslation.blocageTemp == TRIGGER_BLOCAGE) {
			if (manager.assRotation.erreur > 0) 
				Serial.print("1");
			else
				Serial.print("2");
		}
		else if (manager.assTranslation.blocageTemp == -TRIGGER_BLOCAGE) {
			if (manager.assRotation.erreur > 0) 
				Serial.print("-2");
			else
				Serial.print("-1");
		} 
		else {
			Serial.print("0");
		}
		
		Serial.print(" ");
		
		if (manager.assRotation.blocageTemp == TRIGGER_BLOCAGE) {
			if (manager.assTranslation.erreur > 0) 
				Serial.print("1");
			else
				Serial.print("2");
		}
		else if (manager.assRotation.blocageTemp == -TRIGGER_BLOCAGE) {
			if (manager.assTranslation.erreur > 0) 
				Serial.print("-2");
			else
				Serial.print("-1");
		} 
		else {
			Serial.print("0");
		}

		Serial.println();
	}
	else {
		stator--;
	}	
}

EnvoiPosition envoiPosition;

