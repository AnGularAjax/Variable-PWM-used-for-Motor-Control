#include p16f84a.inc
i	equ 0x20	;i=0...N pentru triunghi/trapez
N	equ 0x21	;Nr de tranzitii
x	equ 0x22	;folosit pentru generarea factorului de umplere
j	equ 0x23	;il folosim in bucla pentru generare delay
k	equ 0x24	;il folosim pentru calcularea delay-ului de 10ms
p	equ 0x25    ;p retine factorul de umplere din subrutina puncte_sin
pct equ d'32'	;punctul maxim al sinusului la 90 grade 
n 	equ 0x26    ;n reprezinta factorul de umplere al sinusului
main:
	BCF STATUS,RP1
	BSF STATUS,RP0	;{01}-bank1
	MOVLW B'11100011'	;lasam activ doar RB2
	MOVWF TRISB
	BCF STATUS,RP1
	BCF STATUS,RP0	;{00}- BANK0

cresc_tri:
	MOVLW D'10'
	MOVWF N	;N=10 , nr de tranzitii pe panta cresc/descresc
	CLRF i	;stergem i-ul pentru a incepe iteratia
cresc_tri_1:	;stam i apeluri in "1"

	MOVF i,0	;acc=i, actualizare Z
	BTFSC STATUS,Z	;testez bitul Z
	GOTO cresc_tri_0 ;Z==0, skip GOTO
	MOVWF x	;x=w(acc)=i=>x=i
	BSF PORTB,2		 
	;x=acc=i
	CALL delay_x

cresc_tri_0:	;stam N-i apeluri in "0"
	MOVF i,0
	SUBWF N,0	;acc=N-i
	BTFSC STATUS,Z
	GOTO desc_tri  ;i==N, Z=1
	MOVWF x		;x=N-i
	BCF PORTB,2	   ;i~=N, Z=0
	CALL delay_x
	INCF i,1	;i++ => creste numarul de apeluri in 1
	GOTO cresc_tri_1


desc_tri: 	;este la fel ca la panta crescatoare
;doar ca generat in sens invers
clrf i	;stergem i-ul pentru a incepe panta descrescatoare
desc_tri_0:		;i apeluri in 0
	MOVF i,0	;acc=i, actualizare Z
	BTFSC STATUS,Z	;Z==0, skip goto
	GOTO desc_tri_1 ;i==0, Z=1 =>N-i=N-0 apeluri in "1"
	MOVWF x		;x=acc=i
	BCF PORTB,2		
	CALL delay_x

desc_tri_1:	;N-i apeluuri in 1
	MOVF i,0	;i=w(acc)
	SUBWF N,0	;acc=N-i
				;stam in bucla de N-i ori
	BTFSC STATUS,Z
	GOTO trapez_cresc  ;i==N, Z=1, sari la trapez
	MOVWF x		;x->w->N-i
	BSF PORTB,2	   ;i~=N, Z=0
	CALL delay_x	;producem delay-ul de x ori
	INCF i,1	;incrementam i pana la N
	GOTO desc_tri_0

;GENERARE TRAPEZ-la fel cu triunghiul, diferenta fiind ca sta 
;un timp mai indelungat (1s) in punctul maxim
;intarzierea se face pe portul RB2
trapez_cresc:
clrf i
cresc_trap_1	;i apeluri in 1 logic
	MOVF i,0	;acc=i, actualizare Z
	BTFSC STATUS,Z
	GOTO cresc_trap_0 ;i==0, Z=1
	MOVWF x		;x=acc=i
	BSF PORTB,2	 ;i~=0, Z=0
	CALL delay_x
cresc_trap_0	;N-i apeluri in 0 logic
	MOVF i,0
	SUBWF N,0	;acc=N-i
	BTFSC STATUS,Z
	GOTO platou_trapez  ;i==N, Z=1
	MOVWF x		;x=N-i
	BCF PORTB,2	   ;i~=N, Z=0
	CALL delay_x

	INCF i,1
	GOTO cresc_trap_1


; Deosebirea fata de triunghi consta ca "punem"
; semnalul in 1 logic timp de 1s in punctul maxim
platou_trapez:
movlw d'100'
movwf x	;x<-100
bsf PORTB,2
CALL delay_x	;generam 100*10ms=1s delay
bcf PORTB,2
CALL delay_10ms ; lasam un delay de 10ms inainte de panta descresc.


