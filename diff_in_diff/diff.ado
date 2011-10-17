capture program drop diff 
program define diff, rclass
*! 2.0.1 May2011
version 10.0

************************************************************
************************************************************
**** Program designer: Juan M. Villa.					****
**** Institution: Inter-American Development Bank.		****
**** This program was made only for pedagogic purposes. ****
************************************************************
************************************************************

#delimit ;
syntax varlist(min=1) 
[in] [if] [fw aw pw iw]
 , Period(string)
 Treated(string)
 [ Cov(varlist)
 id(string) 
 Kernel
 bw(real 0.0)
 KType(string)
 QDid(real 0.0)
 PScore(string)
 LOgit
 SUPport
 test
 REPort
 NOStar
 bs
 Reps(integer 50)
 CLuster(string)
 robust ]
 ;
 #delimit cr 

********************
* Set observations *
********************
marksample touse

***********************
* Set output variable *
***********************

tokenize `varlist'
tempvar output
qui: gen `output' = `1'

********************
* Bootstrap prefix *
********************

if "`bs'" != "" {
	if `reps' != . {
		local rep ,reps(`reps')
	}
	local bsp noisily: bs `rep' notable noheader:
	if `qdid' == 0.0 {
		local est r(chi2)
		local inf z
	}
	else if `qdid' != 0.0 {
		local est r(F)
		local inf t
	}
}

else if "`bs'" == "" {
	local bsp ""
	local est r(F)
	local inf t
}

************
* Warnings *
************

if "`period'" == "" {
	di as err "Option period() not specified"
	exit 198
}
else if "`treated'" == "" {
	di as err "Option treated() not specified"
	exit 198
}
if "`cov'" == "" & "`report'" != "" & "`pscore'" == "" {
	di as err "Option report works when cov(varlist) is specified"
	exit 198
}

********************************
********************************
** KERNEL OPTION CALCULATIONS **
********************************
********************************

if "`cov'" != "" & "`test'" == "" {
	if "`kernel'" == "" & `qdid' == 0.0 {
		di in smcl in ye _n "*** DIFFERENCE-IN-DIFFERENCES WITH COVARIATES ***" _n 
	}
	if "`kernel'" == "" & `qdid' != 0.0 {
		di in smcl in ye _n "*** QUANTILE DIFFERENCE-IN-DIFFERENCES WITH COVARIATES ***" _n 
	}
}


***********
* Warning * 
***********

