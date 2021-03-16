#include <htc.h>
#define _XTAL_FREQ 4000000

unsigned char i,N,x,pct=32,nr=20,pct_maxim=100;
//signed char i;
const unsigned int table[50] = 
{5,10,15,19,23,26,28,30,31,32,31,30,28,26, 23,19,15,10,5,0};

void main(void)
{	TRISB = 0b11100011;

	while(1)
	{	//triunghi cresc
		N=10;
		for (i=0; i<=N; i++)
		{	//for(x=1; x<=i; x++)
			for(x=i; x>0; x--)
			{ RB2=1; __delay_ms(0.1); }
			for(x=N-i; x>0; x--)
			{ RB2=0;__delay_ms(0.1); }
	}
		//triunghi descrescator 
		for (i=1; i<=N-1; i++)
		{	//for(x=1; x<=i; x++)
			for(x=N-i; x>0; x--)
			{ RB2=1; __delay_ms(10); }
			for(x=i; x>0; x--)
			{ RB2=0; __delay_ms(10); }
		}

//----------forma trapez------
	//TRAPEZ CRESC.
	for (i=0; i<=N; i++)
		{	//for(x=1; x<=i; x++)
			for(x=i; x>0; x--)
			{ RB3=1; __delay_ms(10); }
			for(x=N-i; x>0; x--)
			{ RB3=0; __delay_ms(10); }
		}
//forma trapez platou
	for(x=pct_maxim; x>0; x--){
	{ RB3=1; __delay_ms(10); }	//sta 100*10ms=1s in 1
}
//forma trapez descrescator 
	for (i=1; i<=N-1; i++)
		{	//for(x=1; x<=i; x++)
			for(x=N-i; x>0; x--)
			{ RB3=1; __delay_ms(10); }
			for(x=i; x>0; x--)
			{ RB3=0;__delay_ms(10);}
		}


//x=factor de umplere
//N=nr de puncte pe panta cresc/descresc
//pct =32, pct repre valoarea maxima a sinusului ;a 90grade
//sta in 1 logic p iteratii , 0 logic pct - p iteratii

//generare sinus
	for (i=0; i<nr; i++)
		{	
	for(x=table[i]; x>0; x--)//table[i] apeluri in "1" logic
		{ RB4=1; __delay_ms(10); }
			for(x=pct-table[i]; x>0; x--)
		{
RB4=0; __delay_ms(10); }	//pct-table[i] apeluri in "0" logic
		}
}
}


