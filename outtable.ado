program define outtable
	syntax varlist, over(varname) by(varlist) to(str) [fileTYPe(str) SVY]
	version 11

{/*Preliminary stuff*/
local namecount = wordcount("`by'")
local varcount =  wordcount("`varlist'")

*Find out how many levels of `over' there are
preserve
	local thisvar : word 1 of `varlist'
	collapse `thisvar', by(`over')
	quietly: drop if `over'==.
	mkmat `over'
	local levels = _N
	
	*Save levels in mata matrix
	local levellist ""
	local levellabellist ""
	quietly: decode `over', gen(`over'2)
	
	forvalues i = 1/`levels' {
		local locallevel = `over' in `i'
		local levellist = "`levellist',`locallevel'"
		local locallevel = `over'2 in `i'
		local levellabellist = `"`levellabellist',"`locallevel'""'
	}
	
	*Cut off first comma and save in matrix
	local strlength = length(`"`levellist'"')
	local levellist = substr(`"`levellist'"',2,`strlength')
	
	local strlength = length(`"`levellabellist'"')
	local levellabellist = substr(`"`levellabellist'"',2,`strlength')

	mata: levellabels = (`levellabellist')
	mata: levelvalues = (`levellist')
restore

*Find strata
preserve
	local thisvar : word 1 of `varlist'
	collapse `thisvar', by(`by')	
	forvalues i=1/`namecount' {
		local thisvar : word `i' of `by'
		quietly: drop if `thisvar'==.
	}
	local stratacount = _N
restore

*Generate subpop variables
decode `over', gen(`over'2)
forvalues i = 1/`levels' {
	mata: st_local("name", levellabels[1,`i'])
	quietly: gen level`i' = 1 if `over'2 == "`name'"
}
drop `over'2

*Create blank dataset to store table in
preserve
	keep `by'
	quietly: gen str222 subtest = ""
	quietly: keep if 0
forvalues i = 1/`levels'{
	mata: st_local("name", levellabels[1,`i'])
	quietly: gen mean_`name' = .
	quietly: gen sd_`name' = .
	quietly: gen count_`name'=.
}

save "C:\Program Files\Stata11\ado\base\t\TEMP outtable master.dta", replace
restore
}
*for each level, generate summary stats of each subtest	
forvalues j=1/`levels'{
	mata: st_local("name", levellabels[1,`j'])
	forvalues i=1/`varcount'{
		preserve
		*Find the mean, sd, and n of each summary stat - store in using data
		local thisvar : word `i' of `varlist'
		local inmatrix = 0 // Which element in the matrix will correspond to the kth strata (this is for if the preceding stratas had missing values)
		quietly: drop if level`j'!=1
		sort `thisvar'
		
		if `thisvar' != . in 1 {
			if "`svy'"!=""{
				quietly: svy: mean `thisvar', over(`by')
			}
			else {
				quietly: mean `thisvar', over(`by')
			}
		}
		*Make dataset have one person in each stratum
		by `by', sort: gen unique = _n
		quietly: drop if unique != 1
		keep `by' `thisvar'
		quietly: gen str20 subtest = "`thisvar'"
		quietly: gen mean_`name' = .
		quietly: gen sd_`name' = .
		quietly: gen count_`name'=.
		
		forvalues k=1/`stratacount'{				
						
			//Find out if strata didn't take this section of the test. if so, skip over them.
			if `thisvar' != . in `k' {
				local inmatrix = `inmatrix' + 1
				
				*Replace mean
				matrix meanstats = e(b)
				local replacingscaler = meanstats[1,`inmatrix'] 
				quietly: replace mean_`name' = `replacingscaler' in `k'

				*Replace sd
				matrix meanstats = e(V)
				local replacingscaler = sqrt(meanstats[`inmatrix',`inmatrix'])
				quietly: replace sd_`name' = `replacingscaler' in `k'
				
				*Replace count
				matrix meanstats = e(_N)
				local replacingscaler = meanstats[1,`inmatrix'] 
				quietly: replace count_`name' = `replacingscaler' in `k'
			}
			
		}
		drop `thisvar'
		quietly: save "C:\Program Files\Stata11\ado\base\t\TEMP outtable using.dta", replace

		*Merge it into master
		quietly: use "C:\Program Files\Stata11\ado\base\t\TEMP outtable master.dta", clear
		quietly: merge 1:1 subtest `by' using "C:\Program Files\Stata11\ado\base\t\TEMP outtable using.dta", nogen update replace
		quietly: save "C:\Program Files\Stata11\ado\base\t\TEMP outtable master.dta", replace
		restore
	}
}

preserve
quietly: use "C:\Program Files\Stata11\ado\base\t\TEMP outtable master.dta", clear
quietly: compress
sort `by'
if "`filetype'" != ".dta"{
	quietly: save `"`to'.dta"', replace
}
	else {
		quietly: outsheet using `"`to'.csv"', replace
}
restore

forvalues i = 1/`levels' {
	quietly: drop level`i'
}
end