if "`kernel'" != "" {
	if "`id'" == "" {
	di as err "id(varname) required with option kernel"
	exit 198
	}
	
	********************************
	* Delete previous calculations *
	********************************
	
	if "`pscore'" == "" {
		capture drop _ps 
	}
	capture drop _weights 
	capture drop _wght_
	capture drop _support
	
	**********
	* Header *
	**********
	
	if "`test'" == "" & `qdid' == 0.0 {
		di in yellow _n "*** KERNEL PROPENSITY SCORE MATCHING DIFFERENCE-IN-DIFFERENCES ***" _n
	}
	if "`test'" == ""  & `qdid' != 0.0 {
		di in yellow _n "*** KERNEL PROPENSITY SCORE MATCHING QUANTILE DIFFERENCE-IN-DIFFERENCES ***" _n
	}
	if "`test'" == ""  & "`support'" != "" {
		di in yellow "*** ESTIMATION IN THE COMMON SUPPORT ***" _n
	}
	
	***********
	* Warning * 
	***********
	
	if "`cov'" == "" & "`kernel'" != "" & "`pscore'" == "" {
	di as err "No covariates specified in cov(varlist)"
	exit 198
	}

	*******************************
	* Propensity Score estimation * 
	*******************************	
	
	if "`report'" == "" {
		local rep qui:
	}
	
	if "`pscore'" == "" {
		if "`logit'" == "" {
		`rep' probit `treated' `cov' if `touse' & `period' == 0 [`weight'`exp']
		}
		if "`logit'" != "" {
		`rep' logit `treated' `cov' if `touse' & `period' == 0 [`weight'`exp'] 
		}		
		qui: predict _ps if `touse' & `period' == 0, p
		label var _ps "Propensity Score"
		local pscore _ps
	}

	
	******************
	* Common support * 
	******************
	
	if "`support'" != "" {
		tempvar common
		qui: gen `common' = `pscore'
		sort `id' `period'
		qui: bysort `id': replace `common' = `common'[_n-1] if `common' == .
		qui: summ `common' if `treated' == 1
		local supmin = r(min)
		qui: summ `common' if `treated' == 0
		local supmax = r(max)
		
		qui: gen _support = `common' >= `supmin' & `common' <= `supmax'
		label var _support "Common support of the propensity score"
		local comsup & _support
	}
	
	*******************************************
	* Kernel function estimation given the PS * 
	*******************************************	
		
	if "`ktype'" != "" {
		local kern kernel(`ktype')
	}
		if "`bw'" != "" {
		local width bwidth(`bw')
	}
	tempvar other 

	qui: kdensity `pscore' [`weight'`exp']  if `touse', kernel(`ktype') bw(`bw') /*
	*/generate(`other' _weights) at(`pscore') nograph
	sort `id' `period'	
	qui: bysort `id': replace _weights = _weights[_n-1] if _weights == .
	qui: replace _weights = 1 if `treated' == 1 & `touse'
	label var _weights "Weights from the Kernel density function"

	local krn [aw=_weights]
}

*********************************
*********************************
**** BALANCING TEST - T TEST ****
*********************************
*********************************

***********
* Warning * 
***********

if "`test'" != "" {
	if "`cov'" == "" & "`kernel'" == "" & "`pscore'" == "" {
		di as err "No covariates specified in cov(varlist)"
		exit 198
	}
	
	*************************************************************
	* Unweighted covariates (if kernel option is not specified) *
	*************************************************************
	
	if "`kernel'" == "" {
		preserve 
		qui: keep if `period' == 0
		di in smcl in ye _n "*** TWO-SAMPLE T TEST ***"  

		#delimit ;
		di in smcl _n _col(0) in gr "t-test at period = 0:" ; 

		di in gr "{hline 94}";
		di	 in gr  
		" Variable(s)         {c |}   Mean Control   {c |} Mean Treated {c |}    Diff.   {c |}   |t|   {c |}"/*;
		*/"  Pr(|T|>|t|)" _n

		"{hline 21}{c +}{hline 18}{c +}{hline 14}{c +}{hline 12}{c +}{hline 9}{c +}"/*;
		*/"{hline 15}";
		
		*Outcome;
		if `period' == 0 {;
			qui: ttest `output' `in' `if', by(`treated');
			tempname `output'_ttest_mc `output'_ttest_mt `output'_ttest_t `output'_ttest_p;
			scalar ``output'_ttest_mc' = r(mu_1);
			scalar ``output'_ttest_mt' = r(mu_2);
			scalar ``output'_ttest_t' = r(t);
			scalar ``output'_ttest_p' = r(p);
				if ``output'_ttest_p' < 0.01 & "`nostar'" == "" {;
					local star`output' "***";
				};
				else if ``output'_ttest_p' > 0.01 & ``output'_ttest_p' < 0.05 & "`nostar'" == "" {;
					local star`output' "**";
				};
				else if ``output'_ttest_p' > 0.05 & ``output'_ttest_p' < 0.1 & "`nostar'" == "" {;
					local star`output' "*";
				};
			
			di in gr in wh abbrev("`1'",12)
			_col(22) in gr "{c |} " in wh %5.3f ``output'_ttest_mc'
			_col(41) in gr "{c |} " in wh %5.3f ``output'_ttest_mt'
			_col(56) in gr "{c |} " in wh %5.3f (``output'_ttest_mt'-``output'_ttest_mc')
			_col(69) in gr "{c |} " in wh %5.2f abs(``output'_ttest_t')
			_col(79) in gr "{c |} " in wh %5.4f ``output'_ttest_p' "`star`output''";
		
		* Covariates;
			foreach cov of var `cov' {;
				qui: ttest `cov' `in' `if', by(`treated');
				tempname `cov'_ttest_mc `cov'_ttest_mt `cov'_ttest_t `cov'_ttest_p;
				scalar ``cov'_ttest_mc' = r(mu_1);
				scalar ``cov'_ttest_mt' = r(mu_2);
				scalar ``cov'_ttest_t' = r(t);
				scalar ``cov'_ttest_p' = r(p);
					if ``cov'_ttest_p' < 0.01 & "`nostar'" == "" {;
						local star`cov' "***";
					};
					else if ``cov'_ttest_p' >= 0.01 & ``cov'_ttest_p' < 0.05 & "`nostar'" == "" {;
						local star`cov' "**";
					};
					else if ``cov'_ttest_p' >= 0.05 & ``cov'_ttest_p' < 0.1 & "`nostar'" == "" {;
						local star`cov' "*";
					};
				
				di in ye abbrev("`cov'",12)
				_col(22) in gr "{c |} " in ye %5.3f ``cov'_ttest_mc'
				_col(41) in gr "{c |} " in ye %5.3f ``cov'_ttest_mt'
				_col(56) in gr "{c |} " in ye %5.3f (``cov'_ttest_mt'-``cov'_ttest_mc')
				_col(69) in gr "{c |} " in ye %5.2f abs(``cov'_ttest_t')
				_col(79) in gr "{c |} " in ye %5.4f ``cov'_ttest_p' "`star`cov''";
			};
		};

		else if "`'" != "" {;
			exit;
		};
		
		di in gr "{hline 94}"_n
		in gr "*** p<0.01; ** p<0.05; * p<0.1";
		#delimit cr	
		restore
		exit
	}
	
	*******************************************************
	* Weighted covariates (if kernel option is specified) *
	*******************************************************
	
	if "`kernel'" != "" {
		preserve 
		qui: keep if `period' == 0
		di in smcl in ye _n "*** TWO-SAMPLE T TEST ***" 
				
		if "`support'" != "" {
			di in smcl in ye "*** TEST IN THE COMMON SUPPORT ***"
		}
		
		#delimit ;
		di in smcl _n _col(0) in gr "t-test at period = 0:" ; 

		di in gr "{hline 94}";
		di	 in gr  
		"Weighted Variable(s) {c |}   Mean Control   {c |} Mean Treated {c |}    Diff.   {c |}   |t|   {c |}"/*;
		*/"  Pr(|T|>|t|)" _n

		"{hline 21}{c +}{hline 18}{c +}{hline 14}{c +}{hline 12}{c +}{hline 9}{c +}"/*;
		*/"{hline 15}";

		*Outcome;
		
		qui: reg `output' `treated' `in' `if' `krn';
		tempname `output'_ttest_mc `output'_ttest_mt `output'_ttest_t `output'_ttest_p;
		scalar ``output'_ttest_mc' = _b[_cons];
		scalar ``output'_ttest_mt' = _b[_cons]+_b[`treated'];
		scalar ``output'_ttest_t' = _b[`treated']/_se[`treated'];
		qui: test _b[`treated'] = 0;
		scalar ``output'_ttest_p' = r(p);
			if ``output'_ttest_p' < 0.01 & "`nostar'" == "" {;
				local star`output' "***";
			};
			else if ``output'_ttest_p' > 0.01 & ``output'_ttest_p' < 0.05 & "`nostar'" == "" {;
				local star`output' "**";
			};
			else if ``output'_ttest_p' > 0.05 & ``output'_ttest_p' < 0.1 & "`nostar'" == "" {;
				local star`output' "*";
			};
		
		di in gr in wh abbrev("`1'",12)
		_col(22) in gr "{c |} " in wh %5.3f ``output'_ttest_mc'
		_col(41) in gr "{c |} " in wh %5.3f ``output'_ttest_mt'
		_col(56) in gr "{c |} " in wh %5.3f (``output'_ttest_mt'-``output'_ttest_mc')
		_col(69) in gr "{c |} " in wh %5.2f abs(``output'_ttest_t')
		_col(79) in gr "{c |} " in wh %5.4f ``output'_ttest_p' "`star`output''";
	
	* Covariates;
		foreach cov of var `cov' {;
			qui: reg `cov' `treated' if `touse' `comsup' `krn';
			tempname `cov'_ttest_mc `cov'_ttest_mt `cov'_ttest_t `cov'_ttest_p;
			scalar ``cov'_ttest_mc' = _b[_cons];
			scalar ``cov'_ttest_mt' = _b[_cons]+_b[`treated'];
			scalar ``cov'_ttest_t' = _b[`treated'] / _se[`treated'];
			qui: test _b[`treated'] = 0;
			scalar ``cov'_ttest_p' = r(p);
				if ``cov'_ttest_p' < 0.01 & "`nostar'" == "" {;
					local star`cov' "***";
				};
				else if ``cov'_ttest_p' >= 0.01 & ``cov'_ttest_p' < 0.05 & "`nostar'" == "" {;
					local star`cov' "**";
				};
				else if ``cov'_ttest_p' >= 0.05 & ``cov'_ttest_p' < 0.1 & "`nostar'" == "" {;
					local star`cov' "*";
				};
			
			di in ye abbrev("`cov'",12)
			_col(22) in gr "{c |} " in ye %5.3f ``cov'_ttest_mc'
			_col(41) in gr "{c |} " in ye %5.3f ``cov'_ttest_mt'
			_col(56) in gr "{c |} " in ye %5.3f (``cov'_ttest_mt'-``cov'_ttest_mc')
			_col(69) in gr "{c |} " in ye %5.2f abs(``cov'_ttest_t')
			_col(79) in gr "{c |} " in ye %5.4f ``cov'_ttest_p' "`star`cov''";
		};
	};

	else if "`'" != "" {;
		exit;
	};
	
	di in gr "{hline 94}" _n
	in gr "*** p<0.01; ** p<0.05; * p<0.1" _n
	in gr "Attention: option kernel weighs variables in cov(varlist)" _n
	in gr "Means and t-test are estimated by linear regression";
	#delimit cr	
	restore 	
	exit
}

*********************************
*********************************
**** REGRESSIONS AND SCALARS ****
*********************************
*********************************

if "`cluster'" != "" {
	local clust cluster(`cluster')
}

****************	
* Coefficients *
****************

quietly {
	tempvar interact
	gen `interact' = `period' * `treated'
	
	local slist "fc0 ft0 f0 fc1 ft1 f1 f11 sec0 se0 sec1 set0 set1 se1 se11 tc0 tt0 td0 tc1 tt1 td1 t11 pc0 pt0 p0 pc1 pt1 p1 p11"
	tempname `slist'
	if "`kernel'" == "" {
		if `qdid' == 0.0 {
			`bsp' reg `output' `period' `treated' `interact' `cov' `if' `in' [`weight'`exp'], `robust' `clust'
		}
		else if `qdid' != 0.0 {
			if "`bs'" == "" {
				qreg `output' `period' `treated' `interact' `cov' `if' `in' [`weight'`exp'], `robust' `clust' q(`qdid')
			}
			if "`bs'" != "" {
				bsqreg `output' `period' `treated' `interact' `cov' `if' `in' [`weight'`exp'], `robust' `clust' q(`qdid') reps(`reps')
			}
		}
	}
	else if "`kernel'" != "" {
		if `qdid' == 0.0 {
			`bsp' reg `output' `period' `treated' `interact' `krn' if `touse' `comsup' [`weight'`exp'], `robust' `clust'
		}
		else if `qdid' != 0.0 {
			if "`bs'" == "" {
				qreg `output' `period' `treated' `interact' `krn' if `touse' `comsup' [`weight'`exp'], `robust' `clust' q(`qdid')
			}
			if "`bs'" != "" {
				bsqreg `output' `period' `treated' `interact' `krn' if `touse' `comsup' [`weight'`exp'], `robust' `clust' q(`qdid') reps(`reps')
			}
		}
	}
	
	
	local time _b[`period']
	local timetr _b[`interact']
	local control0 _b[_cons]
	local treat0 _b[_cons]+_b[`treated']
	local diff0 _b[`treated']
	local df e(df_r)
					
	local control1  _b[_cons]+`time'
	local treatment1 `control0'+`time'+`diff0'+`timetr'
	local diff1 `diff0'+`timetr'
	
	*************
	* Base line *
	*************
	
	test `control0' == 0
	scalar `fc0' = `est'
	scalar `sec0' = abs(`control0') / sqrt(`fc0')
	scalar `tc0' = `control0' / `sec0'
	scalar `pc0' = r(p)
	
	test `treat0' == 0
	scalar `ft0' = `est'
	scalar `set0' = abs(`treat0') / sqrt(`ft0')
	scalar `tt0' = `treat0' / `set0'
	scalar `pt0' = r(p)
	
	test `diff0' == 0
	scalar `f0' = `est'
	scalar `se0' = abs(`diff0') / sqrt(`f0')
	scalar `td0' = `diff0' / `se0'
	scalar `p0' = r(p)
	
	* Stars p0
	if `p0' < 0.01 & "`nostar'" == "" {
		local starp0 "***"
	}
	else if `p0' >= 0.01 & `p0' < 0.05 & "`nostar'" == "" {
		local starp0 "**"
	}
	else if `p0' >= 0.05 & `p0' < 0.1 & "`nostar'" == "" {
		local starp0 "*"
	}
	
	*************
	* Follow up *
	*************
	
	test `control1' == 0
	scalar `fc1' = `est'
	scalar `sec1' = abs(`control1') / sqrt(`fc1')
	scalar `tc1' = `control1' / `sec1'
	scalar `pc1' = r(p)
	
	test `treatment1' == 0
	scalar `ft1' = `est'
	scalar `set1' = abs(`treatment1') / sqrt(`ft1')
	scalar `tt1' = `treatment1' / `set1'
	scalar `pt1' = r(p)
	
	test `diff1' == 0
	scalar `f1' = `est'
	scalar `se1' = abs(`diff1') / sqrt(`f1')
	scalar `td1' = `diff1' / `se1'
	scalar `p1' = r(p)
	
	* Stars p1
	if `p1' < 0.01 & "`nostar'" == "" {
		local starp1 "***"
	}
	else if `p1' >= 0.01 & `p1' < 0.05 & "`nostar'" == "" {
		local starp1 "**"
	}
	else if `p1' >= 0.05 & `p1' < 0.1 & "`nostar'" == "" {
		local starp1 "*"
	}
	
	*******
	* DID *
	*******
	
	test `timetr' == 0
	scalar `f11' = `est'
	scalar `se11' = abs(`timetr') / sqrt(`f11')
	scalar `t11' = `timetr' / `se11'
	scalar `p11' = r(p)
	
	*Stars p11
	if `p11' < 0.01 & "`nostar'" == "" {
		local starp11 "***"
	}
	else if `p11' >= 0.01 & `p11' < 0.05 & "`nostar'" == "" {
		local starp11 "**"
	}
	else if `p11' >= 0.05 & `p11' < 0.1 & "`nostar'" == "" {
		local starp11 "*"
	}
}	


