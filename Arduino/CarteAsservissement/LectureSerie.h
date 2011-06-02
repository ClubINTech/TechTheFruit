#ifndef LectureSerie_h
#define LectureSerie_h

#include <HardwareSerial.h>

class LectureSerie {
	public:
		LectureSerie();
		
		void	traitement();
		
	private:
		bool	litEntier(int *);
		bool	litEntierLong(long int *);
		//void	lol(long int *);
};

extern LectureSerie lectureSerie;

#endif
