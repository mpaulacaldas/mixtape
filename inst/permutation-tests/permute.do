***************************************************************************
* name: risky_sex.do
* author: Scott Cunningham (Baylor) 
* last update: July 1, 2016
***************************************************************************

clear
capture log close

********************************************************************************
*					BEGIN MAJOR REGRESSION LOOP
*
* DESCRIPTION:  Diff-in-diff linear panel models with permutation-based inference
* 				(Buchmueller, DiNardo and Valetta 2011)
* TIME: 		2-3 minutes
********************************************************************************

* Mean outcome values for TX only post-treatment only.
use ../data/txdd.dta, replace
xtset statefip year

* Main Regression loop.
qui tabulate statefip, gen(sdumm)

tempfile txdd
save "`txdd'", replace

* Loop through each state
di "--> START TIME: "c(current_time)

forvalues i=1/50 {

	estimates clear
	local varlist "bmprate wmprate"
	use "`txdd'", replace

	* Loop through each outcome variable
	foreach x of local varlist {

	* Regressions.
		qui xi: reg `x' i.sdumm`i'*i.after crack alcohol income ur poverty black perc1519 aidscapita i.statefip*trend i.year [aweight=pop], robust cluster(statefip)
		qui gen e=e(sample)

	* 1. state fixed effects, year fixed effects only.
		qui xi: reg `x' i.sdumm`i'*i.after, robust cluster(statefip)
		gen `x'1=_b[_IsduXaft_1_1]
		gen `x'_n1=e(N)

	* 2. time-variant controls, state and year fixed effects
	qui xi: reg `x' i.sdumm`i'*i.after crack alcohol income ur poverty black perc1519 aidscapita i.statefip i.year, robust cluster(statefip)
		gen `x'2=_b[_IsduXaft_1_1]
		gen `x'_n2=e(N)

	* 3. time-variant controls, state linear trends, state and year fixed effects
	qui xi: reg `x' i.sdumm`i'*i.after crack alcohol income ur poverty black perc1519 aidscapita i.statefip*trend i.year, robust cluster(statefip)
		gen `x'3=_b[_IsduXaft_1_1]
		gen `x'_n3=e(N)


		di "[`x'] completed"
		drop e
							}
							
di "--> END (state=`i' of 50) time: "c(current_time)

#delimit; 
collapse (mean)
bmprate1-wmprate_n3
;

#delimit cr

gen state=`i'
qui save ../inference/dd/dd_`i'.dta, replace

				}