****************************
****************************
**** TABLES AND REPORTS ****
****************************
****************************
if `qdid' == 0.0 {
	local r2 e(r2)
}
else if `qdid' != 0.0 {
	local r2 = 1 - (e(sum_adev)/e(sum_rdev))
}

di in gr _n "Number of observations:" in ye " " e(N)
di in gr "R-square:" in ye " " %8.5f `r2'

#delimit ;
if "`report'" != "" & "`kernel'" == "" & "`cov'" != "" {;
	di in smcl _n _col(0) in gr "Covariates and Coefficients:" ; 
	di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
	*/"{hline 10}";
	di in gr  
	" Variable(s)         {c |}   Coeff.   {c |} Std. Err. {c |}    `inf'    {c |}"/*;
	*/"  P>|`inf'|" _n
	"{hline 21}{c +}{hline 12}{c +}{hline 11}{c +}{hline 9}{c +}"/*;
	*/"{hline 10}";

	/*;Report of covariates*/;
	foreach cov of var `cov' {;
		quietly: test _b[`cov'] == 0 ;
		di in ye  abbrev("`cov'",12)
		_col(22) in gr "{c |} " in ye %5.3f _b[`cov']
		_col(35) in gr "{c |} " in ye %5.3f _se[`cov']
		_col(47) in gr "{c |} " in ye %5.3f _b[`cov']/_se[`cov']
		_col(57) in gr "{c |} " in ye %5.3f r(p);
	};
	
	di in gr "{hline 21}{c -}{hline 12}{c -}{hline 11}{c -}{hline 9}{c -}"/*;
	*/"{hline 10}";
};

