* @owner Elias Nkuansambo
* Final Code: Extension (Forbes–Rigobon) PART 4 (Post Covid-era)

use "https://raw.githubusercontent.com/enkuansa/Financial-Contagion-Project/main/extension_final_dataset_1995%2B.dta", clear

format Date %td
sort Date

* 1. Further data cleaning
foreach v in usa_3mtb uk_3mtb australia_rates canada_3mtb hongkong_rate germany_3mtb france_3mtb japan_rate swizterland_3mtb netherlands_3mtb {
    replace `v' = . if `v'==0 // replace zeroes with missing values 
    replace `v' = `v'[_n-1] if missing(`v') // replace missing values with the prior day's value on the list.
}

drop if missing(australia_ret_2day, canada_ret_2day, france_ret_2day, germany_ret_2day, hongkong_ret_2day, japan_ret_2day, netherlands_ret_2day, switzerland_ret_2day, uk_ret_2day, us_ret_2day, usa_3mtb, uk_3mtb, australia_rates, canada_3mtb, hongkong_rate, germany_3mtb, swizterland_3mtb, france_3mtb, japan_rate, netherlands_3mtb, netherlands_ret_2day, france_ret_2day, japan_ret_2day) // drop any missing values that may be in the data still except for rates for Japan, Netherlands, and France

* 2. Make new time var to better control the VAR model and pass over the calendar gaps. This ensure less observations from being removed when the model is run.
gen long t = _n // create time
tsset t // set time


* 3. Define some local parameters
* 3.1 Test parameters
* Since we will use both fisher z-test and a transformed t-test, the critical values giventhe number of observations will be essentially the same, apporaching a Normal distribution