;descrescator
;panta descrescatoare a trapezului
desc_trap:
clrf i	;stergem i sa nu ramana valoarea veche 
desc_trap_0	;i apeluri in 0 logic
	MOVF i,0	;acc=i, actualizare Z
	BTFSC STATUS,Z
	GOTO desc_trap_1 ;i==0, Z=1
	MOVWF x		;x=acc=i
	BCF PORTB,2	 ;i~=0, Z=0
	CALL delay_x



desc_trap_1		;N-i apeluri in 1 logic
	MOVF i,0
	SUBWF N,0	;acc=N-i
	BTFSC STATUS,Z
	goto loop_sin  ;i==N, Z=1 , genereaza panta crescatoare, sin
	MOVWF x		;x=N-i
	BSF PORTB,2	   ;i~=N, Z=0
	CALL delay_x
	INCF i,1
	GOTO desc_trap_0

;;;generare sin

;generare sinus, panta crescatoare


loop_sin:

	CLRF i	;stergem i-ul pentru a incepe iteratia
	MOVLW D'0' 
	MOVWF n ;n il punem in 0 astfel ca la primul apel
;al functiei puncte_sin, PCL+n sa ia prima valoare
loop_sin_1:	;genereaza p apeluri in "1" logic
	INCF n,1;atunci cand ajunge in punctul maxim 32
;ne reintoarcem in loop_sin_1 si pt a nu genera de 2 ori
;in acelasi punct,incrementam n-ul de la inceput
	MOVF n,0
	CALL puncte_sin	;la intoarcerea din apel, va avea
;incarcat in acumulator valoarea n corespunzatoare punctelor
;sinusului
	MOVWF p	;din acc, salvam val. in p, pentru ca reprezinta
	;factorul de umplere de pe panta cresc.
 
	MOVF p,0 ;acc<-acc
	BTFSC STATUS,Z
	GOTO loop_sin_0 ;i==0, Z=1
	MOVWF x		;
	BSF PORTB,2		 ;i~=0, Z=0
	CALL delay_x
loop_sin_0:
	MOVF p,0	
	SUBLW pct	;vom genera pct-p apeluri in 0 logic
	BTFSC STATUS,Z
	GOTO loop_sin_1  ;i==N, Z=1
	MOVWF x	
	BCF PORTB,2	   ;i~=N, Z=0
	CALL delay_x
		
	MOVF p,0
	BTFSC STATUS,Z	;daca p=0=> a ajuns la final
	GOTO cresc_tri	;dupa ce am terminat generarea sinusului
	;ne intoarcem la inceput
	GOTO loop_sin_1

;{0,5,10,15,19,23,26,28,30,31,32,31,30,28,26, 23,19,15,10,5,0};
;PCL - program counter pe octetul de low 

puncte_sin: ; aici pastram pct. sinusului pentru o accesare
;facila.
addwf PCL
retlw d'0'	;am luat 21 de puncte deoarece n-ul se incrementeaza la inceput
retlw d'5'
retlw d'10'
retlw d'15'
retlw d'19'
retlw d'23'
retlw d'26'
retlw d'28'
retlw d'30'
retlw d'31'
retlw d'32'
retlw d'31'
retlw d'30'
retlw d'28'
retlw d'26'
retlw d'23'
retlw d'19'
retlw d'15'
retlw d'10'
retlw d'5'
retlw d'0'





delay_x:
	CALL delay_10ms
	DECFSZ x,1	;(8+(5k+4)j+2+1+2)x-1+2=(13+(5k+4)j)x+1
	GOTO delay_x
	RETURN



delay_10ms:
movlw d'10'		;init(j)=2cm
movwf j

loop_k:			;init(k)=2cm
movlw d'199'
movwf k

Loop_10ms:
NOP		;2nop=2cm
NOP
decfsz k,1	;1(2)cm-> 2cm cand k=0 =>skip GOTO
;(2+1+2)k-1+2+1+2)j=(5k+4)j
;BSF+CALL+init(k)+init(j)+delay_10ms+return=1+2+2+2+(5k+4)j+2-1=
;8+(5k+4)j=8+(5*199+4)*10=9998cm aprox 10ms
goto Loop_10ms	;2cm
decfsz j,1	;1(2)cm
goto loop_k

RETURN ;+2cm =>9998 + 2cm =>10ms
NOP
end	
