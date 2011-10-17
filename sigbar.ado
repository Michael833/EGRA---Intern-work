/* 	Generates barchart of significant variables
	Alex Sax
	RTI International
	8-18-11
*/

program define sigbar
	syntax varlist [pweight] [if] [in] [, SVY noLABel Keep noGRAph GRoup(varname) LEGendoptions(str) TWOWay_options(str) lsize(str) hello]
	version 11

*Set labelsize if not user defined
if "`lsize'"==""{
	local lsize = "lsize"
	}
*If svy, use it!
if "`svy'" != ""{
	local `svy' = "svy:"
	}
if "`hello'"!=""{
	di in red "Hi there!"
	di in green "Now back to work."
}

*find the dependant variable
local dvar : word 1 of `varlist'
*If we don't already have a list, make one
capture confirm variable Variable
if _rc{
local sigvars ""
local coeflist ""
local sigvarlab ""
local siglength = 0
forvalues i=2/800 {	
	*Create list of potentially significant variables
	local testvar : word `i' of `varlist'
	capture confirm variable `testvar'
	if !_rc {
		if "`weight'"!="" {
			quietly: `svy' regress `dvar' `testvar' [`weight'`exp']
		}
		else {
			quietly: `svy' regress `dvar' `testvar'
		}
		*Test and move to significant list
		quietly: test `testvar'
		if r(p)<0.05{
			local testcoef = _b[`testvar']
			local coeflist "`coeflist' `testcoef'"
			local sigvars "`sigvars' `testvar'"
			local siglength = `siglength' + 1
		}
	}
}

*Gen vars to make the graph
quietly: gen str50 Variable = ""
quietly: gen str200 Varlab = ""
quietly: gen str14 change = ""
forvalues i = 1/`siglength' {
	*List all significant variables*
	local testvar : word `i' of `sigvars'
	quietly: replace Variable = "`testvar'" in `i'
	*List the labels of all significant variables
	local testvar : word `i' of `sigvars'
	local ltestvar : variable label `testvar'
	quietly: replace Varlab = "`ltestvar'" in `i'
	*List the beta coefficients of all sig vars
	local testvar : word `i' of `coeflist'
	quietly: replace change = "`testvar'" in `i'
}
quietly: destring change, replace
}
*Display graph
if "`graph'" == "" {
*Display the graph if there are not groups
if "`group'" == ""{
	if "`label'" != "nolabel" {
		*And apply labels
		graph hbar (firstnm) change , sort(change) scheme(s2color) over(Varlab, sort(change) ///
			label(labsize(vsmall))) asyvars showyvars cw blabel(bar, size(`lsize') format(%9.1g)) ytitle(`: variable label `dvar'' Change) ///
			title(Change in `: variable label `dvar'' by Factor) legend(off) `twoway_options'
	}
	else {
		*Or don't
		graph hbar (firstnm) change , sort(change) scheme(s2color) over(Variable, sort(change) ///
			label(labsize(vsmall))) asyvars showyvars cw blabel(bar, size(`lsize') format(%9.1g)) ytitle(`: variable label `dvar'' Change) ///
			title(Change in `: variable label `dvar'' by Factor) legend(off) `twoway_options'
	}
}
else {
	*And if there are groups
	decode `group', gen(other`group')
	if "`label'" != "nolabel" {
		*And apply labels
		graph hbar (firstnm) change , sort(change) scheme(s2color) over(other`group', sort(change) ///
			label(nolabel)) asyvars showyvars over(Varlab, sort(change) label(labsize(tiny)))cw ///
			blabel(bar, size(`lsize') format(%9.1g)) ytitle(`: variable label `dvar'' Change) ///
			title(Change in `: variable label `dvar'' by Factor) legend(on cols(1) `legendoptions') ///
			 `twoway_options'
	}
	else {
		*Or don't
		graph hbar (firstnm) change , sort(change) scheme(s2color) over(`group', sort(change) ///
			label(nolabel)) asyvars showyvars over(Variable, sort(change) label(labsize(tiny)))cw ///
			blabel(bar, size(`lsize') format(%9.1g)) ytitle(`: variable label `dvar'' Change) ///
			title(Change in `: variable label `dvar'' by Factor) legend(on cols(1) `legendoptions') ///
			 `twoway_options'
	}
	drop other`group'
}
}

if "`keep'" == "" {
	drop change Variable Varlab
}
end
