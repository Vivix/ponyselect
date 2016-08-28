::Reconstructed pony.bat - WIN32 - Orig 2014, current 2016
@echo off

for /f "tokens=3" %%G in ('find "" /v /c episodes.txt') do set linecount=%%G

:randomize
set/a dice=((%RANDOM%*6)/32768)+1
set/a line_selected=((%RANDOM%*%linecount%)/32768)

::I am pretty sure I had a cleaner solution to 0 in the original.
if %line_selected% equ 0 (
	for /f "delims=, tokens=1,2" %%G in (episodes.txt) do (
		if %%H lss %dice% echo %%G & goto:_prompt
		goto:randomize
	)
)

for /f "delims=, tokens=1,2 skip=%line_selected%" %%G in (episodes.txt) do (
	if %%H lss %dice% echo %%G & goto:_prompt
	goto:randomize
)

:_prompt
set/p reroll=Reroll?
if [%reroll%] equ [y] goto:randomize
goto:eof
