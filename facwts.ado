program define facwts
	syntax varlist [pweight] , LABels(str) [LEGendoptions(str) TWOWay_options(str) Keep SVY Control]
	version 11

quietly: set mat 4000
*Labels should be sum, percent, none
if "`svy'" != ""{
	local `svy' = "svy:"
	}


*Find length of varlist
local numlength = 0
forvalues i=1/800 {	
	local testname : word `i' of `varlist'
	if "`testname'" != "" {
		local numlength = `numlength' + 1
	}
}

*Create a newvarlist of only explanatory variables
*Include variable labels
local newvarlist ""
forvalues i=2/`numlength' {
	*Divide each variable by its max so that they are all on a common scale
	local dupe : word `i' of `varlist'
	quietly: summarize(`dupe')
	quietly: gen `dupe'2 = `dupe'/r(max)
	local newvarlist "`newvarlist' `dupe'2"
	local j = `i' - 1
	local vlab`j' "`dupe'"
}

*find beta coefficients of normalized variables
local depv : word 1 of `varlist'
quietly: `svy' regress `depv' `newvarlist' [`weight'`exp']

*Make new variables of one observation. These are the relative weights of each variable
matrix A = e(b)
mat list e(b)
svmat float A
local nn = `numlength' - 1
local nnvarlist ""
forvalues i = 1/`nn' {
	local dupe : word `i' of `newvarlist'
	drop `dupe'
	ren A`i' `dupe'
	if `dupe' < 0 in 1 {
		*If the weight is negative... make it positive! Everything is relative, and a negative weight is a weight nonetheless	
		replace `dupe' = -1*`dupe' 
		ren `dupe' neg_`dupe'
		local `dupe' = "neg_`dupe'"
		local vlab`i' "neg_`dupe'"
		local nnvarlist "`nnvarlist' neg_`dupe'" 
	}
	else {
		local nnvarlist "`nnvarlist' `dupe'" 
	}
}

if "`control'"==""{
	*Pie it. This shows the relative importance of each factor. 
	graph pie `nnvarlist', pie(_all, explode(minuscule)) plabel(_all `labels', size(large) format(%9.3g)) ///
		legend(on order(1 "`vlab1'" 2 "`vlab2'" 3 "`vlab3'" 4 "`vlab4'" 5 "`vlab5'" 6 "`vlab6'" 7 "`vlab7'" ///
		8 "`vlab8'") cols(3) `legendoptions') title(Factors in `: variable label `depv'') `twoway_options'
}
else{
	*Pie it. This shows the relative importance of each factor. 
	ren A`numlength' other
	local nnp1 = wordcount("`nnvarlist'") + 1
	local vlab`nnp1' "Other factors"
	graph pie `nnvarlist' other, pie(_all, explode(minuscule)) plabel(_all `labels', size(large) format(%9.3g)) ///
		legend(on order(1 "`vlab1'" 2 "`vlab2'" 3 "`vlab3'" 4 "`vlab4'" 5 "`vlab5'" 6 "`vlab6'" 7 "`vlab7'" ///
		8 "`vlab8'") cols(3) `legendoptions') title(Factors in `: variable label `depv'') `twoway_options'
	ren other A`numlength'
}

if "`keep'" == "" {
	drop `nnvarlist' A`numlength'
}
end
