* Auto Cleaning File
* Alex Sax & Michael Costello
* RTI International
* August 2011


* GO ADD NUM LANG IF `s' > 17! 
* Change`s'to "`mymac'" in -apply labels- section

program define egrmaclean
	syntax varlist , [READwords(numlist) LANGuages(str) MLEVels noUPdate hello ]
	version 11


{/* Easter Eggs*/
if "`hello'"!=""{
	di in red "Hi there!"
	di in green "Now back to work."
}
if "`readwords'"=="1 1 2 3 5" | "`readwords'"=="1 1 2 3 5 8"{
	di in red "IL FIBONACCI!"
	di in green `"http://mathworld.wolfram.com/FibonacciNumber.html"'
}
}
{/* Import codebook contents*/
*Declare empty matrices
mata: demvars = ("","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","",""\ ///
			"","","","")
mata: varnames = demvars
mata: labmat = demvars
mata: ssmat = demvars
mata: langmat = demvars /*Use this in the pre-cleaning housekeeping section*/

preserve 
*Save a local copy if connected to the Z: drive*
capture confirm file `"Z:\Task 3 EGRA\Final Databases\Codebook for EGRA & EGMA.xlsx"'
	if !_rc & "`update'"==""{
		import excel using "Z:\Task 3 EGRA\Final Databases\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Demographics")
		quietly: export excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", sheetreplace firstrow(variables) sheet("Demographics")
		import excel using "Z:\Task 3 EGRA\Final Databases\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Test Sections")
		quietly: export excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", sheetreplace firstrow(variables) sheet("Test Sections")
		import excel using "Z:\Task 3 EGRA\Final Databases\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Labels")
		quietly: export excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", sheetreplace firstrow(variables) sheet("Labels")	
		import excel using "Z:\Task 3 EGRA\Final Databases\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Super Summary")
		quietly: export excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", sheetreplace firstrow(variables) sheet("Super Summary")	
		di "Updated local codebook"
	}
	{/* Read excel workbook into stata matrices */
	import excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Demographics")
		local demsections = _N
		forvalues i=1/4 {
			forvalues j=1/`demsections'{
				local contents = DemographicVariables`i' in `j'
				*If we want to drop contents of cell, preface it with "."
				if substr("`contents'",1,1)!="."{
					mata: demvars[`j',`i'] = `"`contents'"'
				}
				else {
					mata: demvars[`j',`i'] = ""
				}
			}
		}
		
	import excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Test Sections")
		local possiblesections = _N
		forvalues i=1/3 {
				forvalues j=1/`possiblesections'{
				local contents = TestSection`i' in `j'
				*If we want to drop contents of cell, preface it with "."
				if substr("`contents'",1,1)!="."{
					mata: varnames[`j',`i'] = `"`contents'"'
				}
				else {
					mata: varnames[`j',`i'] = ""
				}
			}
		}
			
	import excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Labels")
		local labsections = _N
		forvalues i=1/2 {
				forvalues j=1/`labsections'{
				local contents = Label`i' in `j'
				*If we want to drop contents of cell, preface it with "."
				if substr("`contents'",1,1)!="."{
					mata: labmat[`j',`i'] = `"`contents'"'
				}
				else {
					mata: labmat[`j',`i'] = ""
				}
			}
		}	
		
		import excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Super Summary")
		local sssections = _N
		forvalues i=1/2 {
				forvalues j=1/`sssections'{
				local contents = Section`i' in `j'
				*If we want to drop contents of cell, preface it with "."
				if substr("`contents'",1,1)!="."{
					mata: ssmat[`j',`i'] = `"`contents'"'
				}
				else {
					mata: ssmat[`j',`i'] = ""
				}
			}
		}	
	restore
	}
	{/* Define Label Values*/
	*Create labels from matrix labmat
	forvalues i=1/`labsections'{
		mata: st_local("label", labmat[`i',2])
		mata: st_local("labelname", labmat[`i',1])
		if "`label'" != ""{
			local quothlabel ""
			local labellength = wordcount("`label'")/2
			forvalues j=1/`labellength' {
				local k = 2*`j'
				local o = 2*`j' - 1
				local word : word `k' of `label'
				local num : word `o' of `label'
				local word = subinstr("`word'","_"," ",.)
				local quothlabel `"`quothlabel' `num' "`word'""'
			}
			label define `labelname' `quothlabel'
		}
	}
	}

}
{/* Pre-cleaning housekeeping*/
*Create a variable called placeholder to tell egrmaclean how to order each section
capture confirm variable placeholder
	if _rc{
		quietly: gen placeholder = .
	}
order placeholder, first

if "`readwords'"!=""{
	*Determine the length of each section
	local numlength = wordcount("`readwords'")

	* Find the length of the reading word requirement list (readwords) and then  put that list into a matrix.
	local readword ""
	forvalues i = 1/`numlength' {
		local testname : word `i' of `readwords'
		local readword "`readword'`testname',"
	}
	matrix input read_word_needed = (`readword'0)  /* Needed a 0 to make a matrix, 0 is a placeholder to fill the last element. */
}

local langlength = 1 /*Even if the user doesn't specify additional languages, the test still has one */ 
if "`languages'"!=""{
	*Determine how many languages there are and save them in a matrix
	local langlength = 1 + wordcount("`languages'")
	forvalues i = 1/`langlength' {
		local j = `i'+1
		local testname : word `i' of `languages'
		mata: langmat[`j',1] = "`testname'"
	}
}

*A string that will store the "nonboolean" warning
local check ""

*Fix common renpfix errors
forvalues langnum = 1/`langlength'{
	mata: st_local("lang", langmat[`langnum',1])
	foreach j in "01" "1" {
		capture confirm variable `lang'oral_read_word`j'
			if !_rc{
				renpfix `lang'oral_read_word `lang'oral_read
			}
		capture confirm variable `lang'unfam_word`j'
			if !_rc{
				renpfix `lang'unfam_word `lang'invent_word
			}
		capture confirm variable `lang'addition`j'
			if !_rc{
				renpfix `lang'addition `lang'add
			}
		capture confirm variable `lang'subtract`j'
			if !_rc{
				renpfix `lang'subtract `lang'sub
			}
		capture confirm variable `lang'subtraction`j'
			if !_rc{
				renpfix `lang'subtraction `lang'sub
			}
		capture confirm variable `lang'miss_dig`j'
			if !_rc{
				renpfix `lang'miss_dig `lang'miss_num
			}
		}
	}
}

forvalues langnum = `langlength'(-1)1{
	{/* Main cleaning */
		order placeholder
		
		* Define language
		mata: st_local("lang", langmat[`langnum',1])
		di "`lang'"
		{/* Cleaning and ordering the Concepts of Text variables. */
		capture confirm variable cot_location
			if !_rc {
				label variable cot_location "Does the child put his/her finger on the top left letter?"
				label values cot_location yesno
				order cot_location, b(placeholder)		
			}

		capture confirm variable cot_direction
			if !_rc {
				label variable cot_direction "Does the child move his/her finger from left to right?"
				label values cot_direction yesno
				order cot_location cot_direction, b(placeholder)		
			}

		capture confirm variable cot_next_line
			if !_rc {
				label variable cot_next_line "Does the child move his/her finger to the left side of the second line after finishing the first?"
				label values cot_next_line yesno
				order cot_location cot_direction cot_next_line, b(placeholder)		
			}
		}

		
	forvalues s = 2/`possiblesections' {
		{/* Cleaning item-level variables */
			local tested = 0
			mata: st_local("mymac", varnames[`s',1])
			mata: st_local("section", varnames[`s',2])
			mata: st_local("seclab", varnames[`s',3])
			capture confirm variable `lang'`mymac'*
				if !_rc {
					order `lang'`mymac'*, a(placeholder)
				}
			* Recode '01' to standard '1'
			forvalues i = 1/9 {
				capture confirm variable `lang'`mymac'0`i'
					if !_rc {
						ren `lang'`mymac'0`i' `lang'`mymac'`i'
					}
				}
				
			* Find length of section using database variables
			local length = 0
			forvalues i = 1/150 {
				capture confirm variable `lang'`mymac'`i'
				if !_rc {
					local length = `i'
					capture confirm string variable `lang'`mymac'`i'
						if !_rc {
							quietly: destring `lang'`mymac'`i', replace
						}
				}
			}
		}
		if `length' != 0 {
			display "Starting `lang'`section'. Length: `length'"
			** Clean the component variables
			forvalues i=1/`length' {
				quietly: recode `lang'`mymac'`i' (9=.) (99=.) (8=0) (3=0) (-1=.) (11=1)
				quietly: summarize(`lang'`mymac'`i')
		
				* Just in case there are some 3's floating around, the program will let you know
				if ("`mymac'" != "dict" & "`mymac'" != "invent_dict" & "`mymac'"!="read_comp" & "`mymac'"!="list_comp" & r(max) > 1 & r(max) !=.) | (r(min) < 0) {
					if `tested'==0 {
						local check "`check' | `lang'`section'"
						local check "`check' (`i')"
						local tested = 1
					}
					else if ("`mymac'" == "dict" | "`mymac'" == "invent_dict" | "`mymac'"=="read_comp" | "`mymac'"=="list_comp") & (r(max) > 2 & r(max) !=.) | (r(min) < 0) { /* Special cases for dictation sections */
						if `tested'==0 {
							local check "`check' | `lang'`section'"
							local check "`check' (`i')"
							local tested = 1
						}
					}
					else {
						local check "`check' (`i')"
					}
				}
				
				*Apply labels
				label variable `lang'`mymac'`i' "`lang'`section' `i'"
					label values `lang'`mymac'`i' `seclab'
			}
			
			** Reading specific cleaning for oral reading passage and reading comprehension sections
			if "`mymac'"=="read_comp" & "`readwords'"!=""{
				local j=0
				* Redo this just in case reading is done before oral */	
				capture confirm variable `lang'oral_read01
					if !_rc {
						forvalues i = 1/9 {
							ren `lang'oral_read0`i' `lang'oral_read`i'
						}
					}
				*Gen oral read attempted for word_needed
				capture confirm variable `lang'oral_read_attempted
						if !_rc {
							drop `lang'oral_read_attempted
						}
				* Redoing this because we need 2 lengths - 1 for read and one for oral */	
				forvalues i = 1/150 {
					capture confirm variable `lang'oral_read`i'
						if !_rc {
							local j = `i'
						}
				}
				egen `lang'oral_read_attempted=rownonmiss(`lang'oral_read1-`lang'oral_read`j')
				label variable `lang'oral_read_attempted "Number of oral read words that were attempted."
				capture confirm variable `lang'oral_read_auto_stop
					if !_rc{
						order `lang'oral_read_attempted, a(`lang'oral_read_auto_stop)
					}
					else{
						order `lang'oral_read_attempted, a(`lang'oral_read_time_remain)
					}
				forvalues i=1/`length'{
					local word_needed = read_word_needed[1,`i']
					quietly: recode read_comp`i' (3=.) (2=.) (1=.) (0=.) if `lang'oral_read_attempted < `word_needed'
				}
			}
			{/*Make the summary variables*/
				if ("`mymac'"=="add" | "`mymac'"=="sub" | "`mymac'"=="mult" | "`mymac'"=="div") & ///
				(`length' > 10 & "`mlevels'" == "mlevels" & "`lang'"=="") { /*Special section for leveled sections, like add, sub, mult, div */

					{/* Section summary for level 1 */
						capture confirm variable l1`mymac'_score
						if !_rc { 
							drop l1`mymac'_score
						}
						quietly: egen l1`mymac'_score=rowtotal(`mymac'1-`mymac'10), missing 

						capture confirm variable l1`mymac'_attempted
						if !_rc {
							drop l1`mymac'_attempted
						}
						quietly: egen l1`mymac'_attempted=rownonmiss(`mymac'1-`mymac'10) 
						
						capture confirm variable l1`mymac'_score_pcnt
						if !_rc { 
							drop l1`mymac'_score_pcnt
						}
						quietly: gen l1`mymac'_score_pcnt=l1`mymac'_score/10
					
						capture confirm variable l1`mymac'_score_zero
						if !_rc { 
								drop l1`mymac'_score_zero
						}
						quietly: gen l1`mymac'_score_zero= (l1`mymac'_score==0) if l1`mymac'_score<.
					
						capture confirm variable l1`mymac'_attempted_pcnt
						if !_rc { 
							drop l1`mymac'_attempted_pcnt
						}
						quietly: gen l1`mymac'_attempted_pcnt=l1`mymac'_score/l1`mymac'_attempted 
					}
					{/* Label and order level 1 variables */
						*Label summary variables
						label variable l1`mymac'_score "Total correct questions at the section end?"
						label variable l1`mymac'_score_pcnt "Total percentage of all level 1 `section' questions correct at the section end?"
						label variable l1`mymac'_score_zero "Proportion of students with zero level 1 `section' questions correct."
						label values l1`mymac'_score_zero zeroscores
						label variable l1`mymac'_attempted "Number of level 1 `section' questions that were attempted."
						label variable l1`mymac'_attempted_pcnt "Percentage correct of level 1 `section' questions that were attempted."
				
						*Ordering variables 
						capture confirm variable l1`mymac'_auto_stop
						if !_rc { 
							label variable l1`mymac'_auto_stop "Could the child not complete any level 1 `section' questions?"
							label values l1`mymac'_auto_stop yesno
						}
						else {
							capture confirm variable l1`mymac'_time_remain
							if !_rc { 
								order `mymac'1-`mymac'10 l1`mymac'_score l1`mymac'_score_pcnt l1`mymac'_score_zero l1`mymac'_time_remain l1`mymac'_attempted l1`mymac'_attempted_pcnt, b(placeholder)
								label variable l1`mymac'_time_remain "Time remaining when finished answering level 1 `section' questions?"
							}
							else {
								order `mymac'1-`mymac'10 l1`mymac'_score l1`mymac'_score_pcnt l1`mymac'_score_zero l1`mymac'_attempted l1`mymac'_attempted_pcnt, b(placeholder)
							}
						}
					}
					{/* Section summary for l2*/
					capture confirm variable l2`mymac'_score
						if !_rc { 
							drop l2`mymac'_score
						}
						quietly: egen l2`mymac'_score=rowtotal(`mymac'11-`mymac'`length'), missing 

						capture confirm variable l2`mymac'_attempted
						if !_rc {
							drop l2`mymac'_attempted
						}
						quietly: egen l2`mymac'_attempted=rownonmiss(`mymac'11-`mymac'`length') 
						
						capture confirm variable l2`mymac'_score_pcnt
						if !_rc { 
							drop l2`mymac'_score_pcnt
						}
						quietly: gen l2`mymac'_score_pcnt=l2`mymac'_score/`length'
					
						capture confirm variable l2`mymac'_score_zero
						if !_rc { 
							drop l2`mymac'_score_zero
						}
						quietly: gen l2`mymac'_score_zero= (l2`mymac'_score==0) if l2`mymac'_score<.
				
						capture confirm variable l2`mymac'_attempted_pcnt
						if !_rc { 
							drop l2`mymac'_attempted_pcnt
						}
						quietly: gen l2`mymac'_attempted_pcnt=l2`mymac'_score/l2`mymac'_attempted 
					}
					{/* Label and order level 2 and overall variables*/
						*Label summary variables
						label variable l2`mymac'_score "Total correct questions at the section end?"
						label variable l2`mymac'_score_pcnt "Total percentage of all level 2`section' questions correct at the section end?"
						label variable l2`mymac'_score_zero "Proportion of students with zero level 2 `section' questions correct."
						label values l2`mymac'_score_zero zeroscores
						label variable l2`mymac'_attempted "Number of level 2 `section' questions that were attempted."
						label variable l2`mymac'_attempted_pcnt "Percentage correct of level 2 `section' questions that were attempted."
					
						*Ordering variables 
						capture confirm variable `mymac'_autostop
						if !_rc {
							ren `mymac'_autostop `mymac'_auto_stop
						}
						capture confirm variable `mymac'_auto_stop
						if !_rc { 
							label variable `mymac'_auto_stop "Could the child not complete any level 2 `section' questions?"
							label values `mymac'_auto_stop yesno
							label variable `mymac'_time_remain "Time remaining when finished answering level 2 `section' questions?"
							order `mymac'11-`mymac'`length' l2`mymac'_score l2`mymac'_score_pcnt l2`mymac'_score_zero `mymac'_time_remain `mymac'_auto_stop l2`mymac'_attempted l2`mymac'_attempted_pcnt, a(l1`mymac'_attempted_pcnt)
						}
						else {
							capture confirm variable `mymac'_time_remain
							if !_rc { 
								order `mymac'11-`mymac'`length' l2`mymac'_score l2`mymac'_score_pcnt l2`mymac'_score_zero `mymac'_time_remain l2`mymac'_attempted l2`mymac'_attempted_pcnt, a(l1`mymac'_attempted_pcnt)
								label variable `mymac'_time_remain "Time remaining when finished answering level 2 `section' questions?"
							}
							else {
								order `mymac'11-`mymac'`length' l2`mymac'_score l2`mymac'_score_pcnt l2`mymac'_score_zero l2`mymac'_attempted l2`mymac'_attempted_pcnt, a(l1`mymac'_attempted_pcnt)
							}
						}
					}
				}
				else {
					{/*Generate section summary variables*/
						*Drop score if it already exists
						capture confirm variable `lang'`mymac'_score
						if !_rc { 
							drop `lang'`mymac'_score
						}
						*Special generation for dictation sections
						if "`mymac'"!="dict" | "`mymac'"!="invent_dict" | "`mymac'"=="read_comp" | "`mymac'"=="list_comp"{
							quietly: egen `lang'`mymac'_score1 = anycount(`lang'`mymac'1-`lang'`mymac'`length'), v(1)
							quietly: egen `lang'`mymac'_score2 = anycount(`lang'`mymac'1-`lang'`mymac'`length'), v(2)
							quietly: gen `lang'`mymac'_score=`lang'`mymac'_score1+(`lang'`mymac'_score2)/2
							drop `lang'`mymac'_score1 `lang'`mymac'_score2
						}
						else{
							quietly: egen `lang'`mymac'_score=rowtotal(`lang'`mymac'1-`lang'`mymac'`length'), missing 
						}
						
						*Attempted
						capture confirm variable `lang'`mymac'_attempted
						if !_rc {
							drop `lang'`mymac'_attempted
						}
						quietly: egen `lang'`mymac'_attempted=rownonmiss(`lang'`mymac'1-`lang'`mymac'`length') 
						quietly: replace `lang'`mymac'_attempted=`length' if "`mymac'"=="list_comp"
					
						*Score pcnt
						capture confirm variable `lang'`mymac'_score_pcnt
						if !_rc { 
							drop `lang'`mymac'_score_pcnt
						}
						quietly: gen `lang'`mymac'_score_pcnt=`lang'`mymac'_score/`length'
					
						*Zero Score
						capture confirm variable `lang'`mymac'_score_zero
						if !_rc { 
							drop `lang'`mymac'_score_zero
						}
						quietly: gen `lang'`mymac'_score_zero= (`lang'`mymac'_score==0) if `lang'`mymac'_score<.
					
						*Attempted percent
						capture confirm variable `lang'`mymac'_attempted_pcnt
						if !_rc { 
							drop `lang'`mymac'_attempted_pcnt
						}
						quietly: gen `lang'`mymac'_attempted_pcnt=`lang'`mymac'_score/`lang'`mymac'_attempted 
					}
					
					{/*Label and order variables*/ 
						*Label summary variables
						label variable `lang'`mymac'_score "Total correct questions at the section end?"
						label variable `lang'`mymac'_score_pcnt "Total percentage of all `lang'`section' questions correct at the section end?"
						label variable `lang'`mymac'_score_zero "Proportion of students with zero `lang'`section' questions correct."
						label values `mymac'_score_zero zeroscores
						label variable `lang'`mymac'_attempted "Number of `lang'`section' questions that were attempted."
						label variable `lang'`mymac'_attempted_pcnt "Percentage correct of `lang'`section' questions that were attempted."
						
						*Order
						capture confirm variable `lang'`mymac'_autostop
						if !_rc {
							ren `lang'`mymac'_autostop `lang'`mymac'_auto_stop
						}
						capture confirm variable `lang'`mymac'_auto_stop
						if !_rc { 
							label variable `lang'`mymac'_auto_stop "Could the child not complete any `lang'`section' questions?"
							label values `lang'`mymac'_auto_stop yesno
								capture confirm variable `lang'`mymac'_time_remain
							if !_rc { 
								label variable `lang'`mymac'_time_remain "Time remaining when finished answering level 1 `lang'`section' questions?"
								order `lang'`mymac'1-`lang'`mymac'`length' `lang'`mymac'_score `lang'`mymac'_score_pcnt `lang'`mymac'_score_zero `lang'`mymac'_time_remain `lang'`mymac'_auto_stop `lang'`mymac'_attempted `lang'`mymac'_attempted_pcnt, b(placeholder)
							}
							else{
								order `lang'`mymac'1-`lang'`mymac'`length' `lang'`mymac'_score `lang'`mymac'_score_pcnt `lang'`mymac'_score_zero `lang'`mymac'_auto_stop `lang'`mymac'_attempted `lang'`mymac'_attempted_pcnt, b(placeholder)
							}
						}
						else {
							capture confirm variable `lang'`mymac'_time_remain
							if !_rc { 
								order `lang'`mymac'1-`lang'`mymac'`length' `lang'`mymac'_score `lang'`mymac'_score_pcnt `lang'`mymac'_score_zero `lang'`mymac'_time_remain `lang'`mymac'_attempted `lang'`mymac'_attempted_pcnt, b(placeholder)
								label variable `lang'`mymac'_time_remain "Time remaining when finished answering `lang'`section' questions?"
							}
							else {
								order `lang'`mymac'1-`lang'`mymac'`length' `lang'`mymac'_score `lang'`mymac'_score_pcnt `lang'`mymac'_score_zero `lang'`mymac'_attempted `lang'`mymac'_attempted_pcnt, b(placeholder)
							}
						}
					}
				}
			}
		}
	}
	}



	{/* Create super-summary variables */
	order placeholder
	
	*Find whether the section exists in the database
	capture confirm variable `lang'read_comp_score_pcnt
		if !_rc { 
				*If needed, get rid of an summary variable
				capture confirm variable `lang'read_comp_score_pcnt80
				if !_rc {
					drop `lang'read_comp_score_pcnt80
				}
				*Generate and label a new one
				quietly: gen `lang'read_comp_score_pcnt80= (`lang'read_comp_score_pcnt>=.8) if `lang'read_comp_score_pcnt<.
				label values `lang'read_comp_score_pcnt80 yesno
		}

	capture confirm variable `lang'oral_read_time_remain
		if !_rc { 
				capture confirm variable `lang'orf
				if !_rc {
					drop `lang'orf
				}
				quietly: gen `lang'orf=`lang'oral_read_score/(1-(`lang'oral_read_time_remain/60))
	}
		
	capture confirm variable `lang'invent_word_time_remain
		if !_rc { 
				capture confirm variable `lang'cnonwpm
				if !_rc {
					drop `lang'cnonwpm
				}
				quietly: gen `lang'cnonwpm=`lang'invent_word_score/(1-(`lang'invent_word_time_remain/60))
	}

	capture confirm variable `lang'fam_word_time_remain
		if !_rc { 
				capture confirm variable `lang'cwpm
				if !_rc {
					drop `lang'cwpm
				}
				quietly: gen `lang'cwpm=`lang'fam_word_score/(1-(`lang'fam_word_time_remain/60))
		}
			
	capture confirm variable `lang'letter_time_remain
		if !_rc { 
				capture confirm variable `lang'clpm
				if !_rc {
					drop `lang'clpm
				}
				quietly: gen `lang'clpm=`lang'letter_score/(1-(`lang'letter_time_remain/60))
				label variable `lang'clpm "Correct Letters Per Minute"
				order `lang'clpm
		}
	
	capture confirm variable `lang'letter_sound_time_remain
		if !_rc { 
				capture confirm variable `lang'clspm
				if !_rc {
					drop `lang'clspm
				}
				quietly: gen `lang'clspm=`lang'letter_sound_score/(1-(`lang'letter_sound_time_remain/60))
		}
		
	*Order and label the super summary variables
	forvalues i =`sssections'(-1)1{
		mata: st_local("varname", ssmat[`i',1])
		mata: st_local("varlab", ssmat[`i',2])
		capture confirm variable `lang'`varname'
			if !_rc{
				order `lang'`varname', b(placeholder)
				label variable `lang'`varname' "`varlab'"

		}
	}
	}	
	{/* Label demographic variables */
	order placeholder
	
	forvalues s = 1/`demsections' {
		mata: st_local("name", demvars[`s',1])
		mata: st_local("label", demvars[`s',3])
		mata: st_local("valuelabel", demvars[`s',4])
		capture confirm variable `lang'`name'
			if !_rc {
				label variable `lang'`name' "`label'"
				if "`valuelabel'" != "" {
					label value `lang'`name' `valuelabel'
				}
				order `lang'`name', b(placeholder)
			}
	}
	}
}
{/* Post-cleaning housekeeping */
quietly: drop placeholder
if "`check'" != "" {
	di in red "Check sections for nonboolean values:`check'"
}
}


end
