{smcl}
{* 26Aug2011 - Alex Sax}{...}
{cmd: help facwts}
{hline}

{title:Makes a pie chart to show weights of significant variables.}

{title:Syntax}

{p 8 18 2}
{cmd:facwts} {help varlist}
[{it:pweight}]
{cmd:,}
{opt lab:els(}{help str}{cmd:)}
[
{opt k:eep}
{opt leg:engdoptions(}{it:str}{cmd:)}
{opt twow:ayoptions(}{it:str}{cmd:)}
{cmd:svy}
]


{title:Description}

{pstd}
{cmd:facwts} makes a pie chart showing the relative significance of different variables as well as the absolute
weights.


{title:Arguments}

{phang}
{cmd:varlist} includes all the variables that {cmd:facwts} will consider. The dependant variable must come first, 
followed by explanatory variables.


title:Options}

{phang}
{opt lab:el(}{it:str}{cmd:}} specifies whether to use {it:percent}, {it:sum}, or {it:none} to label variables.

{phang}
{opt k:eep} keeps {cmd:facwts's} output.
	
{phang}
{opt leg:engdoptions(}{it:str}{cmd:)} specifies legend options
		
{phang}		
{opt twow:ayoptions(}{it:str}{cmd:)} allows customizations for two-way graphs

{title:Weights and Variances}

{phang}
{cmd:pweight}, unless using svy, should be set to wt_final.

{phang}
{cmd:sv}{cmd:y} makes {cmd:facwts} use the svy: command.


{title:Examples}

{hline}
{pstd}
To look at relative importance of tk18, tk22, and read_comp_score_pcnt on orf. Use weights and drop junk variables that {cmd:facwts} generates

{cmd}
	use "Z:\Task 3 EGRA\Final Databases\Rwanda\EGRA EGMA SSME 2011\4. EGRMA SSME (S Te Tk Tm HT SI ECO KCO MCO).dta", clear
	
	facwts orf tk18 tk22 read_comp_score_pcnt, svy
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
Help: {help [B] pie [R] regress [R] rtiupdate [S] svy }

