* Stata Test Do-File
* Purpose: Verify Stata CLI is working correctly

* Print Stata version
display "Stata Version:"
display "version `c(version)'"

* Print platform info
display "Platform: `c(os)' `c(bit)'"

* Simple calculation test
display "Calculation test (2 + 2 = " 2 + 2 ")"

* Check if common packages are available
display "Checking common packages:"
capture which dplyr
if _rc == 0 {
    display "  ✅ dplyr is installed"
} else {
    display "  ⚠️ dplyr is NOT installed"
}

* Exit Stata
exit, clear
