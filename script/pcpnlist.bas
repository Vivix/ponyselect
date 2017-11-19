1 REM This is the PC-BASIC conversion from commodore
10 COLOR 10,0:PRINT"██████";:COLOR 10,0:PRINT"███";:COLOR 2,0:PRINT"██████████";:COLOR 11,0:PRINT"P█O█N█Y█L█I█S█T█!█████████████████████████▀";:COLOR 10,0:PRINT"█████";:COLOR 11,0:PRINT"██████████■▀"
16 REM *** Open episodes.txt. We are using a modified version of the original!
17 REM File is name<crlf>score to make this as easy as possible.
18 REM Both to make the file, and use it! IMMA BASIC NOOB YA'LL
30 OPEN "I",1,"episodes.txt"
40 DIM PL$(200,1)
45 COLOR 0,5
50 FOR X=1 TO 200
55 IF EOF(1)<>0 THEN GOTO 90
60 LINE INPUT# 1,PL$(X,0)
70 LINE INPUT# 1,PL$(X,1)
75 PRINT CHR$(176+((VAL(PL$(X,1))/2)-1));
80 NEXT
85 CLOSE 1
90 COLOR 7,0:PRINT
95 PRINT X "entries found!"
125 PRINT"episode","dice"
126 DC%=RND(VAL(RIGHT$(TIME$,2))-60)
130 DC%=RND(1)*(6 - 1) + 1
140 REM X should still exist as items*2
150 EP%=RND(1)*((X/2)-1)+1
155 PRINT EP%,DC%
160 IF DC%<VAL(PL$(EP%,1)) THEN GOTO 130
170 PRINT PL$(EP%,0)
180 INPUT "Reroll?",A1$:IF A1$<>"n" GOTO 130
190 END
301 REM e = rnd(1)*(upper lim - lower lim) + lower lim
302 REM Fileformat is pl$(x,y) where x is episode number, and y is
303 REM 0 = NAME, 1 = SCORE