if "`bs'" != "" {;
	di in gr "Bootstrapped Standard Errors";
};

di in smcl _n _col(33) in gr "DIFFERENCE IN DIFFERENCES ESTIMATION" ;
;
di in gr  
"{hline 21} {hline 12} BASE LINE {hline 9} {hline 11} FOLLOW UP {hline 10} {hline 14}"_n 
		
" Outcome Variable(s) {c |} Control {c |}  treated  {c |} Diff(BL) {c |}"/*;
*/" Control {c |}  treated  {c |} Diff(FU) {c |} DIFF-IN-DIFF "_n

"{hline 21}{c +}{hline 9}{c +}{hline 11}{c +}{hline 10}{c +}"/*;
*/"{hline 9}{c +}{hline 11}{c +}{hline 10}{c +}{hline 14}"_n

/*;Coefficients*/
in ye  abbrev("`1'",12)
_col(22) in gr "{c |} " in ye %5.3f `control0'
_col(32) in gr "{c |} " in ye %5.3f `treat0'
_col(44) in gr "{c |} " in ye %5.3f `diff0'
_col(55) in gr "{c |} " in ye %5.3f `control1'
_col(65) in gr "{c |} " in ye %5.3f `treatment1'
_col(77) in gr "{c |} " in ye %5.3f `diff1'
_col(88) in gr "{c |} " in ye %5.3f `timetr' _n


/*;Standard Errors*/
in wh "Std. Error"
_col(22) in gr "{c |} " in wh %4.3f `sec0'
_col(32) in gr "{c |} " in wh %4.3f `set0'
_col(44) in gr "{c |} " in wh %4.3f `se0' 
_col(55) in gr "{c |} " in wh %4.3f `sec1'
_col(65) in gr "{c |} " in wh %4.3f `set1'
_col(77) in gr "{c |} " in wh %4.3f `se1'
_col(88) in gr "{c |} " in wh %4.3f `se11'  _n