local alpha = 0.05 // significance level
local crit  = invnormal(1-`alpha') // This enables us to make

* 3.2 Let's define the time windows properly to be used to filter data later
* These dates or period markers are defined by the authors (Forbes and Rigobon)
local stable_start  = td(01jan2021)
local stable_end    = td(01jan2022)
local turmoil_start = td(02jan2022) // S&P500 peak
local turmoil_end   = td(31dec2022) // S&P500 trough point (October 12, 2022) but extended to June to capture lingering effects
local full_start    = `stable_start'
local full_end      = `turmoil_end'


* 3.3 Let's define the lag paremeters as well.

local p = 5
local q = 5


* 3.4 Lists of countries with respective returns and interest rates organized locally.
/* Each position across macros corresponds to one country:
	cnames - country's name
	rets   - return variable name
	rates  - short-term interest rate variable name
	The Netherlands is excluded because they do not have data for interest rates prior to 2010
*/

local cnames "Australia Canada France Germany HongKong Japan Netherlands Switzerland UK"

local rets   "australia_ret_2day canada_ret_2day france_ret_2day germany_ret_2day hongkong_ret_2day japan_ret_2day netherlands_ret_2day switzerland_ret_2day uk_ret_2day"

local rates  "australia_rates canada_3mtb france_3mtb germany_3mtb hongkong_rate japan_rate netherlands_3mtb swizterland_3mtb uk_3mtb"

local K : word count `cnames' // Keeps the count of the number of vars in cname

* 4. Run a loop over the three countries with US, making pairs

forvalues i = 1/`K' {
	// Loop variables
    local cname : word `i' of `cnames'
    local rj    : word `i' of `rets'
    local ij    : word `i' of `rates'

    capture drop eUS eJ // quietly searches if eUS or eJ have not been dropped, and it drops them.

    
    * 4.1 Estimate VAR only ONCE on FULL window and compute residuals
    preserve
        keep if inrange(Date, `full_start', `full_end') // define the time constraint
        tsset t // define the time as t inseatd of Date so that VAR can run with the max number of obs avalibale in this set

        qui var us_ret_2day `rj', lags(1/`p') exog(L(1/`q').usa_3mtb L(1/`q').`ij')  // run the var model as described by Forbes and Rigobon.

        predict double eUS, resid equation(us_ret_2day) // predict the residuals for the US
        predict double eJ,  resid equation(`rj') // predict the residuals for the another country

        
        * 4.1 CONDITIONAL Correlations(rho*) and standard errors (sigma*) by the different periods (filtered by Date)
			/* The steps are repeated. For each period, we get a correlations 
				matrix, the number of observations, and compute a cross-country 
				correlation value and its respective sigma.
			*/
			
        * Stable
       qui corr eUS eJ if inrange(Date, `stable_start', `stable_end'), covariance // get the variance matrix
        matrix SigS = r(C)		// store the matrix results
        scalar rhoS_cond = SigS[1,2] / sqrt(SigS[1,1]*SigS[2,2]) // conditional correlation for the stable period
        scalar varUS_S   = SigS[1,1] // variance of the US
       qui corr eUS eJ if inrange(Date, `stable_start', `stable_end')
        scalar nS = r(N) // get the number of observations in this period
        scalar sigS_cond = (1 - rhoS_cond^2) / sqrt(nS - 1)	// conditional standard error for the correlation for the stable period

        * Turmoil
       qui corr eUS eJ if inrange(Date, `turmoil_start', `turmoil_end'), covariance // run to get the covariance matrix
        matrix SigT = r(C) // capture the covariance matrix
        scalar rhoT_cond = SigT[1,2] / sqrt(SigT[1,1]*SigT[2,2]) // conditional correlation for the turmoil period
        scalar varUS_T   = SigT[1,1] // variance of the US in times of turmoil
       qui corr eUS eJ if inrange(Date, `turmoil_start', `turmoil_end') // run to get the correlation between the error terms
        scalar nT = r(N) // number of observation for the turmoil period
        scalar sigT_cond = (1 - rhoT_cond^2) / sqrt(nT - 1) // conditional standard error for the correlation for the turmoil period

        * Full
       qui corr eUS eJ if inrange(Date, `full_start', `full_end'), covariance // run to get the covariance matrix
        matrix SigF = r(C) // capture the covariance matrix
        scalar rhoF_cond = SigF[1,2] / sqrt(SigF[1,1]*SigF[2,2]) // conditional correlation for the full period
       qui corr eUS eJ if inrange(Date, `full_start', `full_end') // run to get the correlation between the error terms
        scalar nF = r(N) // number of observation for the full period
        scalar sigF_cond = (1 - rhoF_cond^2) / sqrt(nF - 1) // conditional standard error for the correlation for the full period

        * 4.2 UNCONDITIONAL (Adjusted) Correlations(rho*) and standard errors (sigma*) by the different periods (filtered by Date)
        scalar delta = (varUS_T/varUS_S) - 1 // compute the delta value use in Forbes equation 11
		
		// compute the adjustments for the correlation values in each time period
        scalar rhoS_uncond = rhoS_cond / sqrt(1 + delta*(1 - rhoS_cond^2)) // unconditional correlation for the stable period
        scalar rhoT_uncond = rhoT_cond / sqrt(1 + delta*(1 - rhoT_cond^2)) // unconditional correlation for the turmoil period
        scalar rhoF_uncond = rhoF_cond / sqrt(1 + delta*(1 - rhoF_cond^2)) // unconditional correlation for the full period

        scalar sigS_uncond = (1 - rhoS_uncond^2) / sqrt(nS - 1) // conditional standard error for the correlation for the stable period
        scalar sigT_uncond = (1 - rhoT_uncond^2) / sqrt(nT - 1) // conditional standard error for the correlation for the turmoil period
        scalar sigF_uncond = (1 - rhoF_uncond^2) / sqrt(nF - 1) // conditional standard error for the correlation for the full period

        
        * 4.3 Fisher z-tests (Turmoil - Full)
        scalar zT_c = 0.5*ln((1+rhoT_cond)/(1-rhoT_cond)) // convert the turmoil period correlation to a fisher z-value
        scalar zF_c = 0.5*ln((1+rhoF_cond)/(1-rhoF_cond)) // convert the full period correlation to a fisher z-value
        scalar testF_cond = (zT_c - zF_c) / sqrt(1/(nT-3) + 1/(nF-3)) // make a test-statistic with the fisher z-value for the conditional table

        scalar zT_u = 0.5*ln((1+rhoT_uncond)/(1-rhoT_uncond)) // convert the turmoil period correlation to a fisher z-value for unconditional table
        scalar zF_u = 0.5*ln((1+rhoF_uncond)/(1-rhoF_uncond)) // convert the full period correlation to a fisher z-value for unconditional table
        scalar testF_uncond = (zT_u - zF_u) / sqrt(1/(nT-3) + 1/(nF-3)) // make a test-statistic with the fisher z-value for the unconditional table

        
        * 4.4 t-tests using sigma columns
			* This is a tranformed t-test to account for the hypothesis testing, 
			* which is not H0: rho* = 0, but H0: rho* > rho_T
        
        scalar testT_cond   = (rhoT_cond   - rhoF_cond)   / sqrt(sigT_cond^2   + sigF_cond^2) // t-test statistic for conditional correlation
        scalar testT_uncond = (rhoT_uncond - rhoF_uncond) / sqrt(sigT_uncond^2 + sigF_uncond^2) // t-test statistic for unconditional correlation

        
        * 4.5 Contagion flags
		/* It will compute values only if the values are test conditions are 
			not missing. It will ensure the code will not break down easily if 
			the data is changed somehow.
		*/
        scalar C_F_cond   = !missing(testF_cond) & (testF_cond   > `crit') // Fisher z- test conditions for the conditional table
        scalar C_F_uncond = !missing(testF_uncond) & (testF_uncond > `crit') // Fisher z- test conditions for the unconditional table
        scalar C_T_cond   = !missing(testT_cond) & (testT_cond   > `crit') // t-test conditions for the conditional table
        scalar C_T_uncond = !missing(testT_uncond) & (testT_uncond > `crit') // t-test conditions for the unconditional table

        
        * 4.6 Display the Tables
			* Here we organize everything into a table for better reading of the results
        display "---------------------------------------------------------"
        display "PAIR: US–`cname' (ONE VAR estimated on FULL period)"
        display "----------------TABLE 1 (Conditional) ------------------"
        display "Stable : rho*=" rhoS_cond "  sigma*=" sigS_cond "  N=" nS
        display "Turmoil: rho*=" rhoT_cond "  sigma*=" sigT_cond "  N=" nT
        display "Full   : rho*=" rhoF_cond "  sigma*=" sigF_cond "  N=" nF
        display "Fisher (cond): stat=" testF_cond " Therefore, Contagion ? " cond(C_F_cond, "C", "N")
        display "t-test (cond): stat=" testT_cond " Therefore, Contagion ? " cond(C_T_cond, "C", "N")

        display "--------------- TABLE 2 (Unconditional adjusted)----------"
        display "delta = " delta
        display "Stable : rho =" rhoS_uncond "  sigma =" sigS_uncond
        display "Turmoil: rho =" rhoT_uncond "  sigma =" sigT_uncond
        display "Full   : rho =" rhoF_uncond "  sigma =" sigF_uncond
        display "Fisher (uncond): stat=" testF_uncond " Therefore, Contagion ? " cond(C_F_uncond, "C", "N")
        display "t-test (uncond): stat=" testT_uncond " Therefore, Contagion ? " cond(C_T_uncond, "C", "N")
    restore
}
