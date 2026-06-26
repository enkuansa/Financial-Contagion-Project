
* set the main folder directory
cd "C:\Users\elias\OneDrive\Documents\UND\SPRING 2026\ECON 997\Datasets"

* I. Cleaning the index price data

import excel "C:\Users\elias\OneDrive\Documents\UND\SPRING 2026\ECON 997\Datasets\wide_format_extension_stock_price_data.xlsx", ///
    sheet("price") firstrow clear

* Ensure date is formated properly
format Date %td
tsset Date

* Rename and Re-label
rename AEX price_netherlands
label variable price_netherlands "Netherlands"

rename GDAXI price_germany
label variable price_germany "Germany"

rename AORD price_australia
label variable price_australia "Australia"

rename FCHI price_france
label variable price_france "France"

rename FTSE price_uk
label variable price_uk "UK"

rename  GSPC price_us
label variable price_us "USA"

rename  NASDAQ price_usNASDAQ
label variable price_usNASDAQ "USA NASDAQ"

rename GSPTSE price_canada
label variable price_canada "Canada"

rename HSI price_hongkong 
label variable price_hongkong "Hong Kong"

rename N225 price_japan
label variable price_japan "Japan"

rename SSMI price_switzerland
label variable price_switzerland "Switzerland"

* simple plot
local ticks `=td(01jan1990)' `=td(01jan1995)' `=td(01jan2000)' `=td(01jan2005)' ///
            `=td(01jan2010)' `=td(01jan2015)' `=td(01jan2020)' `=td(01jan2025)'
twoway ///
    line price_* Date, ///
    xlabel(`ticks', format(%tdCCYY) angle(0)) ///
    xscale(range(`=td(01jan1990)' `=td(31dec2026)')) ///
    xtitle("Year") ///
    ytitle("Price Level") ///
    legend(cols(1))

** Convert the data from Wide to Long format
reshape long price_, i(Date) j(country) string

* Clean variable name
rename price_ value

* Sort properly
sort country Date

* Drop missing values
drop if missing(value)

* Generate percentage returns by country
by country: gen ret = 100*(ln(value) - ln(value[_n-1]))

* Generate 2-day rolling average returns by country
by country: gen ret_2day = (ret + ret[_n-1])/2

* Keep only what you need before reshaping back
keep Date country ret_2day

* Reshape back to wide using country names
reshape wide ret_2day, i(Date) j(country) string

rename ret_2day* *_ret_2day


* Plot the log-returns
twoway ///
    line *_ret_2day Date, ///
    xlabel(`ticks', format(%tdCCYY) angle(0)) ///
    xscale(range(`=td(01jan1990)' `=td(31dec2026)')) ///
    xtitle("Year") ///
    ytitle("log returns ( in %)") ///
    legend(cols(1))
	
* Keep only common trading days across all markets
drop if missing(australia_ret_2day, canada_ret_2day, france_ret_2day, ///
                germany_ret_2day, hongkong_ret_2day, japan_ret_2day, ///
                netherlands_ret_2day, switzerland_ret_2day, ///
                uk_ret_2day, us_ret_2day, usNASDAQ_ret_2day)

* save file
save "extension_ret2day_data.dta", replace


* II. Cleaning the interest rate data

import excel "C:\Users\elias\OneDrive\Documents\UND\SPRING 2026\ECON 997\Datasets\wide_format_extension_stock_price_data.xlsx", sheet("rates") firstrow clear

* format the date
format Date %td
destring japan_rate, replace force

*save it
save "extension_interest_rates.dta", replace


* III. MERGE RETURNS WITH INTEREST RATES

use "extension_ret2day_data.dta", clear

merge 1:1 Date using "extension_interest_rates.dta" // merge files

* Keep only matched date
keep if _merge==3
drop _merge
keep if Date >= td("01jan1995")

// drop if missing(australia_ret_2day, canada_ret_2day, france_ret_2day, ///
//                 germany_ret_2day, hongkong_ret_2day, japan_ret_2day, ///
//                 netherlands_ret_2day, switzerland_ret_2day, ///
//                 uk_ret_2day, us_ret_2day, ///
//                 usa_3mtb, uk_3mtb, australia_rates, canada_3mtb, ///
//                 hongkong_rate, germany_3mtb, france_3mtb, ///
//                 japan_rate, swizterland_3mtb, netherlands_3mtb)

* FINAL TS DECLARATION FOR VAR
save "extension_final_dataset_1995+.dta", replace




