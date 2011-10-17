program define rtiupdate
	program drop rtiupdate
	quietly: ado uninstall rti_egrma
	net install rti_egrma, from("Z:\Task 3 EGRA\Final Databases\User\Alex\RTIegrma")
	di "     RTI package is now up to date."
end
