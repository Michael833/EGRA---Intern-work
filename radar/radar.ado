*! Date        : 13 Jun 2011
*! Version     : 1.07
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-bsu.cam.ac.uk
*! Description : Radar graphs

/*
16/04/07 Version 1.02: allow line colours and patterns for the observations
20/5/08  Version 1.03: Allow rlabels.. to vary the web
27/10/08 Version 1.04: Allow missing values but need to implement a gap
23/4/09  Version 1.05: Move to the BSU email, do line widths
1/9/09   Version 1.06: Move to Stata 11
13/6/11  Version 1.07

FUTURE release should include, varying text on axes, control of web parameters, width, colour style.
*/

/* Future ideas

1. Need to sort out the minimum 0 problem

*/

pr radar
version 11.0
preserve
syntax [varlist] [if] [in] [, LC(string) LP(string) LW(string) Rlabel(numlist) LABSIZE(string) *]

local gopt "`options'"

/* Set up the defaults for line color, pattern, width */
if "`lc'"=="" local xopt ""
else local xopt "lc(`lc')"
if "`lp'"~="" local xopt "`xopt' lp(`lp')"
if "`lw'"~="" local xopt "`xopt' lw(`lw')"
if "`labsize'"~=""  local labsize "si(`labsize')"
else local labsize "si(*1)"

if "`if'"~="" keep `if'
if "`in'"~="" keep `in'

local max -1000000000000000000
local min 1000000000000000000
local maxlevels 0

local i 0
local vlist ""
foreach v of local varlist {
  if `++i'==1 local vlab "`v'"
  else {
    confirm numeric variable `v'
    local vlist "`vlist' `v'"
    qui count if `v'~=.
    local nlevels `r(N)'
    if `maxlevels' < `nlevels' local maxlevels `nlevels'
    qui su `v'
    if `r(max)'>`max' local max = `r(max)'
    if `r(min)'<`min' local min = `r(min)'
  }
}

/* The automatic legend values */
local i 0
foreach v of local varlist {
  if `i++'~=0 {
    local order "`order' `--i'"
    local l "`l' label(`i++' "`v'")"
  }
}
local legend "legend(order(`order') `l')"


/* Yes maxlevels is the number of spokes... */
if `maxlevels'>100 {
  di "{error}Warning: You have over 100 possible spokes"
  exit(198)
}

/* Having found min and max.. rlabel might change this */
if "`rlabel'"~="" {
  numlist "`rlabel'", sort
  local rlabel "`r(numlist)'"
  local rmax -10000000000000
  local rmin 1000000000000000
  foreach r of local rlabel {
    if `rmax'<`r' local rmax "`r'"
    if `rmin'>`r' local rmin "`r'"
  }
if `rmin'>`min' local rlabel "`min' `rlabel'"
if `rmax'<`max' local rlabel "`rlabel' `max'"
if `rmin'<`min' local min =`rmin'
if `rmax'>`max' local max =`rmax'
local axeopt ",rlabel(`rlabel')"
local axeoptnocom "rlabel(`rlabel')"
}

/* DRAW the axes*/
_buildaxes `maxlevels' `max' `min' `axeopt'
local g "`r(g)'"
local wys "`r(wys)'"

/* DRAW the observed lines */
_drawobs `vlist' , maxlevels(`maxlevels') max(`max') min(`min') `xopt' 
local go "`r(g)'"

/* LABEL */
_labels `vlab' , maxlevels(`maxlevels') max(`max') min(`min') `labsize'
forv i=1/`maxlevels' {
  local gl `"`gl' `r(g`i')'"'
}

/* LABEL axes the number part*/
_labelaxes `vlab' , labs(`wys') maxlevels(`maxlevels') max(`max') min(`min') `axeoptnocom'
local gaxe `"`r(g)'"'

/* CREATE GRAPH */
twoway `go' `g' (pcspike wy wx wy0 wx0, lc(gs8) lw(*.5)), `legend'  `gl' `gaxe' /*
*/ legend(on)   aspectratio(1) xscale(off) ysca(off) ylab(,nogrid) note(Center is at `min') `gopt'

restore
end

/************************************
 *
 * This labels the axes 
 * labs contains the y coefficient
 *
 *************************************/

pr _labelaxes, rclass
syntax [varlist] [, maxlevels(integer 0) max(real 0) min(real 0) labs(numlist) rlabel(numlist) ]

local minlist : di %6.3f `min'
local maxlist : di %6.3f `max'
local steplist : di %7.4f (`max'-`min')/5
local nspokes = `maxlevels'
local nspokes1=`nspokes'+1

if "`rlabel'"~="" local numberlist "`rlabel'"
else local numberlist "`minlist'(`steplist')`maxlist'"

local i 1
foreach lab of numlist `numberlist' {

  local y: word `i' of `labs'
  local y=0.98*`y'
  local y: di %6.2f `y'

  if `i++'==1 continue

  if "`rlabel'"=="" local lab: di %6.0f `lab'
  local lababs: di %6.0f abs(`lab')
  local x: di %6.2f `lababs'*sin(_pi)
  local x = trim("`x'")
  local y = trim("`y'")
  local lab = trim("`lab'")

  local g `"`g' text(`y' `x' "`lab'",si(*.6) place(n))"' 
}
return local g `"`g'"'

end

/*****************************************************
 * Places the text at the end of the spokes
 *
 *****************************************************/

pr _labels, rclass
syntax [varlist] [, maxlevels(integer 0) max(real 0) min(real 0) SI(string)]

local minlist : di %6.3f `min'
local maxlist : di %6.3f `max'
local steplist : di %7.4f (`max'-`min')/5
local nspokes = `maxlevels'
local nspokes1=`nspokes'+1

forv i=1/`nspokes' {
  local angle = (`i'-1)*2*_pi/`nspokes'
  local p "c"
  if `angle'>0 & `angle'<4*_pi/4 local p "e"
  if `angle'>_pi & `angle'<2*_pi local p "w"
  local lab =`varlist'[`i']
  local y = (`max'-`min')*1.05*cos(`angle')
  local x = (`max'-`min')*1.05*sin(`angle')

  local g`i' `"text(`y' `x' "`lab'", si(`si') place(`p') ) "' 
}
forv i=1/`nspokes' {
  return local g`i'=`"`g`i''"'
}