use ../inference/dd/dd_1.dta, replace
forvalues i=2/50 {				
   append using ../inference/dd/dd_`i'.dta
   				}
   				
qui local end=c(current_time)

gen tx=(state==44)
label variable tx "Texas"

save ../inference/dd/dd_placebo.dta, replace





********************************************************************************
* BEGIN MAIN RESULT TABLES
*
* DESCRIPTION: Use data from major regression loop to create tables with correct
* confidence intervals
********************************************************************************

********************************************************************************
* Tables: Loop
********************************************************************************
estimates clear
local specname=0

local varlist "bmprate wmprate"
	
	foreach x of local varlist {

		forvalues i = 1/3 {
	
		ereturn clear
		tempvar tempsample
		local specname=`specname'+1
	
* Clustered standard errors
		use "`txdd'", replace
		qui xi: reg `x' i.sdumm44*i.after crack alcohol income ur poverty black perc1519 aidscapita i.statefip*trend i.year, robust cluster(statefip)
		qui gen e=e(sample)
		if `i'==1 		{
			qui xi: reg `x' i.sdumm44*i.after i.statefip i.year, robust cluster(statefip)
			estadd ysumm
						}

		else if `i'==2 {			
			qui xi: reg `x' i.sdumm44*i.after crack alcohol income ur poverty black perc1519 aidscapita i.statefip i.year, robust cluster(statefip)
			estadd ysumm
						}

		else if `i'==3 {
			qui xi: reg `x' i.sdumm44*i.after crack alcohol income ur poverty black perc1519 aidscapita i.statefip*trend i.year, robust cluster(statefip)
			estadd ysumm
						}

						
** Inference based confidence intervals

	local specname=`specname'+1
	
* True effect
	use ../inference/dd/dd_placebo.dta, replace
	qui sum `x'`i' if tx==1 			/* get the mean of the variable */
	local beta=r(mean)
	estadd scalar beta=`beta'			/* store this as scalar */

* Count from regression
	local specname=`specname'+1
	qui sum `x'_n`i' if state==44		/* now I use -summarize- */
	local tx_N=r(mean)
	estadd scalar tx_N=`tx_N'			/* store this as a scalar */
		
* percentiles
	qui sum `x'`i' if state!=44, de	/* ditto */
	local p95=r(p95)
	local p5=r(p5)
	estadd scalar p95=`p95'				/* ditto */
	estadd scalar p5=`p5'				/* ditto */

	return list
	estimates store ols_`specname'		/* store these estimates also */

* two-tailed p-values
	qui gen abs`x'`i'=abs(`x'`i')
	qui sort abs`x'`i'
	qui su abs`x'`i' if state==44
	qui count if abs`x'`i' >=r(mean) & state!=44
	qui local p=(`r(N)'/51)
	estadd scalar p=`p'
						}
	


#delimit ;
	cap n estout * using ../tables/dd_`x'.tex, 
		style(tex) label notype
		cells((b(star fmt(%9.3f))) (se(fmt(%9.3f)par))) 		
		stats(beta p5 p95 p tx_N ymean, 
			labels("TX post-1993" "5th percentile" "95th percentile" "Two-tailed test p-value" "N" "Mean of dependent variable")
			fmt(3 3 3 2 0 2))	
		replace noabbrev
		keep(_IsduXaft_1_1)
		varlabels(_IsduXaft_1_1 "TX post-1993")
		title(Estimated effect of TX prison expansion from 1993-1995 on `x')   
		collabels(none) eqlabels(none) mlabels(none) mgroups(none) substitute(_ \_)
		prehead("\begin{table}[htbp]\centering" "\scriptsize" "\caption{@title}" "\begin{center}" "\begin{threeparttable}" "\begin{tabular}{l*{@E}{c}}"
"\toprule"
"\multicolumn{1}{l}{\textbf{Dependent variable:}}&"
"\multicolumn{3}{c}{\textbf{`x'}}\\"
"\midrule"
"\multicolumn{4}{c}{\textbf{Panel A: Clustered SE}}\\")
		posthead("\midrule")
		prefoot("\\" "\midrule" "\multicolumn{4}{c}{\textbf{Panel B: Placebo-based confidence intervals}}\\" "\midrule")  
		postfoot("\midrule"
		"State and year FE 			& Yes 	& Yes 	& Yes 	 \\"
		"Time variant controls 		& No 	& Yes 	& Yes 	 \\"
		"State linear trends 		& No 	& No 	& Yes  	 \\"
		"\bottomrule" "\end{tabular}" "\begin{tablenotes}" "\tiny" "\item State population are used as analytical weights. Time-variant controls include state-level values of total food stamp expenditures, mean of households receiving free lunch, household income, percent aged 15-20 and percent aged 21-30, percent white, percent black, percent of population below poverty line and AIDS mortality rates per 100,000. Panel A presents clustered standard errors and Panel B presents 5th and 95th percentile confidence intervals from placebo-based inferential calculations, and p-values from a two-tailed test based on the share of placebo effects with larger estimates in absolute value than Mississippi. * p$<$0.10, ** p$<$0.05, *** p$<$0.01" "\end{tablenotes}" "\end{threeparttable}" "\end{center}" "\end{table}");
#delimit cr
	cap n estimates clear


* Histogram distributions
su `x'3 if state==44
local tx_mean=float(r(mean))
su `x'3 if state!=44, de
local p5=r(p5)
local p95=r(p95)		

histogram `x'3 if state!=45, bin(30) frequency fcolor(gs12) lcolor(black) ytitle(Frequency) xtitle(Placebo estimates) xline(`tx_mean' `p5' `p95', lpattern(dash) lcolor(red)) title(Placebo `x' sampling distribution) subtitle(Full model) note(Solid vertical bar is TX DD estimate of `tx_mean' and vertical dashed bars are 5th and 95th percentile)
graph save Graph ../figures/inference/`x'.gph, replace
graph export ../figures/inference/`x'.pdf, replace

}


capture log close
exit


