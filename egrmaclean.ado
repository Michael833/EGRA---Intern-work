* Auto Cleaning File
* Alex Sax & Michael Costello
* RTI International
* August 2011


program define egrmaclean
	syntax varlist , [readWords(numlist) LANGuages(str) MLEVels noUPdate write]
	version 11
/*
Table of Contents:
	1. Goodies
	
	2. Import labels, test sections, and summary variables from the codebook
		a. Declare empty matrices
		b. Read in the codebook
			alpha.	Copy to a local codebook
			bravo. Read local codebook into stata matrices
			charlie. Define label values from the codebook
			
	3. Prepare for cleaning
		a. Create a variable called "placeholder" to tell egrmaclean how to order each section, and a variable
			named "check" to store errors
		b. Stuff the user-entered "reading words needed" into a matrix
		c. Make a string matrix containing all the languages in the test
		d. Fix common renpfix errors
		
	4. Main cleaning
		a. Housekeeping that must be done before each new language
		b. Cleaning and ordering the Concepts of Text variables
		c. Cleaning individual sections
			alpha. Determining if section exists and other preliminaries
			bravo. Cleaning and summarizing secitons
				ash. Clean the component variables
				birch. Reading specific cleaning for oral reading passage and reading comprehension sections
				cedar. Make the summary variables
					apocalyptica. Special section for leveled sections, like add, sub, mult, div
							america. Section summary for level 1 variables
							britain. Label and order level 1 variables
							canada. Section summary for level 2 variables
							denmark. Label and order level 2 and overall variables
					beatles. Section for non-leveled sections
							america. Generate section summary variables
							britain. Label and order variables

	5. Create super-summary variables
		a. Find whether the section exists in the database
		b. Order and label the super summary variables
	
	6. Label demographic variables 
	
	7. Post-cleaning housekeeping 
*/

