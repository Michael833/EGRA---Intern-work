/* 	Control Factor Analysis
	Alex Sax
	RTI International
	8-17-2011
*/ 


program define cfa
	syntax varlist [pweight]
	set mat 4000
	version 11

	*Find the beta coeficients
	regress `varlist' [`weight'`exp']
	
	
	*Make the variables standard, so the program can work with them
	gen constant = 0
	mkmat `varlist' constant, mat(B)
	svmat float B
	drop B1
	
	*Find length of out varlist
	local length = 2
	local again = 1
	while `again' == 1 {
		capture confirm variable B`length'
				if !_rc {
					local length = `length' + 1
				}
				else {
					local length = `length' - 1
					local again = 0
				}	
	}  
	drop constant
				
	*Make a variable matrix			
	mkmat B2-B`length', mat(hvars)
	drop B2-B`length'
	*Multiply by transposed coefficient matrix
			matrix CT = e(b)'
			matrix def _controls = hvars*CT			
	*Make it a variable
	svmat float _controls

end
