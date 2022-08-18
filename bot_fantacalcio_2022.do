 set seed 610
 clear all
 set more off
 
 global path /Users/aledinal/Dropbox/Mac/Downloads
 
 import excel "$path/Quotazioni_Fantacalcio_Stagione_2022_23.xlsx", sheet("Tutti") firstrow clear
 
 rename QuotazioniFantacalcio id
 rename B role
 rename D nome
 rename E squadra
 rename F quotazione
 drop if _n<2
 keep id role nome squadra quotazione
 
 *-------------------------------------------------*
 *   Seleziona giocatori con una certa quotazione  *
 *-------------------------------------------------* 
  gen random=runiform()

  
  sort role quotazione
  gen valore = .
  forvalues i = 1/50{
replace valore = `i' if quotazione == "`i'"
}
 
 * Players' selection based on mkt value
 drop if valore <= 4 & role == "P"
 drop if valore <= 6 & role == "D"
 drop if valore <= 7 & role == "C"
 drop if valore <= 8 & role == "A"  

 sort role valore

 sort role random
 by role: gen n=_n
 
 gen n_player=.
 replace n_player=3 if role=="P"
 replace n_player=8 if role=="D"
 replace n_player=8 if role=="C"
 replace n_player=6 if role=="A"
 
 keep if n<=n_player
 drop random n
 
 *player selected 
 *******************************************************************************
 
 gen random=runiform()
 
 *Minimum prezzo
 gen prezzo=1
 
 *300 minus the minimum of the bid 25
 gen tot_soldi=275
 
 *This assumes that MAX you bid on 1 player 150 M (max of last year auction)
 gen     temp= . 
 replace temp= random*3.5*valore if role == "A"
 replace temp= random*1.2*valore if role == "C"
 replace temp= random*valore/2   if role == "D"  
 replace temp= random*valore/4   if role == "P"   
 *This automatically sort attaccanti, centro, dif, port
 sort role random
 gen n=_n
 
 * Attaccanti
 foreach count of numlist 1(1)6 {
 replace prezzo=prezzo+temp if n==`count' & temp<tot_soldi
 replace prezzo=tot_soldi 	if n==`count' & temp>=tot_soldi
 replace prezzo=int(prezzo)
 gen x=prezzo if n==`count'
 egen xx=max(x)
 replace tot_soldi=tot_soldi-xx+1
 drop x xx 
 }

* Altri
 foreach count of numlist 7(1)25 {
 replace prezzo=prezzo+temp if n==`count' & temp<tot_soldi
 replace prezzo=tot_soldi 	if n==`count' & temp>=tot_soldi
 replace prezzo=int(prezzo)
 gen x=prezzo if n==`count'
 egen xx=max(x)
 replace tot_soldi=tot_soldi-xx+1
 drop x xx 
 } 

 
 egen tot = sum(prezzo)
 /*
 He always spend 299, and keep 1M for christmas
 keep id role nome squadra prezzo
 */
