* RRF 2025 - Analyzing Data Template	
*-------------------------------------------------------------------------------	
* Load data
*------------------------------------------------------------------------------- 
	ssc install ietoolkit
	*load analysis data 
use "${data}/Final/TZA_CCT_analysis.dta"	, clear
*set scheme plotplainplain
*-------------------------------------------------------------------------------	
* Exploratory Analysis
*------------------------------------------------------------------------------- 
	
	* Area over treatment by districts 
	gr bar 	area_acre_w, ///
			over(treatment) ///
			by(district)

*-------------------------------------------------------------------------------	
* Final Analysis
*------------------------------------------------------------------------------- 


	* Bar graph by treatment for all districts 
	gr bar 	area_acre_w, ///
			over(treatment) ///
			asy ///
			by(district, legend(pos(6)) row(1) ///
			title(Area cultivated)) /// 
			legend(row(1) order(0 "Assignment:" 1 "Control" 2 "Treatment")) ///
			blabel(total, pos(top) format(%3.2gc)) ///
			ytitle("Average area cultivited - acres") ///
			subtitle(, pos(6) bcolor(none)) ///
			note("")
	gr export "$outputs/fig1.png", replace	
	
	* Distribution of non food consumption by female headed hhs with means
forvalues hh_head = 0/1 {
	sum nonfood_cons_usd_w if female_head==`hh_head' 
	local `hh_head'_nonfood_mean = round(`r(mean)', 0.1)
}
	twoway	(kdensity nonfood_cons_usd_w if female_head==1, color(red)) ///
			(kdensity nonfood_cons_usd_w if female_head==0, color(dknavy)) ///
			, ///
			xline(`1_nonfood_mean', lcolor(red) 	lpattern(-)) ///
			xline(`0_nonfood_mean', lcolor(dknavy) 	lpattern(-)) ///
			leg(order(0 "Household Head:" 1 "Female" 2 "Male" ) row(1) pos(6)) /// 
			xtitle("Non Food consumption") ///
			ytitle("Density") ///
			title("Distribution of Non Food consumption across households") ///
			xlabel(`1_nonfood_mean', add) ///
			note("Dashed lines represent the mean of nonfood consumption for each gender")
			
	gr export "$outputs/fig2.png", replace	
	
*-------------------------------------------------------------------------------	
* Summary stats
*------------------------------------------------------------------------------- 

	* defining globals with variables used for summary
	global sumvars 	hh_size n_child_5 n_elder read sick female_head ///
	livestock_now area_acre_w drought_flood crop_damage
	
	estpost sum  $sumvars
	
	* Summary table - overall and by districts
	eststo all: 	estpost sum $sumvars
	eststo district_1: estpost sum $sumvars if district==1
	eststo district_2: estpost sum $sumvars if district==2
	eststo district_3: estpost sum $sumvars if district==3
	
	
	* Exporting table in csv
	esttab 	all district_* ///
			using "${outputs}/summary_1.csv", replace ///
			label ///
			refcat(hhsize "HH Chars" drought_flood "Shocks" ) ///
			main(mean %6.2f) aux(sd) ///
			mtitle("Full sample" "Kibaha" "Bagamoyos" "Chamwino") ///
			nonotes addn(Mean with standards deviations in parentheses)
			
			
	
	* Also export in tex for latex
*
			
			
*-------------------------------------------------------------------------------	
* Balance tables
*------------------------------------------------------------------------------- 	
	/*
	* Balance (if they purchased cows or not)
	iebaltab 	$sumvars , ///
				grpvar(treatment) ///
				rowvarlabels	///
				format(???)	///
				savecsv(???) ///
				savetex(???) ///
				nonote addnote(???) replace 	
	*/			
*
				
*-------------------------------------------------------------------------------	
* Regressions
*------------------------------------------------------------------------------- 				
				
	* Model 1: Regress of food consumption value on treatment
	regress food_cons_usd_w treatment 
	estadd local clustering "No"
	eststo mod1		// store regression results
	
	
	* Model 2: Add controls 
	regress food_cons_usd_w treatment crop_damage drought_flood
	estadd local clustering "No"
	eststo mod2 // store regression results	
	
	* Model 3: Add clustering by village
	regress food_cons_usd_w treatment crop_damage drought_flood, vce(cluster vid)
	estadd local clustering "Yes"
	eststo mod3 // store regression results	
	
	* Export results in tex
	esttab 	mod1 mod2 mod3 ///
			using "${outputs}/regression.csv" , ///
			label ///
			b(%9.2f) se(%9.2f) ///
			nomtitles ///
			mgroup("Food consumption", pattern(1 0 0 ) span) ///
			scalars("clustering Clustering") ///
			replace
		
*-------------------------------------------------------------------------------			
* Graphs: Secondary data
*-------------------------------------------------------------------------------			

	use "${data}/Final/TZA_amenity_analysis.dta", clear
	
	* createa  variable to highlight the districts in sample
	gen in_sample = inlist(district, 1,3, 6)
	* Separate indicators by sample
	separate n_school, 		by(in_sample)
	separate n_medical, 		by(in_sample)
	* Graph bar for number of schools by districts
	gr hbar 	n_school0  n_school1 , ///
				nofill ///
				over(district, sort(n_school)) ///
				legend(order(0 "Sample:" 1 "Out" 2 "In") row(1)  pos(6)) ///			
				ytitle("Number of schools") ///
				name(g1, replace)
				
	* Graph bar for number of medical facilities by districts				
	gr hbar 	n_medical0 n_medical1, ///
				nofill ///
				over(district, sort(n_medical)) ///
				legend(order(0 "Sample:" 1 "Out" 2 "In") row(1)  pos(6)) ///
				ytitle("Number of Hospitals") ///
				name(g2, replace)
				
	grc1leg2 	g1 g2, ///
				row(1)  ///
				ycommon xcommon ///
				title("Cool", size(1))
			
	
	gr export "$outputs/fig3.png", replace		

****************************************************************************end!			
