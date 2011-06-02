#ifndef EnvoiPosition_h
#define EnvoiPosition_H

#include <HardwareSerial.h>

#define TRIGGER_BLOCAGE	50

class EnvoiPosition {
	public:
		EnvoiPosition();
		
		void	boucle();
		void 	active();
		void	desactive();
	
	private:
		void 	intToHex(unsigned char *);
		
		bool	actif;
};

extern EnvoiPosition envoiPosition;

#endif
