* Baseline Cleaning    				   
set more off

ieboilstart, v(17.0)															
`r(version)' 
	
use "C:\Users\Dropbox\my_project\raw.dta", clear  								

* Check duplicates
duplicates drop hhid, force  													

save "clean.dta", replace  														

* Create age categories for child, adult, senior								
gen agegroup = .  
replace agegroup = 1 if age <= 18
replace agegroup = 2 if age > 18 & age <= 60
replace agegroup = 3 if age > 60

* Applying labels																
label define agegroup_lbl 1 "Child" 2 "Adult" 3 "Senior"
label values agegroup agegroup_lbl
label variable agegroup "Age group catgeory"

save "clean.dta", replace 

* Count of people by age group 													
graph bar (count), over(agegroup, label(angle(0))) bar(1, color(navy)) title("Number of Observations by Age Group") ytitle("Count") legend(off)

graph export "count_by_age.png", replace										



