* SAS Test Program;
* Purpose: Verify SAS CLI is working correctly;

* Print SAS version;
%put NOTE: SAS Version: &sysvlong4;
%put NOTE: Platform: &sysscp &sysbit;

* Simple calculation test;
data _null_;
    result = 2 + 2;
    put "Calculation test (2 + 2 = " result ")";
run;

* Check if common procedures are available;
%put NOTE: Checking common procedures:;
proc options option=validvarname;
run;

%put NOTE: ✅ SAS test completed successfully!;
