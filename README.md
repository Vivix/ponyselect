# ponyselect
*	windows batch			original
*	powershell			finished
*	zsh				unfinished
*	portable c			lost,unstable
*	16bit x86			unstable
*	6510				unfinished
*	mz-700 z80			unfinished

list format:

> item,weight

item is anything except a , (might hit other sensitive characters in certain languages)
weight is 0-6, which rank how wanted the item is. 6 being never chosen, and 0 always chosen when picked. The selector will 'roll a dice' against the weight of its selected line, and if it rolls under the number, will display the item and ask wether or not to reroll.