end

/*****************************************************
 * This draws the observations 
 *
 *****************************************************/

pr _drawobs, rclass
syntax [varlist] [, maxlevels(integer 0) max(real 0) min(real 0) LC(string) LP(string) LW(string)]

local minlist : di %6.3f `min'
local maxlist : di %6.3f `max'
local steplist : di %7.4f (`max'-`min')/5
local nspokes = `maxlevels'
local nspokes1=`nspokes'+1

local n 1
foreach v of local varlist {
  qui gen obsy`n'=.
  qui gen obsx`n'=.
  forv i=1/`nspokes1' {
    local angle = (`i'-1)*2*_pi/`nspokes'
    local r = `v'[`i']
    qui replace obsy`n' = (`r'-`min')*cos(`angle') in `i'
    qui replace obsx`n' = (`r'-`min')*sin(`angle') in `i'
  }
  qui replace obsy`n' = obsy`n'[1] in `nspokes1'
  qui replace obsx`n' = obsx`n'[1] in `nspokes1'

  local xopt ", cmiss(n) lw(*1.2)"
  /* Sort out the colors if they exist */
  if "`lc'"~="" {
    local con: word `n' of `lc'
    if "`con'"~="" local xopt "`xopt' lc(`con')"
  }
  if "`lp'"~="" {
    local con: word `n' of `lp'
    if "`xopt'"=="" & "`con'"~="" local xopt ", lp(`con')"
    if "`xopt'"~="" & "`con'"~="" local xopt "`xopt' lp(`con')"
  }
   if "`lw'"~="" {
    local con: word `n' of `lw'
    if "`xopt'"=="" & "`con'"~="" local xopt ", lw(`con')"
    if "`xopt'"~="" & "`con'"~="" local xopt "`xopt' lw(`con')"
  }
 local g "`g' (line obsy`n' obsx`n'`xopt')"
  local xopt ""
  local `n++'
}
return local g  "`g'"

end

/*****************************************************
 * Draw the axes lines 
 *
 *****************************************************/

pr _buildaxes, rclass
syntax [anything] [, rlabel(numlist)]

/* This step just gets the 3 arguments into some macros */
local i 1
foreach arg of local anything {
  if `i'==1 local nspokes "`arg'"
  if `i'==2 local max "`arg'" 
  if `i++'==3 local min "`arg'"
}

local minlist : di %6.3f `min'
local maxlist : di %6.3f `max'
local steplist : di %7.4f (`max'-`min')/5

local nspokes = `nspokes'
local nspokes1=`nspokes'+1

qui set obs `nspokes1'

qui gen wy=.
qui gen wx=.
qui gen wy0=0
qui gen wx0=0

local numberlist "`minlist'(`steplist')`maxlist'"
if "`rlabel'"~="" local numberlist "`rlabel'"

local n 1
foreach max of numlist `numberlist' {
  qui gen ay`n'=.
  qui gen ax`n'=.
  forv i=1/`nspokes1' {
    local angle = (`i'-1)*2*_pi/`nspokes'
    qui replace ay`n' = (`max'-`minlist')*cos(`angle') in `i'
    qui replace ax`n' = (`max'-`minlist')*sin(`angle') in `i'
    if `n'==1 & `i'~=`nspokes1' {
      qui replace wy = (`maxlist'-`minlist')*cos(`angle') in `i'
      qui replace wx = (`maxlist'-`minlist')*sin(`angle') in `i'
    }
  }
  qui su ay`n'
  local wys "`wys' `r(min)'"
  local g "`g' (line ay`n' ax`n',lc(gs8) lw(*.5))"
  local `n++'
}

return local g "`g'"
return local wys  "`wys'"
end
