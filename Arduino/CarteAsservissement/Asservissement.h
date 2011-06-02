#ifndef Asservissement_h
#define Asservissement_h

// Puissance max. de l'asservissement comprise entre 0 et 1024
#define	PUISSANCE	300

// Constante de l'asservissement
#define KP		30
#define VMAX		30000
#define ACC		22
#define KD		35

#define PRESCALER	128

#define TRIGGER_BLOCAGE	15

class Asservissement{
	public:
		Asservissement();
		
		void	changeConsigne(long int);
		
		int 	calculePwm(long int);
		void 	calculePositionIntermediaire(long int);
		
		void 	stop();
		void 	stopUrgence(long int); 
		
		void 	calculeErreurMax();
		
		void 	changeKp(int);
		void 	changeAcc(long int);
		void	changeVmax(long int);
		void 	changePWM(int);
		void	changeKd(long int);
		
		void	reset();

		// Consigne et position du robot (point de vue Arduino)
		long int 	consigne;	
		long int 	positionIntermediaire;
		
		// Consigne et position du robot zoomé
		long int 	consigneZoom;	
		long int 	positionIntermediaireZoom;

		// Constantes de l'asservissement et du moteur	
		long int 	Kp; 
		long int	Kd;
		long int	deltaBkp;	
		long int 	Acc, Vmax;
		long int 	maxPWM; 
		
		// Distance de freinage		
		long int 	dFreinage; 

		// Palier de vitesse
		long int 	n;	

		// Erreur maximum (sert à détecter les obstacles)
		long int 	erreurMax;	
		long int	erreur;

		// Vaut 1 ou -1 si le moteur est bloqué
		int 		blocageDetecte;
		int		blocageTemp;
};

#endif