{/*  1. Easter Eggs*/
if "`write'"!=""{
	display "1. Goodies"
}
if "`readWords'"=="1 1 2 3 5" | "`readWords'"=="1 1 2 3 5 8"{
	di in red "IL FIBONACCI!"
	di in green `"http://mathworld.wolfram.com/FibonacciNumber.html"'
}
}
{/*  2. Import codebook contents*/
	{/*  a. Declare empty matrices */
if "`write'"!=""{
	display "2. Import labels, test sections, and summary variables from the codebook"
	display ".	a. Declare empty matrices"
}
mata: demographicInfo = ("","","",""\ ///
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
mata: testSectionInfo = demographicInfo
mata: labelInfo = demographicInfo
mata: superSummaryInfo = demographicInfo
mata: langMatrix = demographicInfo /*Use this in the pre-cleaning housekeeping section*/
}

	{/*  b. Read in the codebook */
		{/*  alpha.	Copy a local codebook*/
	if "`write'"!=""{
		display ".	b. Read in the codebook"
		display ".		alpha. Copy to a local codebook"
	}
	preserve 
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
			display "Updated local codebook"
		}
	}
	
		{/*  bravo. Read local codebook into stata matrices */
	if "`write'"!=""{
		display "		bravo. Read local codebook into stata matrices"
	}
	import excel using "C:\Program Files\Stata12\docs\Codebook for EGRA & EGMA.xlsx", clear firstrow sheet("Demographics")
		local demsections = _N
		forvalues i=1/4 {
			forvalues j=1/`demsections'{
				local contents = DemographicVariables`i' in `j'
				*If we want to drop contents of cell, preface it with "."
				if substr("`contents'",1,1)!="."{
					mata: demographicInfo[`j',`i'] = `"`contents'"'
				}
				else {
					mata: demographicInfo[`j',`i'] = ""
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
					mata: testSectionInfo[`j',`i'] = `"`contents'"'
				}
				else {
					mata: testSectionInfo[`j',`i'] = ""
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
					mata: labelInfo[`j',`i'] = `"`contents'"'
				}
				else {
					mata: labelInfo[`j',`i'] = ""
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
					mata: superSummaryInfo[`j',`i'] = `"`contents'"'
				}
				else {
					mata: superSummaryInfo[`j',`i'] = ""
				}
			}
		}	
	restore
	}

		{/*  charlie. Define label values from the codebook */
	if "`write'"!=""{
		display "		charlie. Define label values from the codebook"
	}
	forvalues i=1/`labsections'{
		mata: st_local("label", labelInfo[`i',2])
		mata: st_local("labelName", labelInfo[`i',1])
		if "`label'" != ""{
			local labelDefine ""
			local labelLength = wordcount("`label'")/2
			forvalues j=1/`labelLength' {
				local k = 2*`j'
				local o = 2*`j' - 1
				local word : word `k' of `label'
				local num : word `o' of `label'
				local word = subinstr("`word'","_"," ",.)
				local labelDefine `"`labelDefine' `num' "`word'""'
			}
			label define `labelName' `labelDefine', replace 
		}
	}
	}

}
}
{/*  3. Pre-cleaning housekeeping*/
	{/*  a.  Create placeholder */
	if "`write'"!=""{
		display "3. Prepare for cleaning"
		display `".	a. Create a variable called "placeholder" to tell egrmaclean how to order each section, and a variable named "check" to store errors"'
	}
	capture confirm variable placeholder
		if _rc{
			quietly: gen placeholder = .
		}
	order placeholder, first
	
	*A string that will store the "nonboolean" warning
	local check ""
	}
	{/*  b.  "Reading words needed" matrix */
	if "`write'"!=""{
		display `".	b. Stuff the user-entered "reading words needed" into a matrix"'
	}
	if "`readWords'"!=""{
		local readWordsLength = wordcount("`readWords'")

		*length of the reading word requirement list = readWords
		local readWord ""
		forvalues i = 1/`readWordsLength' {
			local thisWord : word `i' of `readWords'
			local readWord "`readWord'`thisWord',"
		}
		matrix input readWordNeeded = (`readWord'0)  /* 0 is a placeholder to fill the last element. */
	}
	}
	{/*  c.  Make a language matrix */
	if "`write'"!=""{
		display "	c. Make a string matrix containing all the languages in the test"
	}
	local numberOfLanguages = 1 /*Even if the user doesn't specify additional languages, the test still has the main one */ 
	if "`languages'"!=""{
		*Determine how many languages there are and save them in a matrix
		local numberOfLanguages = 1 + wordcount("`languages'")
		forvalues i = 1/`numberOfLanguages' {
			local j = `i'+1
			local thisLanguage : word `i' of `languages'
			mata: langMatrix[`j',1] = "`thisLanguage'"
		}
	}
	}


	{/*  d.  Fix common renpfix errors */
	if "`write'"!=""{
		display ".	d. Fix common renpfix errors"
	}
	forvalues langnum = 1/`numberOfLanguages'{
		mata: st_local("lang", langMatrix[`langnum',1])
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
	}
{/*  4,5,6 are in the language loop */
forvalues langnum = `numberOfLanguages'(-1)1{
	{/*  4. Main cleaning */
		{/*  a. Housekeeping */
		if "`write'"!=""{
			display "4. Main cleaning"
			display ".	a. Housekeeping that must be done before each new language"
		}
		order placeholder
		
		* Define language
		mata: st_local("lang", langMatrix[`langnum',1])
		di "`lang'"
		}
		{/*  b. Concepts of Text */
		if "`write'"!=""{
			display ".	b. Cleaning and ordering the Concepts of Text variables"
		}
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
		{/*  c. Section cleaning */
		forvalues s = 2/`possiblesections' {
			{/*  alpha. Determining if section exists and other preliminaries */
			if "`write'"!=""{
				display ".	c. Cleaning individual sections"
				display ".		alpha. Determining if section exists and other preliminaries"
			}
			local tested = 0
			mata: st_local("currentSection", testSectionInfo[`s',1])
			mata: st_local("section", testSectionInfo[`s',2])
			mata: st_local("sectionValueLabelName", testSectionInfo[`s',3])
			capture confirm variable `lang'`currentSection'*
				if !_rc {
					order `lang'`currentSection'*, a(placeholder)
				}
			* Recode '01' to standard '1'
			forvalues i = 1/9 {
				capture confirm variable `lang'`currentSection'0`i'
					if !_rc {
						ren `lang'`currentSection'0`i' `lang'`currentSection'`i'
					}
				}
				
			* Find length of section using database variables
			local length = 0
			forvalues i = 1/150 {
				capture confirm variable `lang'`currentSection'`i'
				if !_rc {
					local length = `i'
					capture confirm string variable `lang'`currentSection'`i'
						if !_rc {
							quietly: destring `lang'`currentSection'`i', replace
						}
				}
			}
		}
			{/*  bravo. Cleaning and summarizing secitons */
		if `length' != 0 {
			display "Starting `lang'`section'. Length: `length'"
				{/*  ash. Clean the component variables */
			if "`write'"!=""{
				display ".		bravo. leaning and summarizing secitons"
				display ".			ash. Clean the component variables"

			}
			forvalues i=1/`length' {
				quietly: recode `lang'`currentSection'`i' (9=.) (99=.) (8=0) (3=0) (-1=.) (11=1)
				quietly: summarize(`lang'`currentSection'`i')
		
				* Just in case there are some 3's floating around, the program will let you know
				if ("`sectionValueLabelName'" != "compdict" & r(max) > 1 & r(max) !=.) | (r(min) < 0) {
					if `tested'==0 {
						local check "`check' | `lang'`section'"
						local check "`check' (`i')"
						local tested = 1
					}
					else if ("`sectionValueLabelName'" == "compdict") & (r(max) > 2 & r(max) !=.) | (r(min) < 0) { /* Special cases for dictation sections */
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
				label variable `lang'`currentSection'`i' "`lang'`section' `i'"
					label values `lang'`currentSection'`i' `sectionValueLabelName'
			}
			
			}
				{/*  birch. Reading specific cleaning for oral reading passage and reading comprehension sections */
			if "`write'"!=""{
				display ".			birch. Clean the component variables"
			}
			if "`currentSection'"=="read_comp" & "`readWords'"!=""{
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
					local word_needed = readWordNeeded[1,`i']
					quietly: recode read_comp`i' (3=.) (2=.) (1=.) (0=.) if `lang'oral_read_attempted < `word_needed'
				}
			}
			}
				{/*  cedar. Make the summary variables*/
					/*  apocalyptica. Special section for leveled sections, like add, sub, mult, div */ if ("`currentSection'"=="add" | "`currentSection'"=="sub" | "`currentSection'"=="mult" | "`currentSection'"=="div") & ///
																						(`length' > 10 & "`mlevels'" == "mlevels" & "`lang'"=="") { /*Alex, I'm not sure about this length statement */	

					{/*  america. Section summary for level 1 variables*/
						if "`write'"!=""{
							display ".				apocalyptica. Special section for leveled sections, like add, sub, mult, div"
							display ".					america. Section summary for level 1 variables"
						}
						capture confirm variable l1`currentSection'_score
						if !_rc { 
							drop l1`currentSection'_score
						}
						quietly: egen l1`currentSection'_score=rowtotal(`currentSection'1-`currentSection'10), missing 

						capture confirm variable l1`currentSection'_attempted
						if !_rc {
							drop l1`currentSection'_attempted
						}
						quietly: egen l1`currentSection'_attempted=rownonmiss(`currentSection'1-`currentSection'10) 
						
						capture confirm variable l1`currentSection'_score_pcnt
						if !_rc { 
							drop l1`currentSection'_score_pcnt
						}
						quietly: gen l1`currentSection'_score_pcnt=l1`currentSection'_score/10
						quietly: summarize l1`currentSection'_score_pcnt
							if(r(max)>1 & r(max)<.) {
								display in red "QC:l1`currentSection'_score_pcnt is greater than 100%"
							}
							if r(max)<1  {
								display in red "QC:l1`currentSection'_score_pcnt no student scored 100%"
							}
					
						capture confirm variable l1`currentSection'_score_zero
						if !_rc { 
								drop l1`currentSection'_score_zero
						}
						quietly: gen l1`currentSection'_score_zero= (l1`currentSection'_score==0) if l1`currentSection'_score<.
					
						capture confirm variable l1`currentSection'_attempted_pcnt
						if !_rc { 
							drop l1`currentSection'_attempted_pcnt
						}
						quietly: gen l1`currentSection'_attempted_pcnt=l1`currentSection'_score/l1`currentSection'_attempted 
					}
					{/*  britain. Label and order level 1 variables */
						if "`write'"!=""{
							display ".					britain. Label and order level 1 variables"
						}
						*Label summary variables
						label variable l1`currentSection'_score "Total correct questions at the section end?"
						label variable l1`currentSection'_score_pcnt "Total percentage of all level 1 `section' questions correct at the section end?"
						label variable l1`currentSection'_score_zero "Proportion of students with zero level 1 `section' questions correct."
						label values l1`currentSection'_score_zero zeroscores
						label variable l1`currentSection'_attempted "Number of level 1 `section' questions that were attempted."
						label variable l1`currentSection'_attempted_pcnt "Percentage correct of level 1 `section' questions that were attempted."
				
						*Ordering variables 
						capture confirm variable l1`currentSection'_auto_stop
						if !_rc { 
							label variable l1`currentSection'_auto_stop "Could the child not complete any level 1 `section' questions?"
							label values l1`currentSection'_auto_stop yesno
						}
						else {
							capture confirm variable l1`currentSection'_time_remain
							if !_rc { 
								order `currentSection'1-`currentSection'10 l1`currentSection'_score l1`currentSection'_score_pcnt l1`currentSection'_score_zero l1`currentSection'_time_remain l1`currentSection'_attempted l1`currentSection'_attempted_pcnt, b(placeholder)
								label variable l1`currentSection'_time_remain "Time remaining when finished answering level 1 `section' questions?"
							}
							else {
								order `currentSection'1-`currentSection'10 l1`currentSection'_score l1`currentSection'_score_pcnt l1`currentSection'_score_zero l1`currentSection'_attempted l1`currentSection'_attempted_pcnt, b(placeholder)
							}
						}
					}
					{/*  canada. Section summary for level 2 variables*/
					if "`write'"!=""{
							display ".					canada. Section summary for level 2 variables"
					}
					capture confirm variable l2`currentSection'_score
						if !_rc { 
							drop l2`currentSection'_score
						}
						quietly: egen l2`currentSection'_score=rowtotal(`currentSection'11-`currentSection'`length'), missing 

						capture confirm variable l2`currentSection'_attempted
						if !_rc {
							drop l2`currentSection'_attempted
						}
						quietly: egen l2`currentSection'_attempted=rownonmiss(`currentSection'11-`currentSection'`length') 
						
						capture confirm variable l2`currentSection'_score_pcnt
						if !_rc { 
							drop l2`currentSection'_score_pcnt
						}
						quietly: gen l2`currentSection'_score_pcnt=l2`currentSection'_score/`length'
						quietly: summarize l2`currentSection'_score_pcnt
							if(r(max)>1 & r(max)<.) {
								display in red "QC:l2`currentSection'_score_pcnt is greater than 100%"
							}
							if r(max)<1  {
								display in red "QC:l2`currentSection'_score_pcnt no student scored 100%"
							}
					
						capture confirm variable l2`currentSection'_score_zero
						if !_rc { 
							drop l2`currentSection'_score_zero
						}
						quietly: gen l2`currentSection'_score_zero= (l2`currentSection'_score==0) if l2`currentSection'_score<.
				
						capture confirm variable l2`currentSection'_attempted_pcnt
						if !_rc { 
							drop l2`currentSection'_attempted_pcnt
						}
						quietly: gen l2`currentSection'_attempted_pcnt=l2`currentSection'_score/l2`currentSection'_attempted 
					}
					{/*  denmark. Label and order level 2 and overall variables*/
						if "`write'"!=""{
								display ".					denmark. Label and order level 2 and overall variables"
						}	
						*Label summary variables
						label variable l2`currentSection'_score "Total correct questions at the section end?"
						label variable l2`currentSection'_score_pcnt "Total percentage of all level 2`section' questions correct at the section end?"
						label variable l2`currentSection'_score_zero "Proportion of students with zero level 2 `section' questions correct."
						label values l2`currentSection'_score_zero zeroscores
						label variable l2`currentSection'_attempted "Number of level 2 `section' questions that were attempted."
						label variable l2`currentSection'_attempted_pcnt "Percentage correct of level 2 `section' questions that were attempted."
					
						*Ordering variables 
						capture confirm variable `currentSection'_autostop
						if !_rc {
							ren `currentSection'_autostop `currentSection'_auto_stop
						}
						capture confirm variable `currentSection'_auto_stop
						if !_rc { 
							label variable `currentSection'_auto_stop "Could the child not complete any level 2 `section' questions?"
							label values `currentSection'_auto_stop yesno
							label variable `currentSection'_time_remain "Time remaining when finished answering level 2 `section' questions?"
							order `currentSection'11-`currentSection'`length' l2`currentSection'_score l2`currentSection'_score_pcnt l2`currentSection'_score_zero `currentSection'_time_remain `currentSection'_auto_stop l2`currentSection'_attempted l2`currentSection'_attempted_pcnt, a(l1`currentSection'_attempted_pcnt)
						}
						else {
							capture confirm variable `currentSection'_time_remain
							if !_rc { 
								order `currentSection'11-`currentSection'`length' l2`currentSection'_score l2`currentSection'_score_pcnt l2`currentSection'_score_zero `currentSection'_time_remain l2`currentSection'_attempted l2`currentSection'_attempted_pcnt, a(l1`currentSection'_attempted_pcnt)
								label variable `currentSection'_time_remain "Time remaining when finished answering level 2 `section' questions?"
							}
							else {
								order `currentSection'11-`currentSection'`length' l2`currentSection'_score l2`currentSection'_score_pcnt l2`currentSection'_score_zero l2`currentSection'_attempted l2`currentSection'_attempted_pcnt, a(l1`currentSection'_attempted_pcnt)
							}
						}
					}
				}
					/*  beatles. Section for non-leveled sections */  else {
					{/*  america. Generate section summary variables*/
						if "`write'"!=""{
							display ".				beatles. Section for non-leveled sections"
							display ".					america. Generate section summary variables"
						}
						*Drop score if it already exists
						capture confirm variable `lang'`currentSection'_score
						if !_rc { 
							drop `lang'`currentSection'_score
						}
						*Special generation for dictation sections
						if "`sectionValueLabelName'"=="compdict"{
							quietly: egen `lang'`currentSection'_score1 = anycount(`lang'`currentSection'1-`lang'`currentSection'`length'), v(1)
							quietly: egen `lang'`currentSection'_score2 = anycount(`lang'`currentSection'1-`lang'`currentSection'`length'), v(2)
							quietly: gen `lang'`currentSection'_score=`lang'`currentSection'_score1+(`lang'`currentSection'_score2)/2
							drop `lang'`currentSection'_score1 `lang'`currentSection'_score2
							** If the section is missing, this should take the 0's returned by -anycount- and change them to missing.
							quietly: recode `lang'`currentSection'_score (0=.) if missing(`lang'`currentSection'1-`lang'`currentSection'`length') 
						}
						else{
							quietly: egen `lang'`currentSection'_score=rowtotal(`lang'`currentSection'1-`lang'`currentSection'`length'), missing 
						}
						
						*Attempted
						capture confirm variable `lang'`currentSection'_attempted
						if !_rc {
							drop `lang'`currentSection'_attempted
						}
						quietly: egen `lang'`currentSection'_attempted=rownonmiss(`lang'`currentSection'1-`lang'`currentSection'`length') 
						quietly: replace `lang'`currentSection'_attempted=`length' if "`currentSection'"=="list_comp"
					
						*Score pcnt
						capture confirm variable `lang'`currentSection'_score_pcnt
						if !_rc { 
							drop `lang'`currentSection'_score_pcnt
						}
						quietly: gen `lang'`currentSection'_score_pcnt=`lang'`currentSection'_score/`length'
						quietly: summarize `lang'`currentSection'_score_pcnt
							if(r(max)>1 & r(max)<.) {
								display in red "QC:`lang'`currentSection'_score_pcnt is greater than 100%"
							}
							if r(max)<1  {
								display in red "QC:`lang'`currentSection'_score_pcnt no student scored 100%"
							}
					
						*Zero Score
						capture confirm variable `lang'`currentSection'_score_zero
						if !_rc { 
							drop `lang'`currentSection'_score_zero
						}
						quietly: gen `lang'`currentSection'_score_zero= (`lang'`currentSection'_score==0) if `lang'`currentSection'_score<.
					
						*Attempted percent
						capture confirm variable `lang'`currentSection'_attempted_pcnt
						if !_rc { 
							drop `lang'`currentSection'_attempted_pcnt
						}
						quietly: gen `lang'`currentSection'_attempted_pcnt=`lang'`currentSection'_score/`lang'`currentSection'_attempted 
					}
					
					{/*  britain. Label and order variables*/ 
						if "`write'"!=""{
							display ".					britain. Generate section summary variables"
						}
						*Label summary variables
						label variable `lang'`currentSection'_score "Total correct `lang'`section' questions."
						label variable `lang'`currentSection'_score_pcnt "Percentage of `lang'`section' questions correct."
						label variable `lang'`currentSection'_score_zero "Student scored zero on `lang'`section' section."
						label values `currentSection'_score_zero zeroscores
						label variable `lang'`currentSection'_attempted "Number of `lang'`section' questions attempted."
						label variable `lang'`currentSection'_attempted_pcnt "Percentage of attempted `lang'`section' questions correct."
						
						*Order
						capture confirm variable `lang'`currentSection'_autostop
						if !_rc {
							ren `lang'`currentSection'_autostop `lang'`currentSection'_auto_stop
						}
						capture confirm variable `lang'`currentSection'_auto_stop
						if !_rc { 
							label variable `lang'`currentSection'_auto_stop "Could the child not complete any `lang'`section' questions?"
							label values `lang'`currentSection'_auto_stop yesno
								capture confirm variable `lang'`currentSection'_time_remain
							if !_rc { 
								label variable `lang'`currentSection'_time_remain "Time remaining when finished answering level 1 `lang'`section' questions?"
								order `lang'`currentSection'1-`lang'`currentSection'`length' `lang'`currentSection'_score `lang'`currentSection'_score_pcnt `lang'`currentSection'_score_zero `lang'`currentSection'_time_remain `lang'`currentSection'_auto_stop `lang'`currentSection'_attempted `lang'`currentSection'_attempted_pcnt, b(placeholder)
							}
							else{
								order `lang'`currentSection'1-`lang'`currentSection'`length' `lang'`currentSection'_score `lang'`currentSection'_score_pcnt `lang'`currentSection'_score_zero `lang'`currentSection'_auto_stop `lang'`currentSection'_attempted `lang'`currentSection'_attempted_pcnt, b(placeholder)
							}
						}
						else {
							capture confirm variable `lang'`currentSection'_time_remain
							if !_rc { 
								order `lang'`currentSection'1-`lang'`currentSection'`length' `lang'`currentSection'_score `lang'`currentSection'_score_pcnt `lang'`currentSection'_score_zero `lang'`currentSection'_time_remain `lang'`currentSection'_attempted `lang'`currentSection'_attempted_pcnt, b(placeholder)
								label variable `lang'`currentSection'_time_remain "Time remaining when finished answering `lang'`section' questions?"
							}
							else {
								order `lang'`currentSection'1-`lang'`currentSection'`length' `lang'`currentSection'_score `lang'`currentSection'_score_pcnt `lang'`currentSection'_score_zero `lang'`currentSection'_attempted `lang'`currentSection'_attempted_pcnt, b(placeholder)
							}
						}
					}
				}
			}
		}
	}
	}
	}
	}
	{/*  5. Create super-summary variables */
	order placeholder
	{/*  a. Find whether the section exists in the database*/
	if "`write'"!=""{
			display "5. Create super-summary variables"
			display ".	a. Find whether the section exists in the database"
	}
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
				quietly: summarize `lang'orf
				if(r(max)>150 & r(max)<.) {
					display in red "QC:`lang'orf is greater than 150 word per minute"
				}
	}
		
	capture confirm variable `lang'invent_word_time_remain
		if !_rc { 
				capture confirm variable `lang'cnonwpm
				if !_rc {
					drop `lang'cnonwpm
				}
				quietly: gen `lang'cnonwpm=`lang'invent_word_score/(1-(`lang'invent_word_time_remain/60))
				quietly: summarize `lang'cnonwpm
				if(r(max)>150 & r(max)<.) {
					display in red "QC:`lang'cnonwpm is greater than 150 invented word per minute"
				}
	}

	capture confirm variable `lang'fam_word_time_remain
		if !_rc { 
				capture confirm variable `lang'cwpm
				if !_rc {
					drop `lang'cwpm
				}
				quietly: gen `lang'cwpm=`lang'fam_word_score/(1-(`lang'fam_word_time_remain/60))
				quietly: summarize `lang'cwpm
				if(r(max)>150 & r(max)<.) {
					display in red "QC:`lang'cwpm is greater than 150 familiar word per minute"
				}
		}
			
	capture confirm variable `lang'letter_time_remain
		if !_rc { 
				capture confirm variable `lang'clpm
				if !_rc {
					drop `lang'clpm
				}
				quietly: gen `lang'clpm=`lang'letter_score/(1-(`lang'letter_time_remain/60))
				quietly: summarize `lang'clpm
				if(r(max)>150 & r(max)<.) {
					display in red "QC:`lang'clpm is greater than 150 letters per minute"
				}
		}
	
	capture confirm variable `lang'letter_sound_time_remain
		if !_rc { 
				capture confirm variable `lang'clspm
				if !_rc {
					drop `lang'clspm
				}
				quietly: gen `lang'clspm=`lang'letter_sound_score/(1-(`lang'letter_sound_time_remain/60))
				quietly: summarize `lang'clspm
				if(r(max)>150 & r(max)<.) {
					display in red "QC:`lang'clspm is greater than 150 letter sounds per minute"
				}
		}
	}
	
	{/*  b. Order and label the super summary variables */
	if "`write'"!=""{
			display ".	b. Order and label the super summary variables"
	}
	forvalues i =1(1)`sssections'{
		mata: st_local("varname", superSummaryInfo[`i',1])
		mata: st_local("varlab", superSummaryInfo[`i',2])
		capture confirm variable `lang'`varname'
			if !_rc{
				order `lang'`varname', b(placeholder)
				label variable `lang'`varname' "`varlab'"

		}
	}
	}
	}
	{/*  6. Label demographic variables */
	if "`write'"!=""{
			display "6. Label demographic variables"
	}
	order placeholder
	
	forvalues s = 1/`demsections' {
		mata: st_local("name", demographicInfo[`s',1])
		mata: st_local("label", demographicInfo[`s',3])
		mata: st_local("valuelabel", demographicInfo[`s',4])
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
}
{/*  7. Post-cleaning housekeeping */
if "`write'"!=""{
	display "7. Post-cleaning housekeeping "
}
quietly: drop placeholder
if "`check'" != "" {
	display in red "Check sections for nonboolean values:`check'"
}
}


end
