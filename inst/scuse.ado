prog drop _all

*! Scott Cunningham use - scuse v1.0.1  BB29
prog scuse
	version 14.2
	syntax anything [, CLEAR noDesc]
	if regexm("`anything'", ".+.zip$") {
		capt copy "https://storage.googleapis.com/causal-inference-mixtape.appspot.com/`anything'" ., replace
		if _rc != 0 {
			di as err _n "Error: cannot copy `anything' to current working directory."
			exit 
		}
		qui unzipfile "`anything'", replace
		loc fn = reverse(substr(reverse("`anything'"), 5, .))
		capt use `fn', `clear'
	}
	else {
		capt use "https://storage.googleapis.com/causal-inference-mixtape.appspot.com/`anything'", `clear'
	}
	if _rc != 0 {
 		if _rc == 4 {
 			di as err _n "Error: data in memory would be lost. Use  scuse `anything', clear  to discard changes."
 		} 
 		else if _rc == 610 {
 			di as err _n "Error: C datafile `anything' must be accessed from Stata 14.x." _n  "It cannot be read by earlier Stata versions."
 		}
 		else {
		di as err _n "Error: C datafile `anything' does not exist. Contents of memory not altered."
		}
		exit
	}
	if "`desc'" != "nodesc" { 
		describe
	}
end
// 1.0.1: Cloned -bcuse.ado- and made it -scuse.ado-
