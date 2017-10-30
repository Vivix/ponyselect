1 REM THIS IS THE RECONSTRUCTION OF
2 REM PONYLIST FROM THE COMMODORE 64
3 REM REWORKED SLIGHTLY TO BE READABLE ON PC
10 ?"========================="
11 ?"| PONYLIST! <3 <3       |"
15 ?"========================="
16 REM ** Open the file on a tape, and go for it.
20 DIM PL$(2,30,1)
30 OPEN 1,1,0 "EPISODES"
40 FOR X=0 TO 2:  REM SHOWS
45 FOR Y=0 TO 200:REM EPISODES
50 FOR Z=0 TO 1:  REM SCORE PLANE! (0 = names, 1 = score)
55 INPUT# 1,PL$(X,Y,Z)
60 NEXT
65 NEXT
70 NEXT
80 CLOSE 1
90 REM **This is just the clean sketch of what was written on the real hardware
91 REM **
100 ?"PRESS E FOR EDIT, OR ANY KEY TO ROLL."
110 GET A1$:IF A1$="E" THEN GOTO 300
120 REM ** DISPLAY BELOW, EDITOR AT 300
125 ?,"NAME"
130 FOR X=0 TO 5
135 IF PL$(X,0,0)<>"" THEN A1$="Y"
137 ?,X PL$(X,0,0)
140 NEXT
150 IF A1$<>"Y" THEN ?"NO SHOWS LOADED, PLEASE EDIT!":GOTO 100
160 ?"WHICH SHOW WOULD YOU LIKE TO ROLL?"
170 GET A1%
171 REM ** SANITY CHECK IN THE FUTURE MAYBE IF WE EVER CARE
200 A2%=(RND(1) * ( VAL(PL$(A1%,0,1)) - 1 ) + 1)
210 IF VAL(PL$(A1%,A2%,1))<(RND(1)*5)+1 THEN ?,PL$(A1%,A2%,0) ELSE GOTO 200
220 ?"REROLL?":GET A1$:IF A1$<>"N" THEN GOTO 200
230 END
300 REM add editor
301 REM e = rnd(1)*(upper lim - lower lim) + lower lim
302 rem THE FILE FORMAT IS A 3D ARRAY! WHERE X = SHOW, Y = EPISODES, Z = SCORE!
303 rem 0 0 1 = episode count
304 rem 0 0 0 = show name 
305 rem 0 1 0 = name of episode 1
306 rem 0 2 0 = name of episode 2
307 rem 0 1 1 = score of episode 
308 rem 0 2 1 = score of episode 2
