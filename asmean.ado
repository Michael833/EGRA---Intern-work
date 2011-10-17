program define asmean
	syntax varlist(min=2 max=3) [pweight] , LEVels(numlist) [INCrements(integer 0) ///
				Keep PERcentiles noGRAph TWOWay_options(str) LEGendoptions(str)]
/* 	Auto bar chart at given reading comprehension scores
	Alex Sax
	RTI International
	8-18-11
*/

	version 11

*This program either makes the percentile graph, or a bar graph.
* 	The bar graph displays the mean of a dep. var for each subpopulation. Either a sub-pop determined by the depv or not.
* 	The user has the option of breaking it up further with the `over' variable.


*Find out how many names the user entered
local depv : word 1 of `varlist'
local expl : word 2 of `varlist'
local over : word 3 of `varlist'
local numlength = wordcount("`levels'")



local subpops ""

*Gen a new variable for each level. EX: Over or equal to 0 (average), >=80, >=100
forvalues i = 1/`numlength' {
	local testname : word `i' of `levels'
	if `i'<`numlength'{
		local j = `i' + 1
		local testname2 : word `j' of `levels'
		local levup = `testname2'
	}
	local lev = `testname'
	quietly: gen level`i' = .
	if "`percentiles'"==""{
		if `i'<`numlength' {
			quietly: replace level`i' = 1 if `expl' >= `lev' & `expl' < `levup' & `expl' != .
		}
		else {
			quietly: replace level`i' = 1 if `expl' >= `lev' & `expl' != .
		}
	}
	else {
		*If percentiles, then break up the population by the levels specified
		quietly: replace level`i' = 1 if `expl' == `lev'
	}
	quietly: gen value_subpop`i' = level`i'*`depv'
	local vlab`i' "Population at or above `testname'"
	local subpops = "`subpops' value_subpop`i'"
}

if "`percentiles'"!="" {
local subpops ""
* Generate percent tiles for each subgroup, then apply the percentile (in tiles) to each desired percentile
quietly: gen tiles = .
	forvalues i=1/`numlength' {
		local j : word `i' of `levels'		
		pctile junk`i' =`depv' if `expl' == `j', n(100)		
		local vlab`i' "`: label (`expl') `j''"
		
		*Make a connected plot if the percentiles are far enough away from each other. Otherwise, the graph is cluttered.
		if `increments' < 15 & `increments' != 0 {
			local subpops`i' = "line `depv' tiles if `expl' == `j'"	
		}
		else {
			local subpops`i' = "connected `depv' tiles if `expl' == `j'"	
		}
		
		*Apply percentiles
		if `increments'!=0{
			forvalues k = 1(`increments')99 {
				local req = junk`i' in `k'
				quietly: replace tiles = `k' if orf == `req' & `expl' == `j'
			}
		}
		else{
			foreach k of numlist 1 25 50 75 99 {
				local req = junk`i' in `k'
				quietly: replace tiles = `k' if orf == `req' & `expl' == `j'
			}
		}
		local vlab = `"`i' "`vlab`i''" `vlab'""'
		}
}

*Graph it.
if "`graph'" == "" {
	if "`percentiles'"=="" {
		graph bar (mean) `subpops' [`weight'`exp'], over(`over', label(nolabel)) asyvar showyvar blabel(bar, size(vsmall) position(outside) ///
			orientation(vertical) format(%9.1g)) ytitle(`: variable label `depv'') title(`: variable label `depv'' by `over') legend(on cols(1) ///
			`legendoptions' label(1 "`vlab1'") label(2 "`vlab2'") label(3 "`vlab3'") label(4 "`vlab4'") ///
			label(5 "`vlab5'") label(6 "`vlab6'") label(7 "`vlab7'") label(8 "`vlab8'") rows(3)) bargap(16) outergap(50) nolabel `twoway_options'
	}
	else {
		sort `expl' tiles
		
		twoway (`subpops1')(`subpops2') (`subpops3') (`subpops4') (`subpops5') (`subpops6') (`subpops7') (`subpops8'), ///
				 legend(on order(1 "`vlab1'" 2 "`vlab2'" 3 "`vlab3'" 4 "`vlab4'" 5 "`vlab5'" 6 "`vlab6'" 7 "`vlab7'" ///
				 8 "`vlab8'") cols(1) `legendoptions') `twoway_options' xtitle(Percentile) title(`: variable label `depv'' v `expl') ///

	}




}

*Keep or drop generated variables
if "`keep'" == "" {
	if "`percentiles'"!="" {
	drop tiles
	}
	forvalues i = 1/`numlength' {
		drop level`i' value_subpop`i' 
		if "`percentiles'"!="" {
			drop junk`i'	
		}
	}
}
end
