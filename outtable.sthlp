{smcl}
{* 26Aug2011 - Alex Sax}{...}
{cmd: help outtable}
{hline}

{title:Creates and outputs a pivot table.}

{title:Syntax}

{p 8 18 2}
{cmd:outtable} {help varlist}
{cmd:,}
{cmd:over(}{help varname}{cmd:)}
{cmd:by(}{help varlist}{cmd:)}
{cmd:to(}{help varlist}{cmd:)}
[
{cmd:file}{opt typ:e}{cmd:(}{help str}{cmd:)}
{cmd:svy}
]


{title:Description}

{pstd}
{cmd:outtable} exports a pivot table to {cmd:to(}{it:str}{cmd:)}


{title:Arguments}

{phang}
{cmd:varlist} includes all the subtests that {cmd:outtable} will list


{title:Mandatory options}

{phang}
{cmd:over(}{it:varname}{cmd:)} tells {cmd:outtable} which variable to separate columns by

{phang}
{cmd:by(}{it:varlist}{cmd:)} tells {cmd:outtable} which variable to stratify rows by

{phang}
{cmd:to(}{it:varlist}{cmd:)} tells {cmd:outtable} where to output the completed table
	
	
{title:Discretionary options}

{phang}		
{cmd:file}{opt typ:e}{cmd:(}{it:str}{cmd:)} either .dta or .csv. Determines which file type the table will be. Default is .csv.

{title:Weights and Variances}

{phang}
{cmd:svy} uses the {cmd:svy} command


{title:Examples}

{hline}
{pstd}Produce a weighted table under the filename "Z:\Task 3 EGRA\Final Databases\User\Alex\testoutput.csv". 
Look under this file to see the results.

{cmd}
	. use "Z:\Task 3 EGRA\Final Databases\Zambia\3. Zambia Standard Weighted.dta", clear
	. outtable clspm cnonwpm orf, over(female) by(grade sequence) svy to(Z:\Task 3 EGRA\Final Databases\User\Alex\testoutput)
{text}


{title:Author}

{pstd}
Alex Sax, University of Maryland
(asax/contractor@rti.org)


{title:Contact}

{pstd}
Michael Costello, RTI International
(mcostello@rti.org)


{title:Also See}
Help: {help [R] egrmaclean} {help [R] rtiupdate}

