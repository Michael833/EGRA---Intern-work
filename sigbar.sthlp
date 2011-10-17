{smcl}
{* 26Aug2011 - Alex Sax}{...}
{cmd: help sigbar}
{hline}

{title:Makes a bar graph of significant variables}

{title:Syntax}

{p 8 18 2}
{cmd:sigbar} {help varlist}
[{it:pweight}]
[{cmd:,}
{opt nolab:el}
{opt nogra:ph}
{opt k:eep}
{opt g:roup}{cmd:(}{help varname}{cmd:)}
{cmd: lsize(}{it:str}{cmd:)}
{opt leg:engdoptions}{cmd:(}{it:str}{cmd:)}
{opt twow:ayoptions}{cmd:(}{it:str}{cmd:)}
{cmd:svy}
]


{title:Description}

{pstd}
{cmd:sigbar} takes a list of possibly significant variables and boils it down to only significant ones.  
Once the list contains only significant variables, {cmd:sigbar} makes them into a bargraph.  {cmd:sigbar}
gives you the option of grouping these variables.


{title:Arguments}

{phang}
{cmd:varlist} includes all the variables that {cmd:sigbar} will consider. The dependant variable must come first, 
followed by explanatory variables.


{title:Options}

{phang}
{opt nolab:el} puts variable names instead of variable labels on the bargraph.

{phang}
{opt nogra:ph} prevents {cmd:sigbar} from outputting a graph and makes {cmd:sigbar} run faster.

{p 4 4 2}
{opt k:eep} keeps {cmd:sigbar's} output where:

{p 6}
{it: Variable}		- contains significant variable names.{p_end}
{p 8}
{it: Varlab}		- contains the labels of those variables.{p_end}
{p 8}
{it: change}		- contains the beta coefficients of those variables.{p_end}
	
	
{phang}
{opt g:}{cmd:roup(}{it:varname str}{cmd:)} tells {cmd:sigbar} which variable contains groups for significant variables.

{phang}
{cmd:lsize(}{it:str}{cmd:)} sets the label size on the bargraph.

{phang}
{opt leg:engdoptions}{cmd:(}{it:str}{cmd:)} specifies legend options
		
{phang}		
{opt twow:ayoptions}{cmd:(}{it:str}{cmd:)} allows customizations for two-way graphs

{title:Weights and Variances}

{phang}
{cmd:pweight}, unless using svy, should be set to wt_final.

{phang}
{cmd:sv}{cmd:y} makes {cmd:sigbar} use the svy: command.


{title:Examples}

{hline}
{pstd}
Read in weighted data.  Look at the time-on-task variables and find out which teacher actions significantly affect
student scores.

{cmd}
	use "Z:\Task 3 EGRA\Final Databases\Rwanda\EGRA EGMA SSME 2011\4. EGRMA SSME (S Te Tk Tm HT SI ECO KCO MCO).dta", clear
	
	sigbar k_orf  k_cor_pcnt*, svy
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
Help: {help [B] bargraph} {help [R] regress}  {help [S] svy}