/*;t-stat*/
in wh "`inf'"
_col(22) in gr "{c |} " in wh %4.2f `tc0'
_col(32) in gr "{c |} " in wh %4.2f `tt0'
_col(44) in gr "{c |} " in wh %4.2f `td0' 
_col(55) in gr "{c |} " in wh %4.2f `tc1'
_col(65) in gr "{c |} " in wh %4.2f `tt1'
_col(77) in gr "{c |} " in wh %4.2f `td1'
_col(88) in gr "{c |} " in wh %4.2f `t11'  _n


/*;Probabilities*/
in wh "P>|`inf'|"
_col(22) in gr "{c |} " in wh %4.3f `pc0'
_col(32) in gr "{c |} " in wh %4.3f `pt0'
_col(44) in gr "{c |} " in wh %4.3f `p0' "`starp0'"
_col(55) in gr "{c |} " in wh %4.3f `pc1'
_col(65) in gr "{c |} " in wh %4.3f `pt1'
_col(77) in gr "{c |} " in wh %4.3f `p1' "`starp1'"
_col(88) in gr "{c |} " in wh %4.3f `p11' "`starp11'"  _n

in gr "{hline 21}{c -}{hline 9}{c -}{hline 11}{c -}{hline 10}{c -}"/*;
*/"{hline 9}{c -}{hline 11}{c -}{hline 10}{c -}{hline 14}"
;
#delimit cr
		
*********	
* Notes *
*********
if `qdid' == 0.0 {
	di in gr "* Means and Standard Errors are estimated by linear regression"
}
if `qdid' != 0.0 {
	di in gr "* Values are estimated at the `qdid' quantile"
}

if "`robust'" != "" {
	di in gr "**Robust Std. Errors"
}
if "`cluster'" != "" {
	di in gr "**Clustered Std. Errors"
}

if "`nostar'" == "" {
	di in gr "**Inference: *** p<0.01; ** p<0.05; * p<0.1"
}

***********************
***********************
**** SAVED RESULTS ****
***********************
***********************

return scalar mean_c0 = `control0'
return scalar mean_t0 = `treat0'
return scalar diff0 = `diff0'
return scalar mean_c1 = `control1'
return scalar mean_t1 = `treatment1'
return scalar diff1 = `diff1'
return scalar diffdiff = `timetr'
return scalar se_c0 = `sec0'
return scalar se_t0 = `set0'
return scalar se_d0 = `se0'
return scalar se_c1 = `sec1'
return scalar se_t1 = `set1'
return scalar se_d1 = `se1'
return scalar se_dd = `se11'

end
