
* set the main folder directory
cd "C:\Users\elias\OneDrive\Documents\UND\SPRING 2026\ECON 997\Datasets"

* I. IMPORT RETURNS DATA (Index Price Data)

import excel "C:\Users\elias\OneDrive\Documents\UND\SPRING 2026\ECON 997\Datasets\main data.xlsx", ///
    sheet("Prices") firstrow clear

* Ensure date is formated properly
format Date %td

* Give variables a common stub
rename (prices_US prices_UK prices_AU prices_CAN ) ///
       (index_US index_UK index_AU index_CAN)

* Convert the data from Wide to Long format to ensure returns are calculated properly
reshape long index_, i(Date) j(country) string

* Clean variable name
rename index_ value

* Encode and set time
encode country, gen(id)
sort country Date
xtset id Date

* Drop missing values
drop if missing(value)

* Generate percentage returns by country
sort country Date
by country: gen ret = 100*(ln(value) - ln(value[_n-1]))

* Generate 2-day rolling average returns by country
sort country Date
by country: gen ret_2day = (ret + ret[_n-1])/2

* Drop initial missing returns
drop(ret country value)
// drop if missing(ret_2day)

** Reshape back to wide
sort id Date
reshape wide ret_2day, i(Date) j(id) 

* rename to make it easier to distinguish
// rename ret_2day1 return_Netherlands
// rename ret1 ret_Australia
// rename ret2 ret_Canada
// rename ret3 ret_US
// rename ret4 ret_Canada
rename ret_2day1 Australia_ret
rename ret_2day2 Canada_ret
rename ret_2day3 UK_ret
rename ret_2day4 US_ret
// rename ret_2day6 return_HongKong
// rename ret_2day7 return_Japan

* Keep only common trading days across all markets
drop if missing(Australia_ret, Canada_ret, UK_ret, US_ret)

* save file
save "clean_2days_returns.dta", replace


****************************************************
* II. IMPORT T-BILL / INTEREST RATE DATA
****************************************************

import excel "C:\Users\elias\OneDrive\Documents\UND\SPRING 2026\ECON 997\Datasets\main data.xlsx", sheet("Short-term interest Rates daily") firstrow clear

* format the date
format Date %td

* rename 
rename Australia_3M_Bank_Accepted_Bill	australia_rate
rename Canada_3mtbill	canada_rate
rename UK_3mbond_yield	uk_rate
rename US_3MTBILLYIELD us_rate


*save it
save "clean_interest_rates.dta", replace


* III. MERGE RETURNS WITH INTEREST RATES

use "clean_2days_returns.dta", clear

merge 1:1 Date using "clean_interest_rates.dta"

* Keep only matched date
keep if _merge==3
drop _merge
drop if missing(australia_rate, canada_rate, uk_rate, us_rate, Australia_ret, Canada_ret, UK_ret, US_ret)

* FINAL TS DECLARATION FOR VAR
save "final_dataset.dta", replace
