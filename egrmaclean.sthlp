{smcl}
{* 26Aug2011 - Alex Sax}{...}
{cmd: help egrmaclean}
{hline}

{title:Automatically standardizes and recodes EGRMA datasets}

{title:Syntax}

{p 8 18 2}
{cmd:egrmaclean} {it:varlist}
{cmd:,}
{opt read:word}{cmd:(}{it:numlist int}{cmd:)} 
[{opt mlev:els}]

{title:Description}

{pstd}
{cmd: egraclean} cleans EGRA and EGMA data according to RTI standards.  
It creates summary variables for each existing section and labels all 
variables.  


{title:Arguments}

{phang}
{it:varlist} includes all the variables that {cmd:egrmaclean} will clean.
{cmd:egrmaclean} will leave unfamiliar variables alone, so {it:varlist} 
should almost always be -*- (omit the dashes).


{title:Options}

{phang}
{opt read:word}{cmd:(}{it:numlist int}{cmd:)} recodes reading comprehension
scores to missing if the student did not read enough to answer the
question. 

{phang}
{opt mlev:el} creates summary variables for two levels of addition,
subtraction, multiplication, and division as well as overall summary variables 
for each section.


{title:Examples}

{hline}
Read in data, then clean. Create two levels for math variables.

{cmd}
	use "Z:\Task 3 EGRA\Final Databases\Zambia\1. Zambia Data.dta", clear

	ren miss_dig_time_remain0 add_time_remain
	
	egrmaclean *, read(9 16 48 56 71) mlev
{txt}


{title:Authors}

{pstd}
Alex Sax, University of Maryland
(asax/contractor@rti.org)
Michael Costello, RTI International
(MCostello@rti.org)

{title:Also See}

{pstd}
Help: {help [S] svyset} {help [R] rtiupdate}
