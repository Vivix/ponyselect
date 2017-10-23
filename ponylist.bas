10 REM Commodore 64 Basic
11 REM PONYLIST
12 REM Because I've never tried Basic (Should work on MZ700 too- maybe)
13 REM Version without episodes or weighted list. (Find out more about extra data for each target machine)
30 ? "Enter ammount seasons"
35 input a1%

38 ? "Enter number of episodes in this season: "
40 for x = 1 to a1%
50 ? "Season" x
55 REM Arrays start on 0 in basic as well, but this should be fine.
60 input a2%(x)
70 next

80 REM We're getting season first, then episode
85 a3%(1) = rnd(1)*(a1% - 1) + 1
86 a3%(2) = rnd(1)*(a2%(a3%(1)) - 1) + 1

81 REM e = rnd(1)*(upper lim - lower lim) + lower lim
90 ? "SEASON", "EPISODE":?a3%(1),a3%(2)

100 input "Reroll?";x$
110 if x$="n" then end
120 goto 85
