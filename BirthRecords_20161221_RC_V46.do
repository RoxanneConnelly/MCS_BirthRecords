STOP
********************************************************************************
/*

An investigation of the consistency of parental occupational information in UK 
birth records and a national social survey.

ROXANNE CONNELLY Roxanne.Connelly@warwick.ac.uk @ConnellyRoxanne
VERNON GAYLE vernon.gayle@ed.ac.uk @profbigvern

Published in EUROPEAN SOCIOLOGICAL REVIEW


Abstract:
In the UK new sources of administrative social science data are unfolding 
rapidly but the quality of these new forms of data for sociological research 
is yet to be established. We investigate the quality and consistency of the 
parental occupational information that is officially recorded on administrative 
birth records by undertaking a comparison with information collected from the 
same parents in the UK Millennium Cohort Study (MCS). We detect a large amount 
of missing information in the birth records and a range of inconsistencies. We 
present an empirical analysis of MCS data using parental social class measures 
derived both from the birth records and the survey to assess the effects of 
these discrepancies. We conclude that parental occupational information from 
administrative birth records should not be assumed, a priori, to be suitable 
for sociological analyses and that further research should be undertaken into 
their consistency and accuracy.


********************************************************************************
****Notes

Original Aim - To Assess the accuracy of occupations reported on birth
				records using linked data from the UK Millennium Cohort Study
				
Link to useful info on MCS1 derived variables http://tinyurl.com/j3ljsnc


********************************************************************************
****Data

Millennium Cohort Study 1st Survey (2001-03) SN4683 (Downloaded 30/03/2016)

Millennium Cohort Study Birth Registration and Maternity Hospital 
Episode Dataset SN5614 (Downloaded 30/03/2016)

British Household Panel Survey: Waves 1-18 (1991-2009) SN5152 
(Downloaded 30/03/2016)

																			*/
********************************************************************************
****Set-Up

global path1 "E:\Data\RAWDATA"
global path2 "E:\Data\MYDATA\WORK"
global path3 "E:\Data\MYDATA\TEMP"
global path4 "E:\Data\MYDATA\FINAL"

clear
capture log close
capture log using $path3\log_MCSBirthRecords.txt, replace text
																			
********************************************************************************








***STAGE 1 : PREPARING THE BIRTH RECORDS DATA



*****Birth Records Data
*The Birth records are stored in separate files for each nation

********************************************************************************
**ENGLAND

use $path1\ARCHIVE\MCS_reg\br_eng_ns.dta, clear

keep mcsid cnum mocccd focccd country mothemp fathemp ///
mnssec fnssec

numlabel, add

*Keep only one baby per family and we are interested in the parents
tab cnum
keep if cnum==1
tab cnum
drop cnum

*country of registration
tab country, mi
*mothers occupation (SOC2000)
tab mocccd, mi
*fathers occupation (SOC2000)
tab focccd, mi

describe

keep mcsid country mocccd focccd
capture drop miss
egen miss = rmiss(mcsid country mocccd focccd)
tab miss
*one case has missing information for mother's occupation

*check all England
tab country

sort mcsid

save $path3\MCS_BR_ENG.dta, replace




********************************************************************************
**WALES

use $path1\ARCHIVE\MCS_reg\br_wales_ns.dta, clear

keep mcsid cnum mocccd focccd country mothemp fathemp ///
mnssec fnssec

numlabel, add

*Keep only one baby per family and we are interested in the parents
tab cnum
keep if cnum==1
tab cnum
drop cnum

*country of registration
tab country, mi
*mothers occupation (SOC2000)
tab mocccd, mi
*fathers occupation (SOC2000)
tab focccd, mi

describe

keep mcsid country mocccd focccd
capture drop miss
egen miss = rmiss(mcsid country mocccd focccd)
tab miss
*no missing information

*check all Wales
tab country

sort mcsid

save $path3\MCS_BR_WALES.dta, replace






/*******************************************************************************
**Northern Ireland

The NI occupational information is in SOC90 format, the occupational 
data in the other nations is in SOC2000 format. The occupational data
in the MCS data is in SOC2000 format only. There is no direct conversion from
SOC90 to SOC2000 so I am going to leave out NI as not to introduce unfair 
error into the analysis.

use $path1\ARCHIVE\MCS_reg\br_ni_ns.dta, clear

keep mcsid cnum mocccde focccde country

keep if cnum==1
drop cnum

numlabel, add

tab country

sort mcsid

save $path3\MCS_BR_NI.dta, replace

*/




********************************************************************************
**SCOTLAND

use $path1\ARCHIVE\MCS_reg\br_scot_ns.dta, clear

keep mcsid cnum mothoccd focccd country mothemp fathemp ///
mnssec fnssec

numlabel, add

*Keep only one baby per family and we are interested in the parents
tab cnum
keep if cnum==1
tab cnum
drop cnum

*country of registration
tab country, mi
*mothers occupation (SOC2000)
rename mothoccd mocccd
tab mocccd, mi
*fathers occupation (SOC2000)
tab focccd, mi

describe

keep mcsid country mocccd focccd
capture drop miss
egen miss = rmiss(mcsid country mocccd focccd)
tab miss
*nomissing information

*check all Wales
tab country

sort mcsid

save $path3\MCS_BR_SCOT.dta, replace













********************************************************************************

**Survey design and nonresponse weights for the MCS
*Just keep sweep one weights

use $path1\ARCHIVE\MCS1\stata9_se\mcs_longitudinal_family_file.dta, clear

keep mcsid nocmhh sentry country ptty00 pttype2 sptn00 nh2 weight1 ///
weight2 aaoutc00 aovwt1 aovwt2

sort mcsid

save $path3\MCS_weight.dta, replace















********************************************************************************
**Append birth record files for each country

use $path3\MCS_BR_ENG.dta, clear
append using $path3\MCS_BR_WALES.dta
append using $path3\MCS_BR_SCOT.dta

duplicates report mcsid
sort mcsid
merge 1:1 mcsid using $path3\MCS_weight.dta

*Drop those that are only in the survey weights dataset 
*(i.e. not in the linked data sample)
drop if _merge==2

tab _merge
drop _merge

sort mcsid

save $path3\MCS_BR_GB.dta, replace















********************************************************************************
********************************************************************************

/**** Missing Data

There are missing codes in the birth records occupational variables:

0010
0020
0030
0040
0050
0060
0070
0080
0090

These codes are not labelled. When initially viewing these codes we considered
a possible interpretation to be that these are SOC major group codes which 
some occupations were coded to.

We contacted the Office for Nationla Statistics and the National Records of 
Scotland to gain more information on these codes. These are missing codes. 
These are described here: http://tinyurl.com/zmjohmd (click on Socio-Economic
Lists).

The labels for these missing codes are as follows:

0010 inadequately described
0020 occupation not stated
0030 retired
0040 student
0050 independent means
0060 permenently sick
0070 full-time care of the home and/or dependent relatives
0080 no previous job
0090 unemployed person with no other information

A small number of observations also have . to indicate that the information
is missing but no missing code.

																			*/








use $path3\MCS_BR_GB.dta, clear

numlabel, add
describe

*Variable to indicate this is the linked data sample
capture drop linked
gen linked = 1
tab linked, mi
*15014
*This is correct there are 10326 in England, 
* 2545 in Wales and 2143 in Scotland



destring mocccd, gen(brmumocc)
destring focccd, gen(brdadocc)

tab brmumocc, mi
tab brmumocc if (brmumocc<=100), mi
tab brdadocc, mi
tab brdadocc if (brdadocc<=100), mi


***RECODE the Missing Values to Missing

recode brmumocc (0010=.) (0020=.) (0030=.) (0040=.) (0050=.) ///
				(0060=.) (0070=.) (0080=.) (0090=.)
				
recode brdadocc (0010=.) (0020=.) (0030=.) (0040=.) (0050=.) ///
				(0060=.) (0070=.) (0080=.) (0090=.)	
				
tab brmumocc, mi
tab brmumocc if (brmumocc<=100), mi
tab brdadocc, mi
tab brdadocc if (brdadocc<=100), mi




***INVALID SOC2000 Codes

*Looking at the SOC2000 codes there are codes included in the birth records
*which are not valid.
*This applies to 5 cases in mothers records
*and 11 cases in father's records
*Mum 1143 3137 4139 4321 5361
*Dad 2412 3133 4125 4139 4233 5149(x2) 5344 7219 9120 9212
*I will set these to missing 'other'


recode brmumocc (1143=.) (3137=.) (4139=.) (4321=.) (5361=.)
recode brdadocc (2412=.) (3133=.) (4125=.) (4139=.) (4233=.) ///
				(5149=.) (5344=.) (7219=.) (9120=.) (9212=.)


				
tab brmumocc, mi
tab brmumocc if (brmumocc<=100), mi
tab brdadocc, mi
tab brdadocc if (brdadocc<=100), mi				
				
				
sort mcsid

save $path3\MCS_BR_GB_V2.dta, replace
					
********************************************************************************
























********************************************************************************
********************************************************************************
********************************************************************************
*MCS Survey Data SWEEP 1 (Nine Months)

/*In the MCS the main respondent is usually but not always the mother,
the partner respondent is usually but not always the father. There
are also proxy responednts. 

I will make a file that has main, partner and proxy respondents organised 
by their person number. I will identify which respondents are the natural 
mother and natural father to ensure they are the same respondents as on
the birth record. */

*Occupational data reported at MCS1 (9 Months)










****MAIN RESPONDENTS

use $path1\ARCHIVE\MCS1\stata9_se\mcs1_parent_interview.dta, clear

numlabel, add

keep mcsid ampnum00 amsocc00 amsecc00

*Person number of the main respondent
tab ampnum00
*SOC2000 of the main respondent
tab amsocc00
*NSSEC of the main respondent
tab amsecc00

mvdecode _all, mv(-1=. \ -9=.)

*Produce a BHPS style pnum variable for main respondents
capture drop pnum
gen pnum = .
replace pnum = ampnum00 if (amsocc00!=.)

*check there are no duplicates
duplicates report mcsid
duplicates report mcsid pnum

sort mcsid

save $path3\MCS1_main_occ.dta, replace 














****PARTNER RESPONDENTS

use $path1\ARCHIVE\MCS1\stata9_se\mcs1_parent_interview.dta, clear

keep mcsid appnum00 apsocc00 apsecc00

mvdecode _all, mv(-1=. \ -9=.)

*Produce a BHPS style pnum variable for partner respondents
capture drop pnum
gen pnum = .
replace pnum = appnum00 if (apsocc00!=.)

*check there are no duplicates
duplicates report mcsid
duplicates report mcsid pnum

sort mcsid

save $path3\MCS1_part_occ.dta, replace 











****PROXY RESPONDENTS

use $path1\ARCHIVE\MCS1\stata9_se\mcs1_parent_interview.dta, clear

keep mcsid axpxno00 axsocc00 axsecc00

mvdecode _all, mv(-1=. \ -9=.)

*Produce a BHPS style pnum variable for proxy respondents
tab axpxno00
capture drop pnum
gen pnum = .
replace pnum = axpxno00 if (axsocc00!=.)


duplicates report mcsid
duplicates report mcsid pnum

sort mcsid

save $path3\MCS1_proxy_occ.dta, replace 












****Append these three files so have a row for each individual rather than
* a row for each family.

use $path3\MCS1_main_occ.dta, clear
append using $path3\MCS1_part_occ.dta
append using $path3\MCS1_proxy_occ.dta

drop if pnum==.

duplicates report mcsid pnum

tab axsocc00


*A variable to indicate that the occupational 
*information was collected by proxy
capture drop proxy
gen proxy = 0
replace proxy = 1 if (axsocc00!=.)
tab proxy, mi


*Overall variable for SOC2000 for all respondents
tab amsocc00
tab apsocc00

capture drop soc
gen soc = .
replace soc = amsocc00 
replace soc = apsocc00 if (amsocc00==.)
replace soc = axsocc00 if ((amsocc00==.)&(apsocc00==.))
tab soc, mi


keep mcsid pnum proxy soc

label variable pnum "Person Number"
label variable proxy "Proxy Respondent"
label variable soc "soc2000"


sort mcsid pnum

save $path3\mcs1_parents.dta, replace














********************************************************************************
/*Now I will identify which respondents are the natural mother and natural
  father */


*Identity of main and partner respondent
use $path1\ARCHIVE\MCS1\stata9_se\mcs1_hhgrid.dta, clear

keep MCSID AHPNUM00 AHPSEX00 AHCREL00 AHPJOB00 AHPTPC00 AHELIG00 AHRESP00

rename MCSID mcsid
rename AHPNUM00 pnum
rename AHPSEX00 sex
rename AHCREL00 rel
rename AHPJOB00 work
rename AHPTPC00 resident
rename AHELIG00 elig
rename AHRESP00 response

mvdecode _all, mv(-1=. \ -9=.)

numlabel, add

*drop cohort member themselves (only interested in parents)
tab pnum, mi
drop if pnum==.

duplicates report mcsid pnum

sort mcsid pnum

save $path3\mcs1_identity.dta, replace

*Merge the Relationship information to the pnum level file


***Natural Mother
use $path3\mcs1_parents.dta, clear
sort mcsid pnum
merge m:1 mcsid pnum using $path3\mcs1_identity.dta
keep if _merge==3
tab _merge
drop _merge

tab rel
*7 = natural parent
tab sex
*2 = female
capture drop mum
gen mum = 0
replace mum = 1 if (rel==7)&(sex==2)
tab mum
label variable mum "natural mother"

tab soc mum, mi

duplicates report mcsid mum
duplicates tag mcsid mum, gen(tag)
/*From inspection - duplicates are all families with multiple caregivers 
(e.g. foster carer) neither of which is the natural mother*/
drop tag


keep if mum ==1

keep mcsid proxy soc sex work resident elig response

rename proxy mumproxy
rename soc mumsoc
rename work mumwork
rename resident mumresident
rename elig mumelig
rename response mumresponse

sort mcsid

save $path3\mcs1_mum.dta, replace


***Dad
use $path3\mcs1_parents.dta, clear
sort mcsid pnum
merge m:1 mcsid pnum using $path3\mcs1_identity.dta
keep if _merge==3
tab _merge
drop _merge


tab rel
*7 = Natural Parent
tab sex
*2 = Male
capture drop dad
gen dad = 0
replace dad = 1 if (rel==7)&(sex==1)
tab dad
label variable dad "natural father"

duplicates report mcsid dad
duplicates tag mcsid dad, gen(tag)
/*From inspection - duplicates are all families with multiple caregivers 
neither of which is the natural father 
(i.e. mainly step fathers / mother's partner) */
drop tag

keep if dad==1

keep mcsid proxy soc sex work resident elig response

rename proxy dadproxy
rename soc dadsoc
rename work dadwork
rename resident dadresident
rename elig dadelig
rename response dadresponse

sort mcsid

save $path3\mcs1_dad.dta, replace

















********************************************************************************

/*Merge the mother and father's survey data on occupations to the birth 
records data*/

use $path3\MCS_BR_GB_V2.dta, clear
sort mcsid
merge 1:1 mcsid using $path3\mcs1_mum.dta
drop _merge
merge 1:1 mcsid using $path3\mcs1_dad.dta
drop _merge
save $path3\mcs1_birthmumdad.dta, replace





/*I am going to merge with a plain household file showing id for all households
at mcs 1 so i can see the number of families with missing data from both
sources */

use $path1\ARCHIVE\MCS1\stata9_se\mcs_longitudinal_family_file.dta, clear

keep mcsid sentry country ptty00 pttype2 sptn00 nh2 ///
weight1 weight2 aaoutc00 aovwt1 aovwt2 aaoutc00

numlabel, add

*keep if these families gave an interview at MCS1

tab aaoutc00
*18552 productive interviews at MCS1
keep if aaoutc00==2

sort mcsid

save $path3\mcs1_weights.dta, replace

use $path3\mcs1_birthmumdad.dta, clear
sort mcsid
merge 1:1 mcsid using $path3\mcs1_weights.dta

*0 cases in birthmumdad file only
*295 in weights file only
*keep only those that were matched
keep if _merge==3
drop _merge


******************
*Here I am only keeping those who are in the sample of survey records
*that were linked to the admin records.
tab linked, mi
keep if linked==1
*15014

describe 

numlabel, add

drop mocccd focccd

/*Make a variable to indicate if there is a perfect match between SOC2000
codes in the survey and birth record and patterns of missingness
FOR MOTHERS*/

describe brmumocc mumsoc brdadocc dadsoc

tab brmumocc, mi
tab brdadocc, mi
tab mumsoc, mi
tab dadsoc, mi

capture drop brmumvalid
gen brmumvalid = .
replace brmumvalid = 1 if (brmumocc!=.)
tab brmumvalid, mi
						
capture drop surmumvalid
gen surmumvalid = .
replace surmumvalid = 1 if (mumsoc!=.)
tab surmumvalid, mi

capture drop mumsocmatch
gen mumsocmatch = 0
replace mumsocmatch = 1 if (brmumocc==mumsoc)						
tab mumsocmatch

capture drop mumbrmiss
gen mumbrmiss = 0
replace mumbrmiss = 1 if (brmumocc==.)
tab mumbrmiss

capture drop mumsurmiss
gen mumsurmiss = 0
replace mumsurmiss = 1 if (mumsoc==.)
tab mumsurmiss

capture drop mummatch
gen mummatch = .
replace mummatch = 1 if (mumsocmatch==1)
replace mummatch = 2 if (mumsocmatch==0)&((mumbrmiss!=.)&(mumsurmiss!=.))
replace mummatch = 3 if (brmumvalid==.)&(surmumvalid==.)
replace mummatch = 4 if (brmumvalid==.)&(surmumvalid==1)
replace mummatch = 5 if (brmumvalid==1)&(surmumvalid==.)
tab mummatch
label variable mummatch "mum soc matches"
label define matchl 1 "SOC2000 Matches" ///
					2 "SOC2000 Does Not Match" ///
					3 "SOC2000 Missing on Both" ///
					4 "SOC2000 Missing on BR" ///
					5 "SOC2000 Missing on Survey"
label values mummatch matchl
numlabel, add
tab mummatch					
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/*Make a variable to indicate if there is a perfect match between SOC2000
codes in the survey and birth record and patterns of missingness
FOR FATHERS*/			
			
describe brmumocc mumsoc brdadocc dadsoc

tab brmumocc, mi
tab brdadocc, mi
tab mumsoc, mi
tab dadsoc, mi

capture drop brdadvalid
gen brdadvalid = .
replace brdadvalid = 1 if (brdadocc!=.)
tab brdadvalid, mi
						
capture drop surdadvalid
gen surdadvalid = .
replace surdadvalid = 1 if (dadsoc!=.)
tab surdadvalid, mi

capture drop dadsocmatch
gen dadsocmatch = 0
replace dadsocmatch = 1 if (brdadocc==dadsoc)						
tab dadsocmatch

capture drop dadbrmiss
gen dadbrmiss = 0
replace dadbrmiss = 1 if (brdadocc==.)

capture drop dadsurmiss
gen dadsurmiss = 0
replace dadsurmiss = 1 if (dadsoc==.)
tab dadsurmiss

capture drop dadmatch
gen dadmatch = .
replace dadmatch = 1 if (dadsocmatch==1)
replace dadmatch = 2 if (dadsocmatch==0)&((dadbrmiss!=.)&(dadsurmiss!=.))
replace dadmatch = 3 if (brdadvalid==.)&(surdadvalid==.)
replace dadmatch = 4 if (brdadvalid==.)&(surdadvalid==1)
replace dadmatch = 5 if (brdadvalid==1)&(surdadvalid==.)
tab dadmatch
label variable dadmatch "dad soc matches"
label values dadmatch matchl
numlabel, add
tab dadmatch	

tab mummatch
tab dadmatch						

tab mummatch dadmatch












/*Look across mummatch and dadmatch to see which families have information
for mothers and fathers*/

tab mummatch 
tab dadmatch

tab brmumvalid, mi
tab brdadvalid, mi

tab brmumvalid brdadvalid, mi

tab surmumvalid, mi
tab surdadvalid, mi

tab surmumvalid surdadvalid, mi

tab brdadvalid surdadvalid, mi
tab brmumvalid surmumvalid, mi


















****			

tab country
label define country 1 "England" 2 "Wales" 3 "Scot", replace
label values country country
numlabel, add
tab country, mi

sort mcsid

save $path2\MCS1_BirthRecordsOccupations.dta, replace

********************************************************************************























********************************************************************************
********************************************************************************
********************************************************************************
**LINK TO OCCUPATIONAL MEASURES (NS-SEC and CAMSIS)

use $path2\MCS1_BirthRecordsOccupations.dta, clear

*****Scotland is the only nation for which we have SOC and employment status. 
*I will code England, Wales and Scotland to the reduced versions of NSSEC
*and CAMSIS.








********************************************************************************
***All simplified version of NSSEC



capture drop mumnssec dadnssec


save $path2\MCS1_BirthRecordsOccupations_V2.dta, replace


use $path2\MCS1_BirthRecordsOccupations_V2.dta, clear

*Mother birth record occupations
tab brmumocc, mi
rename brmumocc soc2000

describe soc2000

numlabel, add

gen ukempst = 0

merge m:m soc2000 ukempst using "E:\BirthCertificate\gb91soc2000\gb91soc2000.dta"

drop if _merge==2
drop _merge

*I looked up 1111 on the ONS scheme which maps to 1.1 (I will replace 2 cases)

numlabel, add
tab ns_sec
replace ns_sec = 1 if (soc2000==1111)

describe soc2000 ns_sec

rename soc2000 brmumocc
rename ns_sec brmum_nssec_simp

label variable brmum_nssec_simp "BR Mum NSSEC"

describe brmumocc brmum_nssec_simp

tab brmumocc, mi
tab brmum_nssec_simp, mi

*Father birth record occupations
tab brdadocc 
rename brdadocc soc2000

describe soc2000

capture drop ukempst
gen ukempst = 0

merge m:m soc2000 ukempst using "E:\BirthCertificate\gb91soc2000\gb91soc2000.dta"

drop if _merge==2
drop _merge


*I looked up 1111 on the ONS scheme which maps to 1.1 
*(I will replace that 2 cases)

tab ns_sec
replace ns_sec = 1 if (soc2000==1111)

rename soc2000 brdadocc
rename ns_sec brdad_nssec_simp

describe brdadocc brdad_nssec_simp

label variable brdad_nssec_simp "BR Dad NSSEC"

tab brdad_nssec_simp 


*Mother survey occupations
tab mumsoc 
rename mumsoc soc2000

capture drop ukempst
gen ukempst = 0

merge m:m soc2000 ukempst using "E:\BirthCertificate\gb91soc2000\gb91soc2000.dta"

drop if _merge==2
drop _merge

tab ns_sec
replace ns_sec = 1 if (soc2000==1111)

rename soc2000 mumsoc
rename ns_sec mum_nssec_simp

label variable mum_nssec_simp "SURVEY Mum NSSEC"



*Father survey occupations
tab dadsoc 
rename dadsoc soc2000

capture drop ukempst
gen ukempst = 0

merge m:m soc2000 ukempst using "E:\BirthCertificate\gb91soc2000\gb91soc2000.dta"

drop if _merge==2
drop _merge

tab ns_sec
replace ns_sec = 1 if (soc2000==1111)

rename soc2000 dadsoc
rename ns_sec dad_nssec_simp

label variable dad_nssec_simp "SURVEY Dad NSSEC"


save $path2\MCS1_BirthRecordsOccupations_V3.dta, replace










********************************************************************************
***All simplified version of CAMSIS



use $path2\MCS1_BirthRecordsOccupations_V3.dta, clear

*Birth Records Mum

tab brmumocc 
rename brmumocc soc2000

capture drop ukempst
gen ukempst = 0

merge m:m soc2000 ukempst using "E:\BirthCertificate\gb91soc2000\gb91soc2000.dta"

drop if _merge==2
drop _merge

drop ukempst stdempst ns_sec opercat rns_sec ropercat rgsc seg nrempst

rename soc2000 brmumocc
rename mcamsis brmum_mcamsis_simp
rename fcamsis brmum_fcamsis_simp

label variable brmum_mcamsis_simp "BR Mum male CAMSIS"
label variable brmum_fcamsis_simp "BR Mum female CAMSIS"



*Birth Records Dad
tab brdadocc 

capture drop soc2000
rename brdadocc soc2000

capture drop ukempst
gen ukempst = 0


merge m:m soc2000 ukempst using "E:\BirthCertificate\gb91soc2000\gb91soc2000.dta"

drop if _merge==2
drop _merge

drop ukempst stdempst ns_sec opercat rns_sec ropercat rgsc seg nrempst

rename soc2000 brdadocc
rename mcamsis brdad_mcamsis_simp
rename fcamsis brdad_fcamsis_simp

label variable brdad_mcamsis_simp "BR Dad male CAMSIS"
label variable brdad_fcamsis_simp "BR Dad female CAMSIS"





*Survey Mum

tab mumsoc
rename mumsoc soc2000

capture drop ukempst
gen ukempst = 0

merge m:m soc2000 ukempst using "E:\BirthCertificate\gb91soc2000\gb91soc2000.dta"

drop if _merge==2
drop _merge

drop ukempst stdempst ns_sec opercat rns_sec ropercat rgsc seg nrempst

rename soc2000 mumsoc
rename mcamsis mum_mcamsis_simp
rename fcamsis mum_fcamsis_simp

label variable mum_mcamsis_simp "SURVEY Mum male CAMSIS"
label variable mum_fcamsis_simp "SURVEY Mum female CAMSIS"


*Survey Dad

tab dadsoc 
rename dadsoc  soc2000

capture drop ukempst
gen ukempst = 0

merge m:m soc2000 ukempst using "E:\BirthCertificate\gb91soc2000\gb91soc2000.dta"

drop if _merge==2
drop _merge


drop ukempst stdempst ns_sec opercat rns_sec ropercat rgsc seg nrempst

rename soc2000 dadsoc 
rename mcamsis dad_mcamsis_simp
rename fcamsis dad_fcamsis_simp

label variable dad_mcamsis_simp "SURVEY Dad male CAMSIS"
label variable dad_fcamsis_simp "SURVEY Dad female CAMSIS"



tab mummatch
capture drop mummatchbin
gen mummatchbin = 0
replace mummatchbin = 1 if (mummatch==1)
tab mummatchbin


tab dadmatch
capture drop dadmatchbin
gen dadmatchbin = 0
replace dadmatchbin = 1 if (dadmatch==1)
tab dadmatchbin


keep mcsid brmumocc brdadocc country sentry ptty00 pttype2 sptn00 ///
nh2 weight1 weight2 aaoutc00 aovwt1 aovwt2 mumproxy mumsoc sex ///
mumwork mumresident mumelig mumresponse dadproxy dadsoc dadwork ///
dadresident dadelig dadresponse mummatch dadmatch brdad_mcamsis_simp ///
brdad_fcamsis_simp brmum_nssec_simp brdad_nssec_simp mum_nssec_simp ///
dad_nssec_simp brmum_mcamsis_simp brmum_fcamsis_simp mum_mcamsis_simp ///
mum_fcamsis_simp dad_mcamsis_simp dad_fcamsis_simp ///
brmumvalid brdadvalid surmumvalid surdadvalid dadbrmiss ///
dadsurmiss mumbrmiss mumsurmiss mummatch dadmatch mummatchbin dadmatchbin


save $path2\MCS1_BirthRecordsOccupations_V4.dta, replace













********************************************************************************
********************************************************************************

****SCOTLAND - Can we use the employment status information somehow?

********************************************************************************

*Because scotland has both SOC2000 codes and employment status information 
*I will code this nations data to a series of (full) occupation based measures.

*08/06/2015
*However when you look at the employment status variable it is not standard.
*So I will just use the simplified (i.e. not involving employment status)
*variables for all.

use $path1\ARCHIVE\MCS_reg\br_scot_ns.dta, clear

numlabel, add

tab mothemp 
tab fathemp

describe mothemp
describe fathemp

*From documentation (not in the dataset grrrr)
*0 = students, independent means, no occupation, handicapped, not known
*1 = employees, apprentices, armed forces (other ranks)
*2 = managers, superintendents, armed forces (officers)
*3 = Foremen
*4 = Self-Employed - with employees
*5 = Self-Employed - without employees


*Compared to standard Employment status variables
*from use $path1\OTHER\gb91soc2000.dta, clear

*stdempst
*0 = status unknown
*2 = self employed (principals)
*3 = Own account
*4 = employer
*6 = employee

*ukempst
*0 = not known/simplified
*1 = employers - large organisations
*2 = employers - small organisations
*3 = self employed, no employees
*4 = managers - large organisations
*5 = managers - small organisations
*6 = supervisors
*7 = Other Employees


*I don't think we will be able to use the employment status variables from the
*Birth records data.

********************************************************************************





















********************************************************************************
********************************************************************************
*******   M C S    S W E E P    T W O - did occupation change between sweeps??

/* Idea - Add in the occupations reported by natural mothers and fathers in 
MCS2 (Age 3). These can be used as an additional check 

*11/08/2015 the new occupational information is not collected at MCS2 if
*the respondent states they have the same job. The variable for soc adds in
*the old soc information gived at sweep one. So we are not able to identify 
*if the respondent gives the same occupation at each sweep. Remove
*this aspect of the analysis */
********************************************************************************





























********************************************************************************
********************************************************************************

****  A D D I T I O N A L   I N F O   M C S   1

****Collect some additional information about the natural mother and father
*from MCS1. This may be used to examine patterns of missingness or misscodings.




***Person number and identitiy (e.g. mum or dad)
use $path1\ARCHIVE\MCS1\stata9_se\mcs1_hhgrid.dta, clear

keep MCSID AHPNUM00 AHPSEX00 AHPAGE00 AHCREL00 AHPJOB00 AHPTPC00 ///
AHELIG00 AHRESP00 AHCAGE00

rename MCSID mcsid
rename AHPNUM00 pnum

numlabel, add
tab pnum
*drop cohort members themselves
drop if pnum==-1

tab AHCREL00
*7 natural parent
tab AHPSEX00
*1 male 2 female


capture drop dad
gen dad = 0
replace dad = 1 if (AHCREL00==7)&(AHPSEX00==1)
tab dad
label variable dad "Natural Father"
*15,311

capture drop mum
gen mum = 0
replace mum = 1 if (AHCREL00==7)&(AHPSEX00==2)
tab mum
label variable mum "Natural Mother"
*18,527

tab AHRESP00 dad
*28 dad main
*13,215 dad partner
*215 dad proxy
*1903 dad no interview

tab AHRESP00 mum
*18497 mum main
*7 mum partner
*1 mum proxy
*22 mum no interview


duplicates report mcsid pnum
sort mcsid pnum

save $path3\hhgidentity.dta, replace















***Natural Mother and Father's Education
*Main respondent
use $path1\ARCHIVE\MCS1\stata9_se\mcs1_parent_interview.dta, clear

keep mcsid amvcqu00 mcsid ampnum00 amacqu00 amvcqu00 ampsex00
numlabel, add

rename ampnum00 pnum
rename amacqu00 academic
tab academic, mi
drop if academic<1

tab ampsex00
rename ampsex00 sex
label variable sex "Sex"

duplicates report mcsid pnum

tab pnum
drop if pnum==-1

duplicates report mcsid pnum
sort mcsid pnum
save $path3\mcs1par1.dta, replace


*Partner repondent
use "E:\Data\RAWDATA\ARCHIVE\MCS1\stata9_se\mcs1_parent_interview.dta", clear

keep mcsid appnum00 apacqu00 apvcqu00 appsex00
numlabel, add

rename appnum00 pnum
rename apacqu00 academic
tab academic, mi
drop if academic<1

tab appsex00
rename appsex00 sex

duplicates report mcsid pnum

tab pnum
drop if pnum==-1

duplicates report mcsid pnum
sort mcsid pnum
save $path3\mcs1par2.dta, replace


*Proxy respondent
use "E:\Data\RAWDATA\ARCHIVE\MCS1\stata9_se\mcs1_parent_interview.dta", clear

keep mcsid axpxno00 axacqu00 axvcqu00
numlabel, add

rename axpxno00 pnum
rename axacqu00 academic
tab academic, mi
drop if academic<1


capture drop proxy
gen proxy=1
label variable proxy "Responded via Proxy Interview"

capture drop sex
gen sex=.

duplicates report mcsid pnum

tab pnum
drop if pnum==-1

sort mcsid pnum
save $path3\mcs1par3.dta, replace


use $path3\mcs1par1.dta, clear
append using $path3\mcs1par2.dta
duplicates report mcsid pnum
append using $path3\mcs1par3.dta
duplicates report mcsid pnum
sort mcsid pnum
save $path3\mcs1parall.dta, replace

numlabel, add

tab pnum

tab academic, mi
label variable academic "Highest Academic Qualification"

/* Academic
 S1 MAIN Highest academic qualification |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                       1. Higher degree |        618        3.34        3.34
                        2. First degree |      2,287       12.37       15.72
        3. Diplomas in higher education |      1,557        8.42       24.14
                   4. A / AS / S levels |      1,718        9.29       33.43
           5. O level / GCSE grades A-C |      6,183       33.45       66.88
                     6. GCSE grades D-G |      1,980       10.71       77.60
95. Other academic qualifications (incl |        532        2.88       80.48
       96. None of these qualifications |      3,609       19.52      100.00
----------------------------------------+-----------------------------------
                                  Total |     18,484      100.00

								  
*/								  


tab sex, mi

duplicates report mcsid pnum

sort mcsid pnum

save $path3\mcs1parall.dta, replace






**Merge with household grid to get identity (relationship to cohort member)
use $path3\hhgidentity.dta, clear
sort mcsid pnum
duplicates report mcsid pnum

merge 1:1 mcsid pnum using $path3\mcs1parall.dta
*drop those that are in the hhg file only
keep if _merge==3
drop _merge

duplicates report mcsid pnum

tab proxy mum
tab proxy dad

capture drop mumeduc 
gen mumeduc = .
replace mumeduc = academic if (mum==1)
tab mumeduc
recode mumeduc (96=7) (95=8)
label define mumeduc 1 "Higher Degree" 2 "First Degree" 3 "Diplomas HE" ///
	4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" 7 "None" 8 "Foreign"
label values mumeduc mumeduc
label variable mumeduc "Mother's Highest Academic Qualification MCS1"
tab mumeduc academic, mi

capture drop dadeduc 
gen dadeduc = .
replace dadeduc = academic if (dad==1)
tab dadeduc
recode dadeduc (96=7) (95=8)
label values dadeduc mumeduc
label variable dadeduc "Father's Highest Academic Qualification MCS1"
tab dadeduc academic, mi

keep mcsid pnum mum dad sex mumeduc dadeduc proxy

duplicates report mcsid pnum
sort mcsid pnum

save $path3\mcs1parall2.dta, replace




*Change into a MCSID level file
use $path3\mcs1parall2.dta, clear
keep mcsid mum mumeduc
tab mum
keep if mum==1
drop mum
sort mcsid
duplicates report mcsid
save $path3\mcs1parall2mum.dta, replace

use $path3\mcs1parall2.dta, clear
keep mcsid dad dadeduc proxy
tab dad
keep if dad==1
drop dad
sort mcsid
save $path3\mcs1parall2dad.dta, replace

use $path3\mcs1parall2mum.dta, clear
sort mcsid
merge 1:1 mcsid using $path3\mcs1parall2dad.dta
drop _merge
duplicates report mcsid
sort mcsid
save $path3\mcs1parall2both.dta, replace
















*Dervied variables

*info on main and partners in this file but no pnum

*Main
use $path1\ARCHIVE\MCS1\stata9_se\mcs1_derived_variables.dta, clear

keep MCSID AMDAGB00 AMDGAB00 AMD06E00 AMD11E00 AMD08E00 AMDNVQ00 AMD13C00

rename MCSID mcsid
sort mcsid

save $path3\temp1main.dta, replace

*Partner
use $path1\ARCHIVE\MCS1\stata9_se\mcs1_derived_variables.dta, clear

keep MCSID APDAGB00 APDGAB00 APD06E00 APD08E00 APDNVQ00 APD13C00

rename MCSID mcsid
sort mcsid

save $path3\temp1partner.dta, replace



use "E:\Data\RAWDATA\ARCHIVE\MCS1\stata9_se\mcs1_hhgrid.dta", clear
keep MCSID AHPNUM00 AHRESP00
rename MCSID mcsid
rename AHPNUM00 pnum

numlabel, add

tab AHRESP00
keep if AHRESP00==1
tab pnum

keep mcsid pnum

sort mcsid
save $path3\temp2main.dta, replace


use "E:\Data\RAWDATA\ARCHIVE\MCS1\stata9_se\mcs1_hhgrid.dta", clear
keep MCSID AHPNUM00 AHRESP00
rename MCSID mcsid
rename AHPNUM00 pnum

numlabel, add

tab AHRESP00
keep if (AHRESP00==2)|(AHRESP00==3)
tab pnum

keep mcsid pnum

sort mcsid
save $path3\temp2partner.dta, replace


use $path3\temp2main.dta, clear
sort mcsid
merge 1:1 mcsid using $path3\temp1main.dta
keep if _merge==3
drop _merge
duplicates report mcsid pnum
sort mcsid pnum
save $path3\temp3main.dta, replace


use $path3\temp2partner.dta, clear
sort mcsid
merge 1:1 mcsid using $path3\temp1partner.dta
keep if _merge==3
drop _merge
duplicates report mcsid pnum
sort mcsid pnum
save $path3\temp3partner.dta, replace



use $path3\temp3main.dta, clear
append using $path3\temp3partner.dta
sort mcsid pnum
duplicates report mcsid pnum
save $path3\temp4.dta, replace

capture drop _merge

numlabel, add

*AGE
*main age
tab AMDGAB00
*partner age
tab APDGAB00

mvdecode AMDGAB00 APDGAB00, mv(-2=. \ -1=.)

rename AMDGAB00 mainage
rename APDGAB00 partnerage



*ETHNICITY
tab AMD08E00, mi
tab APD08E00, mi

mvdecode AMD08E00, mv(-104=. \ -9=. \ -8=. \ -1=. \ 10=. \40=.)
mvdecode APD08E00, mv(-9=. \ -8=. \ -1=. \ 0=. )


rename AMD08E00 main8eth
rename APD08E00 partner8eth


*NVQ Levels

tab AMDNVQ00, mi
tab APDNVQ00, mi

rename AMDNVQ00 mainnvq
rename APDNVQ00 partnernvq

*Full NS-SEC

tab AMD13C00 
tab APD13C00

rename AMD13C00 mainnssec
rename APD13C00 partnernssec


duplicates report mcsid pnum
sort mcsid pnum
save $path3\MCS1_Parents_additionalvars.dta, replace

*Merge to get identity
*Mum
use $path3\hhgidentity.dta, clear
sort mcsid pnum
duplicates report mcsid pnum
merge 1:1 mcsid pnum using $path3\MCS1_Parents_additionalvars.dta
tab mum _merge
tab dad _merge
keep if _merge==3
drop _merge

keep if mum==1
duplicates report mcsid mum

*Mum Age
tab mainage
capture drop mumage
gen mumage = .
replace mumage = mainage if (mainage!=.)
replace mumage = partnerage if (partnerage!=.)
label define age 1 "<19" 2 "20-29" 3 "30-39" 4 "40+"
label values mumage age
tab mumage, mi
label variable mumage "Mother's Age"


*Mum NVQ
tab mainnvq
capture drop mumnvq
gen mumnvq = .
replace mumnvq = mainnvq if (mainnvq!=.)
replace mumnvq = partnernvq if (partnernvq!=.)
recode mumnvq (-1=.) (96=0) (95=7)
label define nvq 0 "None" 1 "NVQ1" 2 "NVQ2" 3 "NVQ3" 4 "NVQ4" 5 "NVQ5" ///
				6 "NVQ6" 7 "Foreign", replace
label values mumnvq nvq
tab mumnvq, mi
label variable mumnvq "Mother's NVQ"


*Mum Full NS-SEC
tab mainnssec
capture drop mumnssec
gen mumnssec = .
replace mumnssec = mainnssec if (mainnssec!=.)
replace mumnssec = partnernssec if (partnernssec!=.)
recode mumnssec (-1=.) (2=1) (3=2) (4=3) (5=3) (6=3) (7=4) ///
			(8=5) (9=5) (10=6) (11=6) (12=7) (13=8)
label define nssec 1 "LargeEmp" 2 "HighProf" 3 "LowMan" 4 "Int" ///
				5 "SmallEmp" 6 "LowSup" 7 "Semi-R" 8"Routine", replace
label values mumnssec nssec
tab mumnssec, mi
label variable mumnssec "Mother's Full NSSEC"


*Mum Ethnicity
tab main8eth
capture drop mumeth
gen mumeth = .
replace mumeth = main8eth if (main8eth!=.)
replace mumeth = partner8eth if (partner8eth!=.)
label define eth 1 "White" 2 "Mixed" 3 "Indian" 4 "Pakistani" ///
				5 "Bangladeshi" 6 "BlackCarib" 7 "BlackAfr" 8 "Other", replace
label values mumeth eth
tab mumeth, mi
label variable mumeth "Mother's Ethnicity"






keep mcsid pnum mum mumage mumnvq mumnssec mumeth
sort mcsid pnum

save $path3\temp5mum.dta, replace



*Merge to get identity
*dad
use $path3\hhgidentity.dta, clear
sort mcsid pnum
duplicates report mcsid pnum
merge 1:1 mcsid pnum using $path3\MCS1_Parents_additionalvars.dta
tab mum _merge
tab dad _merge
keep if _merge==3
drop _merge

keep if dad==1
duplicates report mcsid dad

*Dad Age
tab mainage
capture drop dadage
gen dadage = .
replace dadage = mainage if (mainage!=.)
replace dadage = partnerage if (partnerage!=.)
label define age 1 "<19" 2 "20-29" 3 "30-39" 4 "40+"
label values dadage age
tab dadage, mi
label variable dadage "Father's Age"


*Dad NVQ
tab mainnvq
capture drop dadnvq
gen dadnvq = .
replace dadnvq = mainnvq if (mainnvq!=.)
replace dadnvq = partnernvq if (partnernvq!=.)
recode dadnvq (-1=.) (96=0) (95=7)
label define nvq 0 "None" 1 "NVQ1" 2 "NVQ2" 3 "NVQ3" 4 "NVQ4" 5 "NVQ5" ///
				6 "NVQ6" 7 "Foreign", replace
label values dadnvq nvq
tab dadnvq, mi
label variable dadnvq "Father's NVQ"


*Dad Full NS-SEC
tab mainnssec
capture drop dadnssec
gen dadnssec = .
replace dadnssec = mainnssec if (mainnssec!=.)
replace dadnssec = partnernssec if (partnernssec!=.)
recode dadnssec (-1=.) (2=1) (3=2) (4=3) (5=3) (6=3) (7=4) ///
			(8=5) (9=5) (10=6) (11=6) (12=7) (13=8)
label define nssec 1 "LargeEmp" 2 "HighProf" 3 "LowMan" 4 "Int" ///
				5 "SmallEmp" 6 "LowSup" 7 "Semi-R" 8"Routine", replace
label values dadnssec nssec
tab dadnssec, mi
label variable dadnssec "Father's Full NSSEC"


*Dad Ethnicity
tab partner8eth
capture drop dadeth
gen dadeth = .
replace dadeth = partner8eth if (partner8eth!=.)
replace dadeth = main8eth if (main8eth!=.)
label define eth 1 "White" 2 "Mixed" 3 "Indian" 4 "Pakistani" ///
				5 "Bangladeshi" 6 "BlackCarib" 7 "BlackAfr" 8 "Other", replace
label values dadeth eth
tab dadeth, mi
label variable dadeth "Father's Ethnicity"







keep mcsid pnum dad dadage dadnvq dadnssec dadeth
sort mcsid pnum

save $path3\temp5dad.dta, replace



*Append Mother and Father


use $path3\temp5mum.dta, clear
duplicates report mcsid pnum
duplicates report mcsid
merge 1:1 mcsid using $path3\temp5dad.dta
drop _merge
sort mcsid
save $path3\MCS1_Parents_additionalvars2.dta, replace



***Add this on to the main dataset
use $path3\MCS1_Parents_additionalvars2.dta, clear
duplicates report mcsid
merge 1:1 mcsid using $path3\mcs1parall2both.dta
drop _merge
duplicates report mcsid
sort mcsid
merge 1:1 mcsid using $path2\MCS1_BirthRecordsOccupations_V4.dta


*drop if the cases are in the using file only
*i.e. they are not in the linked admin dataset
drop if _merge==2
drop _merge

duplicates report mcsid

save $path2\MCS1_BirthRecordsOccupations_V5.dta, replace




****Time since between birth and interview (cohort member's age)

use "E:\Data\RAWDATA\ARCHIVE\MCS1\stata9_se\mcs1_hhgrid.dta", clear

keep MCSID AHCAGE00 AHCNUM00
rename MCSID mcsid

tab AHCNUM00, mi
keep if AHCNUM00==1
drop AHCNUM00

tab AHCAGE00
rename AHCAGE00 cmage
label variable cmage "MCS1 CM Age at Interview"

sort mcsid 
duplicates report mcsid
save $path3\tempcmage.dta, replace


use $path2\MCS1_BirthRecordsOccupations_V5.dta, clear
sort mcsid
merge 1:1 mcsid using $path3\tempcmage.dta
keep if _merge==3
drop _merge
sort mcsid


label variable brmumvalid "Mum Birth Record Valid SOC2000"
label variable brdadvalid "Dad Birth Record Valid SOC2000"
label variable surmumvalid "Mum Survey Valid SOC2000"
label variable surdadvalid "Dad Survey Valid SOC2000"

label variable mumbrmiss "Mum Birth Record SOC200 Missing"
label variable dadbrmiss "Dad Birth Record SOC200 Missing"
label variable mumsurmiss "Mum Survey SOC200 Missing"
label variable dadsurmiss "Dad Survey SOC200 Missing"

label variable mummatchbin "Mum BR and Sur Match Binary Var"
label variable dadmatchbin "Dad BR and Sur Match Binary Var"

sort mcsid

save $path2\MCS1_BirthRecordsOccupations_V6.dta, replace



********************************************************************************





























********************************************************************************
**********************      A N A L Y S I S       ******************************

		
		
use $path2\MCS1_BirthRecordsOccupations_V6.dta, clear

*drop Northern Ireland
drop if country==.	
tab country













********************************************************************************
****Descriptives of difference between birth records and survey
***Of those with a valid SOC2000 on the Survey and birth record what is
***the degree of agreement

tab mummatch, mi
tab mummatchbin
tab dadmatch
tab dadmatchbin

*If there is a valid SOC2000 on birth record and survey
tab mummatch if (mummatch<=2)
*59% matches
tab dadmatch if (dadmatch<=2)
*54% matches

*kappa mum SOC2000
kap mumsoc brmumocc if (mummatch<=2)
*59% agreement
*kappa = 0.58
*std error = 0.0015
*z = 395.59
*prob>z 0.000


*kappa dad SOC2000
kap dadsoc brdadocc if (dadmatch<=2)
*54% agreement
*kappa = 0.54
*std error = 0.0009
*z = 580.31
*prob>z 0.000


*If there is a valid nssec from birth record and survey
*NS-SEC
*Mum
tab brmum_nssec_simp mum_nssec_simp
capture drop mumnsmatch
gen mumnsmatch=.
replace mumnsmatch = 1 if (brmum_nssec_simp==mum_nssec_simp) ///
& ((brmum_nssec_simp!=.)&(mum_nssec_simp!=.))
replace mumnsmatch = 0 if (brmum_nssec_simp!=mum_nssec_simp) ///
& ((brmum_nssec_simp!=.)&(mum_nssec_simp!=.))
tab mumnsmatch
*n = 9168
*match 75%

kap brmum_nssec_simp mum_nssec_simp if (mumnsmatch>=0)
*75% agreement
*kappa = 0.68
*SE = 0.0051
*z = 133.89
*prob>z 0.000

*Dad
tab brdad_nssec_simp dad_nssec_simp
capture drop dadnsmatch
gen dadnsmatch=.
replace dadnsmatch = 1 if (brdad_nssec_simp==dad_nssec_simp) ///
& ((brdad_nssec_simp!=.)&(dad_nssec_simp!=.))
replace dadnsmatch = 0 if (brdad_nssec_simp!=dad_nssec_simp) ///
& ((brdad_nssec_simp!=.)&(dad_nssec_simp!=.))
tab dadnsmatch
*n = 10241
*match 67%

kap brdad_nssec_simp dad_nssec_simp if (dadnsmatch>=0)
*67% agreement
*kappa = 0.62
*SE = 0.0038
*z = 161.46
*prob>z 0.000



*If there is a valid camsis from birth record and survey
*CAMSIS

pwcorr mum_mcamsis_simp brmum_mcamsis_simp ///
if ((mum_mcamsis_simp!=.)&(brmum_mcamsis_simp!=.)), sig
*0.81

capture drop num
gen num=1
tab num if ((mum_mcamsis_simp!=.)&(brmum_mcamsis_simp!=.))
*9168

scatter mum_mcamsis_simp brmum_mcamsis_simp ///
if ((mum_mcamsis_simp!=.)&(brmum_mcamsis_simp!=.)), ///
jitter(10) msize(small) scheme(s1mono) ///
xtitle("Mother's Birth Record CAMSIS") ytitle("Mother's Survey CAMSIS") ///
title("Mother's CAMSIS derived from Survey and Birth Record") ///
note("Note: Simplified CAMSIS, Cases with valid SOC2000 on Survey and Birth Record only," ///
"n=9,168, r=0.81, p<0.001")


pwcorr dad_mcamsis_simp brdad_mcamsis_simp ///
if ((dad_mcamsis_simp!=.)&(brdad_mcamsis_simp!=.)), sig
*0.83

tab num if ((dad_mcamsis_simp!=.)&(brdad_mcamsis_simp!=.))
*10241

scatter dad_mcamsis_simp brdad_mcamsis_simp ///
if ((dad_mcamsis_simp!=.)&(brdad_mcamsis_simp!=.)), ///
jitter(10) msize(small) scheme(s1mono) ///
xtitle("Father's Birth Record CAMSIS") ytitle("Father's Survey CAMSIS") ///
title("Father's CAMSIS derived from Survey and Birth Record") ///
note("Note: Simplified CAMSIS, Cases with valid SOC2000 on Survey and Birth Record only," ///
"n=10,241, r=0.83, p<0.001")







****Agreement of NSSEC
	
tab brmum_nssec_simp 

tab brdad_nssec_simp, mi 

tab mum_nssec_simp 

tab dad_nssec_simp, mi
		
		
capture drop dadnssecmatch
gen dadnssecmatch = .
replace dadnssecmatch = 1 if (brdad_nssec_simp==dad_nssec_simp)
replace dadnssecmatch = 0 if (brdad_nssec_simp!=dad_nssec_simp)
replace dadnssecmatch = . if (brdad_nssec_simp==.)|(dad_nssec_simp==.)
label variable dadnssecmatch "Dad's nssec matches"
label values dadnssecmatch yesno
tab dadnssecmatch, mi
tab dadnssecmatch

capture drop mumnssecmatch
gen mumnssecmatch = .
replace mumnssecmatch = 1 if (brmum_nssec_simp==mum_nssec_simp)
replace mumnssecmatch = 0 if (brmum_nssec_simp!=mum_nssec_simp)
replace mumnssecmatch = . if (brmum_nssec_simp==.)|(mum_nssec_simp==.)
label variable mumnssecmatch "Mum's nssec matches"
label values mumnssecmatch yesno
tab mumnssecmatch, mi	
tab mumnssecmatch	





************************

***Footnote
*I have use the simplified NS-SEC throughout as there is not 
*employment status information in the birth records files I have
*Here I will compare the simplified and full NS-SEC in the MCS
*to see how much agreement there is between these two measures

tab mumnssec mum_nssec_simp
tab dadnssec dad_nssec_simp

pwcorr mumnssec mum_nssec_simp, sig
*0.96 p<0.001
pwcorr dadnssec dad_nssec_simp, sig
*0.92 p<0.001

kap mumnssec mum_nssec_simp
*86% agreement kap 0.83

kap dadnssec dad_nssec_simp
*78% agreement kap 0.75



***************************

****Error in Practice
*lead to misclassification

****Error in Principle
*Do not lead to misclassification

tab mummatch, mi
*25% doesn't match

tab mumnssecmatch 

tab mumnssecmatch if (mummatch==2)
*If soc2000 doesn't match
*nssec is the same 40% of the time

tab dadnssecmatch 

tab dadnssecmatch if (dadmatch==2)




****NSSEC by NSSEC Table


tab mummatch
tab dadmatch

tab brmum_nssec_simp
tab mum_nssec_simp


tab brmum_nssec_simp mum_nssec_simp if (mummatch<=2)
estpost tab brmum_nssec_simp mum_nssec_simp if (mummatch<=2)
esttab using E:\blank.rtf, cell(b rowpct(fmt(0))) unstack replace


tab brdad_nssec_simp dad_nssec_simp if (dadmatch<=2)
estpost tab brdad_nssec_simp dad_nssec_simp if (dadmatch<=2)
esttab using E:\blank.rtf, cell(b rowpct(fmt(0))) unstack replace
		












********************************************************************************

***Descriptive Statistics of additional variables for the regression models

use $path2\MCS1_BirthRecordsOccupations_V6.dta, clear
drop if country==.
numlabel, add

*Highest Academic Qualification of two parents

tab mumeduc, mi
tab dadeduc, mi

recode mumeduc dadeduc (8=.)

capture drop hied
egen hied = rmax(mumeduc dadeduc)
tab hied
replace hied = 8 if ((mumeduc==8)&(dadeduc==8))
label values hied mumeduc
tab hied, mi
label variable hied "Parents Highed Academic Qualification"


*Age of Mother
tab mumage, mi

*Ethnicity of Mother
tab mumeth, mi

*Baby's age at interview
summ cmage

*Sample for this analysis
capture drop miss
egen miss = rmiss(hied mumage mumeth cmage)
tab miss
tab country, mi


capture drop miss
egen miss = rmiss(hied mumage mumeth cmage dadmatch mummatch)
tab miss


tab mumage if (miss==0), mi
tab mumeth if (miss==0), mi
tab hied if (miss==0), mi

keep if (miss==0)


svyset sptn00 [pweight=weight2], strata(pttype2) fpc(nh2)	

tab mumage, mi
tab mumeth, mi
tab hied, mi

svy: tab mumage, count col
svy: tab mumeth, count col
svy: tab hied, count col

sort mcsid
save $path2\MCS1_BirthRecordsOccupations_V7.dta, replace


















********************************************************************************
****Regression models of patterns of difference in occupations between
****the birth records and survey


use $path2\MCS1_BirthRecordsOccupations_V7.dta, clear
tab country, mi
numlabel, add

tab mumbrmiss 
tab mumsurmiss
tab dadbrmiss 
tab dadsurmiss


****Unadjusted Estimates

logit mumsurmiss ib2.mumage i.mumeth ib5.hied
fitstat
est sto m1

logit mumbrmiss ib2.mumage i.mumeth ib5.hied
fitstat
est sto m2

logit dadsurmiss ib2.mumage i.mumeth ib5.hied
fitstat
est sto m3

logit dadbrmiss ib2.mumage i.mumeth ib5.hied
fitstat
est sto m4


esttab m1 m2 m3 m4 using blank.rtf, replace cells(b(star fmt(2) ///
label(Log Odds)) se(par fmt(2))) stats(n)
		
		

tab mummatch 
tab dadmatch	

mlogit mummatch ib2.mumage i.mumeth ib5.hied cmage 	
fitstat
est sto m1

mlogit dadmatch ib2.mumage i.mumeth ib5.hied cmage 	
fitstat
est sto m2
		
esttab m1 using blank.rtf, b(2) se(2) wide replace
		
esttab m2 using blank.rtf, b(2) se(2) wide replace		
		
		
		
****Adjusted Estimates

*UK weight
svyset sptn00 [pweight=weight2], strata(pttype2) fpc(nh2)	
	
		
		
svy: logit mumsurmiss ib2.mumage i.mumeth ib5.hied
fitstat
est sto m1

svy: logit mumbrmiss ib2.mumage i.mumeth ib5.hied
fitstat
est sto m2

svy: logit dadsurmiss ib2.mumage i.mumeth ib5.hied
fitstat
est sto m3

svy: logit dadbrmiss ib2.mumage i.mumeth ib5.hied
fitstat
est sto m4


esttab m1 m2 m3 m4 using blank.rtf, replace cells(b(star fmt(2) ///
label(Log Odds)) se(par fmt(2))) stats(n)
		
		

tab mummatch 
tab dadmatch	



svy: mlogit mummatch ib2.mumage i.mumeth ib5.hied cmage 	
fitstat
est sto m1



svy: mlogit dadmatch ib2.mumage i.mumeth ib5.hied cmage 	
fitstat
est sto m2
		
esttab m1 using blank.rtf, b(2) se(2) wide replace
		
esttab m2 using blank.rtf, b(2) se(2) wide replace		
				
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
********************************************************************************
****Graphs of the Regression results might help interpretation		
		
use $path2\MCS1_BirthRecordsOccupations_V7.dta, clear
tab country, mi
numlabel, add		
		
		
		

		
		
****Adjusted Estimates

*UK weight
svyset sptn00 [pweight=weight2], strata(pttype2) fpc(nh2)	
	
collin 	mumage mumeth hied	
		
svy: logit mumsurmiss ib2.mumage i.mumeth ib5.hied
est sto survey_mum

svylogitgof

qv ib2.mumage
qvgraph ib2.mumage

label list



qvgraph ib2.mumage, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4) ///
					plotregion(style(none)) fysize(55) fxsize(55) ///
					xscale(off) ///
					ylabel(1 "Under 19" 2 "20-29" ///
					3 "30-39" 4 "Over 40" , ///
					labsize(small) angle(0) ) ///
					ytitle("Mother's Age at Delivery", size(small)) ///
					title("Survey", size(medsmall)) 
						
graph save Graph "H:\temp\mumsurage.gph", replace

qv i.mumeth


qvgraph i.mumeth, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4) ///
					plotregion(style(none)) fysize(55) fxsize(55) ///
					xscale(off) ///
					ylabel(1 "White" 2 "Mixed" ///
					3 "Indian" 4 "Pakistani" ///
					5 "Bangladeshi" 6 " Black Carib." 7 "Black Afr." ///
					8 "Other" , labsize(small) angle(0)) ///
					ytitle("Mother's Ethnicity", size(small)) 
	

graph save Graph "H:\temp\mumsureth.gph", replace					



qv ib5.hied

qvgraph ib5.hied, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4) ///
					plotregion(style(none)) fysize(55) fxsize(55) ///
					ylabel(1 "Higher Degree" 2 " First Degree" 3 "  Diploma HE" ///
					4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" ///
					7 "None" , ///
					 labsize(small) angle(0)) ///
					ytitle("Parents' Education Level", size(small)) 

graph save Graph "H:\temp\mumsured.gph", replace



svy: logit mumbrmiss ib2.mumage i.mumeth ib5.hied
est sto records_mum

qv ib2.mumage
qvgraph ib2.mumage, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xscale(off) ///
					ylabel(1 "Under 19" 2 "20-29" 3 "30-39" 4 "Over 40", ///
					labsize(small) angle(0)) ///
					ytitle("Mother's Age at Delivery") ///
					title("Birth Record", size(medsmall))
					

graph save Graph "H:\temp\mumbrage.gph"	, replace					
					
					
qv i.mumeth
qvgraph i.mumeth, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4) ///
					plotregion(style(none)) ///
					xscale(off) ///
					ylabel(1 "White" 2 "Mixed" 3 "Indian" 4 "Pakistani" ///
					5 "Bangladeshi" 6 "Black Carib." 7 "Black Afr." ///
					8 "Other", labsize(small) angle(0)) ///
					ytitle("Mother's Ethnicity") 
					
				
graph save Graph "H:\temp\mumbreth.gph"	, replace	
					
					
qv ib5.hied
qvgraph ib5.hied, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4)  ///
					plotregion(style(none)) ///
					ylabel(1 "Higher Degree" 2 "First Degree" 3 "Diploma HE" ///
					4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" 7 "None", ///
					labsize(small)  angle(0)) ///
					ytitle("Parents' Education Level")
					

graph save Graph "H:\temp\mumbred.gph", replace							

svy: logit dadsurmiss ib2.mumage i.mumeth ib5.hied
est sto survey_dad

qv ib2.mumage
qvgraph ib2.mumage, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xscale(off) ///
					ylabel(1 "Under 19" 2 "20-29" 3 "30-39" 4 "Over 40", ///
					labsize(small) angle(0)) ///
					ytitle("Mother's Age at Delivery") ///
					title("Survey", size(medsmall))

graph save Graph "H:\temp\dadsurage.gph", replace						
					
					
					
qv i.mumeth
qvgraph i.mumeth, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4) ///
					plotregion(style(none)) ///
					xscale(off) ///
					ylabel(1 "White" 2 "Mixed" 3 "Indian" 4 "Pakistani" ///
					5 "Bangladeshi" 6 "Black Carib." 7 "Black Afr." ///
					8 "Other", labsize(small) angle(0)) ///
					ytitle("Mother's Ethnicity") 

					

graph save Graph "H:\temp\dadsureth.gph", replace						
					
					
qv ib5.hied
qvgraph ib5.hied, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4)  ///
					plotregion(style(none)) ///
					ylabel(1 "Higher Degree" 2 "First Degree" 3 "Diploma HE" ///
					4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" 7 "None", ///
					labsize(small) angle(0)) ///
					ytitle("Parents' Education Level") 
					
					
					
					

graph save Graph "H:\temp\dadsured.gph"	, replace						
					
					

svy: logit dadbrmiss ib2.mumage i.mumeth ib5.hied
est sto records_dad

qv ib2.mumage
qv ib2.mumage
qvgraph ib2.mumage, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xscale(off) ///
					ylabel(1 "Under 19" 2 "20-29" 3 "30-39" 4 "Over 40", ///
					labsize(small) angle(0)) ///
					ytitle("Mother's Age at Delivery") ///
					title("Birth Record", size(medsmall))

					
graph save Graph "H:\temp\dadbrage.gph"	, replace					
					
					
qv i.mumeth
qvgraph i.mumeth, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xscale(off) ///
					ylabel(1 "White" 2 "Mixed" 3 "Indian" 4 "Pakistani" ///
					5 "Bangladeshi" 6 "Black Carib." 7 "Black Afr." ///
					8 "Other", labsize(small) angle(0)) ///
					ytitle("Mother's Ethnicity") 

					
graph save Graph "H:\temp\dadbreth.gph"	, replace					
					
					
qv ib5.hied
qvgraph ib5.hied, scheme(s1mono) hori xscale(r(-2 4)) xlabel(-2[1]4)  ///
					plotregion(style(none)) ///
					ylabel(1 "Higher Degree" 2 "First Degree" 3 "Diploma HE" ///
					4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" 7 "None", ///
					labsize(small) angle(0)) ///
					ytitle("Parents' Education Level") 
					
graph save Graph "H:\temp\dadbred.gph", replace							
					
				

esttab survey_mum records_mum survey_dad records_dad ///
					using blank.rtf, replace cells(b(star fmt(2) ///
					label(Log Odds)) se(par fmt(2))) stats(n)		

					
****Graph Combine

graph combine "H:\temp\mumsurage.gph" "H:\temp\dadsurage.gph" ///
				"H:\temp\mumbrage.gph" "H:\temp\dadbrage.gph" ///
				"H:\temp\mumsureth.gph" "H:\temp\dadsureth.gph" ///
				"H:\temp\mumbreth.gph" "H:\temp\dadbreth.gph" ///
				"H:\temp\mumsured.gph" "H:\temp\dadsured.gph" ///	
				"H:\temp\mumbred.gph" "H:\temp\dadbred.gph"	, ///
				scheme(s1mono) ///
				title("Missing Occupational Information", size(medsmall)) ///
				subtitle("Logit Coefficients and Quasi-Standard Errors", size(medsmall)) ///
				note("Note: UK Millennium Cohort Study (SN4683 & SN5614)" ///
				"Models are adjusted for survey design, Northern Ireland Excluded, n=14,827", size(vsmall))
								
		
		
*Separate graphs for mothers and fathers

*Father		
					
graph combine "H:\temp\dadsurage.gph" ///
				"H:\temp\dadbrage.gph" ///
				"H:\temp\dadsureth.gph" ///
				"H:\temp\dadbreth.gph" ///
				"H:\temp\dadsured.gph" ///	
				"H:\temp\dadbred.gph"	, ///
				scheme(s1mono) cols(2) xsize(10) ysize(10) ///
				title("Father's Missing Occupational Information", size(small)) ///
				subtitle("Logit Coefficients and Quasi-Standard Errors", size(small)) ///
				note("Note: UK Millennium Cohort Study (SN4683 & SN5614)" ///
				"Models are adjusted for survey design, Northern Ireland Excluded, n=14,827", size(vsmall))					
		
					
*Mother
					
graph combine "H:\temp\mumsurage.gph" ///
				"H:\temp\mumbrage.gph" ///
				"H:\temp\mumsureth.gph" ///
				"H:\temp\mumbreth.gph" ///
				"H:\temp\mumsured.gph" ///	
				"H:\temp\mumbred.gph"	, ///
				scheme(s1mono) cols(2) xsize(10) ysize(10) xcommon ///
				title("Mother's Missing Occupational Information", size(small)) ///
				subtitle("Logit Coefficients and Quasi-Standard Errors", size(small)) ///
				note("Note: UK Millennium Cohort Study (SN4683 & SN5614)" ///
				"Models are adjusted for survey design, Northern Ireland Excluded, n=14,827", size(vsmall))					
					
					
					
					
					
					
					
****VERTICAL
		
use $path2\MCS1_BirthRecordsOccupations_V7.dta, clear
tab country, mi
numlabel, add		
		
		
****Adjusted Estimates

*UK weight
svyset sptn00 [pweight=weight2], strata(pttype2) fpc(nh2)	
	
		
collin mumage mumeth hied
		
svy: logit mumsurmiss ib2.mumage i.mumeth ib5.hied


qvgraph ib2.mumage, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4) ///
					plotregion(style(none)) ///
					xlabel(1 "Under 19" 2 "20-29" ///
					3 "30-39" 4 "Over 40" , ///
					labsize(small) ) ///
					xtitle("Mother's Age at Delivery", size(small)) ///
					title("Survey", size(medsmall)) 
						
graph save Graph "H:\temp\mumsurage2.gph", replace

qvgraph i.mumeth, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4) ///
					plotregion(style(none)) ///
					xlabel(1 "White" 2 "Mixed" ///
					3 "Indian" 4 "Pakistani" ///
					5 "Bangladeshi" 6 " Black Carib." 7 "Black Afr." ///
					8 "Other" , alternate labsize(small) ) ///
					xtitle("Mother's Ethnicity", size(small)) 
	

graph save Graph "H:\temp\mumsureth2.gph", replace					


qvgraph ib5.hied, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4) ///
					plotregion(style(none)) ///
					xlabel(1 "Higher Degree" 2 " First Degree" 3 "  Diploma HE" ///
					4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" ///
					7 "None" , ///
					alternate labsize(small)) ///
					xtitle("Parents' Education Level", size(small)) 

graph save Graph "H:\temp\mumsured2.gph", replace



svy: logit mumbrmiss ib2.mumage i.mumeth ib5.hied

qvgraph ib2.mumage, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xlabel(1 "Under 19" 2 "20-29" 3 "30-39" 4 "Over 40", ///
					labsize(small) ) ///
					xtitle("Mother's Age at Delivery", size(small)) ///
					title("Birth Record", size(medsmall))
					

graph save Graph "H:\temp\mumbrage2.gph"	, replace					
					
				
qvgraph i.mumeth, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4) ///
					plotregion(style(none)) ///
					xlabel(1 "White" 2 "Mixed" 3 "Indian" 4 "Pakistani" ///
					5 "Bangladeshi" 6 "Black Carib." 7 "Black Afr." ///
					8 "Other", alternate labsize(small) ) ///
					xtitle("Mother's Ethnicity", size(small)) 
					
				
graph save Graph "H:\temp\mumbreth2.gph"	, replace	
					
				
qvgraph ib5.hied, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xlabel(1 "Higher Degree" 2 "First Degree" 3 "Diploma HE" ///
					4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" 7 "None", ///
					alternate labsize(small) ) ///
					xtitle("Parents' Education Level", size(small))
					

graph save Graph "H:\temp\mumbred2.gph", replace							

svy: logit dadsurmiss ib2.mumage i.mumeth ib5.hied


qvgraph ib2.mumage, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xlabel(1 "Under 19" 2 "20-29" 3 "30-39" 4 "Over 40", ///
					labsize(small) angle(0)) ///
					xtitle("Mother's Age at Delivery", size(small)) ///
					title("Survey", size(medsmall))

graph save Graph "H:\temp\dadsurage2.gph", replace						
					
					
					

qvgraph i.mumeth, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4) ///
					plotregion(style(none)) ///
					xlabel(1 "White" 2 "Mixed" 3 "Indian" 4 "Pakistani" ///
					5 "Bangladeshi" 6 "Black Carib." 7 "Black Afr." ///
					8 "Other", alternate labsize(small) ) ///
					xtitle("Mother's Ethnicity", size(small)) 

					

graph save Graph "H:\temp\dadsureth2.gph", replace						
					
					

qvgraph ib5.hied, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xlabel(1 "Higher Degree" 2 "First Degree" 3 "Diploma HE" ///
					4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" 7 "None", ///
					alternate labsize(small) ) ///
					xtitle("Parents' Education Level", size(small)) 
					
graph save Graph "H:\temp\dadsured2.gph"	, replace						
					
					

svy: logit dadbrmiss ib2.mumage i.mumeth ib5.hied

qvgraph ib2.mumage, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xlabel(1 "Under 19" 2 "20-29" 3 "30-39" 4 "Over 40", ///
					labsize(small) ) ///
					xtitle("Mother's Age at Delivery", size(small)) ///
					title("Birth Record", size(medsmall))

					
graph save Graph "H:\temp\dadbrage2.gph"	, replace					
					
					

qvgraph i.mumeth, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xlabel(1 "White" 2 "Mixed" 3 "Indian" 4 "Pakistani" ///
					5 "Bangladeshi" 6 "Black Carib." 7 "Black Afr." ///
					8 "Other", alternate labsize(small) ) ///
					xtitle("Mother's Ethnicity", size(small)) 

					
graph save Graph "H:\temp\dadbreth2.gph"	, replace					
					
					

qvgraph ib5.hied, scheme(s1mono) yscale(r(-2 4)) ylabel(-2[1]4)  ///
					plotregion(style(none)) ///
					xlabel(1 "Higher Degree" 2 "First Degree" 3 "Diploma HE" ///
					4 "A Levels" 5 "GCSE A-C" 6 "GCSE D-G" 7 "None", ///
					alternate labsize(small) ) ///
					xtitle("Parents' Education Level", size(small)) 
					
graph save Graph "H:\temp\dadbred2.gph", replace							
										
					
					
					
					
					
					

*Father		
					
graph combine "H:\temp\dadsurage2.gph" ///
				"H:\temp\dadbrage2.gph" ///
				"H:\temp\dadsureth2.gph" ///
				"H:\temp\dadbreth2.gph" ///
				"H:\temp\dadsured2.gph" ///	
				"H:\temp\dadbred2.gph"	, ///
				scheme(s1mono) cols(2)  ///
				title("Father's Missing Occupational Information", size(small)) ///
				subtitle("Logit Coefficients and Quasi-Standard Errors", size(small)) ///
				note("Note: UK Millennium Cohort Study (SN4683 & SN5614)" ///
				"Models are adjusted for survey design, Northern Ireland Excluded, n=14,827", size(vsmall))					
		
					
*Mother
					
graph combine "H:\temp\mumsurage2.gph" ///
				"H:\temp\mumbrage2.gph" ///
				"H:\temp\mumsureth2.gph" ///
				"H:\temp\mumbreth2.gph" ///
				"H:\temp\mumsured2.gph" ///	
				"H:\temp\mumbred2.gph"	, ///
				scheme(s1mono) cols(2) ///
				title("Mother's Missing Occupational Information", size(small)) ///
				subtitle("Logit Coefficients and Quasi-Standard Errors", size(small)) ///
				note("Note: UK Millennium Cohort Study (SN4683 & SN5614)" ///
				"Models are adjusted for survey design, Northern Ireland Excluded, n=14,827", size(vsmall))					
										

					
					
					
					
					
					
		
					
					

*Coefplot
coefplot (survey_mum, label(Mother)) (survey_dad, label(Father)), bylabel(Survey) ///
	  || (records_mum)				 (records_dad)              , bylabel(Birth Record)	///
	  ||, xline(0) byopts(xrescale) 
*can't get quasi-standard errors with coefplot










****MLOGIT - different combinations of missing
*mlogplot doesn't accept factor variables


tab mumage, gen(mage)
	
label variable mage1 "<19"
label variable mage2 "20-29"
label variable mage3 "30-39"
label variable mage4 "40+"


tab mumeth, gen(eth)

label variable eth2 "Mixed"
label variable eth3 "Indian"
label variable eth4 "Pakistani"
label variable eth5 "Bangleshi"
label variable eth6 "Black Caribbean"
label variable eth7 "Black African"
label variable eth8 "Other"

tab hied, gen(ed)

label variable ed1 "Higher Degree"
label variable ed2 "First Degree"
label variable ed3 "Diploma HE"
label variable ed4 "A Levels"
label variable ed6 "GCSE A-G"
label variable ed7 "None"	

label variable cmage "Child's Age at Survey"

numlabel, add
tab mummatch	
label define match 1 "M" 2 "N" 3 "A" 4 "R" 5 "S", replace
label values mummatch match		
label values dadmatch match


svy: mlogit mummatch mage1 mage2 mage4 eth2 eth3 eth4 eth5 eth6 eth7 eth8 ///
						ed1 ed2 ed3 ed4 ed6 ed7 cmage 	
						
prchange

mlogplot mage1 mage2 mage4, ///
					oratio std(000) base(1) labels prob(0.05) ///
					min(-1) max(4)

graph save "H:\temp\mummatch1.gph", replace	


mlogplot eth2 eth3 eth4 eth5 eth6 eth7 eth8, ///
					oratio std(0000000) base(1) labels prob(0.05)  ///
					min(-1) max(4)

graph save "H:\temp\mummatch2.gph", replace	


mlogplot ed1 ed2 ed3 ed4 ed6 ed7 cmage , ///
					oratio std(000000s) base(1) labels prob(0.05)  ///
					min(-1) max(4)
					
graph save Graph "H:\temp\mummatch3.gph", replace						


/****
****saving and graph combine doesn't seem to work for mlogplot
					
graph combine "H:\temp\mummatch1.gph" "H:\temp\mummatch2.gph" "H:\temp\mummatch3.gph"		
					

graph combine  "H:\temp\mummatch2.gph" "H:\temp\mummatch3.gph"

"H:\temp\mummatch1.gph"

svy: mlogit dadmatch ib2.mumage i.mumeth ib5.hied cmage 	

*****/

svy: mlogit dadmatch mage1 mage2 mage4 eth2 eth3 eth4 eth5 eth6 eth7 eth8 ///
						ed1 ed2 ed3 ed4 ed6 ed7 cmage 	
						
prchange

mlogplot mage1 mage2 mage4, ///
					oratio std(000) base(1) labels prob(0.05) ///
					min(-1.3) max(3.5)


mlogplot eth2 eth3 eth4 eth5 eth6 eth7 eth8, ///
					oratio std(0000000) base(1) labels prob(0.05) ///
					min(-1.3) max(3.5)


mlogplot ed1 ed2 ed3 ed4 ed6 ed7 cmage , ///
					oratio std(000000s) base(1) labels prob(0.05) 	///
					min(-1.3) max(3.5)

					

	
						

		
********************************************************************************

****Now I am going to add in some outcomes to see how the survey and birth 
*records variables are associated with these.


use $path2\MCS1_BirthRecordsOccupations_V7.dta, clear
tab country, mi
numlabel, add	

keep mcsid brmum_nssec_simp brdad_nssec_simp mum_nssec_simp ///
		dad_nssec_simp hied mumage mumeth	
	
sort mcsid
save $path3\mcsbirthrecords.dta, replace

	
	
	
**Cohort member details from mcs1/mcs2

use $path1\ARCHIVE\MCS1\stata9_se\mcs1_hhgrid.dta, clear
keep MCSID AHCNUM00 AHCSEX00
numlabel, add

rename MCSID mcsid
rename AHCNUM00 cmnum
tab cmnum
drop if cmnum==-1

tab AHCSEX00
capture drop male
gen male = .
replace male = 1 if (AHCSEX00==1)
replace male = 0 if (AHCSEX00==2)
label define yesno 1 "yes" 0 "no"
label values male yesno
label variable male "cm male"
tab male
drop AHCSEX00
	
sort mcsid cmnum
save $path3\mcs0.dta, replace	


use $path1\ARCHIVE\MCS2\mcs2_hhgrid.dta, clear
keep MCSID BHCNUM00 BHCSEX00
numlabel, add

rename MCSID mcsid
rename BHCNUM00 cmnum
tab cmnum
drop if cmnum==-1

tab BHCSEX00
capture drop male
gen male = .
replace male = 1 if (BHCSEX00==1)
replace male = 0 if (BHCSEX00==2)
label define yesno 1 "yes" 0 "no"
label values male yesno
label variable male "cm male"
tab male
drop BHCSEX00
	
sort mcsid cmnum
save $path3\mcs3.dta, replace	

	

**MCS3 (Age 5)


use $path1\ARCHIVE\MCS3\mcs3_child_assessment_data.dta, clear
keep mcsid chcnum00 ccyage00 mcs3age cdnvtscr chcage00
numlabel, add

tab chcnum00
rename chcnum00 cmnum

tab ccyage00 



tab mcs3age 

tab cdnvtscr 
rename cdnvtscr mcs3vocab
recode mcs3vocab (-1=.)

tab chcage00

sort mcsid cmnum
save $path3\mcs5.dta, replace




**MCS5 (Age 11)


use $path1\ARCHIVE\MCS5\mcs5_cm_asssessment.dta, clear	
keep MCSID ECCNUM00 EVSTSCO AGE ECCAGE00 ECCSEX00
numlabel, add

rename MCSID mcsid

tab ECCNUM00
rename ECCNUM00 cmnum


tab EVSTSCO 
recode EVSTSCO (-1=.)
rename EVSTSCO mcs5verb


tab AGE

sort mcsid cmnum
save $path3\mcs11.dta, replace



***Merge these together

use $path3\mcs0.dta, clear
sort mcsid cmnum 
merge 1:1 mcsid cmnum using $path3\mcs3.dta
drop _merge
sort mcsid cmnum
merge 1:1 mcsid cmnum using $path3\mcs5.dta
drop _merge
sort mcsid cmnum
merge 1:1 mcsid cmnum using $path3\mcs11.dta
drop _merge
save $path3\mcsall.dta, replace




use $path1\ARCHIVE\MCS5\longitudinal_family_file.dta, clear
rename MCSID mcsid
merge 1:1 mcsid using $path3\mcsbirthrecords.dta		
drop _merge
sort mcsid
merge 1:m mcsid using $path3\mcsall.dta	
drop _merge	
sort mcsid cmnum
save $path3\MCS_BR_OUTCOMES.dta, replace	
		
	
	
	
	
	
	
/****Models of test score outcomes at MCS3 and MCS5

Sample size will change due to missing data

Covariates in model: male mumage mumeth hied
	and mum/dad NSSEC from either survey or birth record.		
	
brmum_nssec_simp brdad_nssec_simp 
mum_nssec_simp dad_nssec_simp	
	
*/
	
	
	
	
	
	
	
use $path3\MCS_BR_OUTCOMES.dta, clear
	
	
*MCS3 (Age 5) Outcome - missingness on all variables

capture drop samp3
egen samp3 = rmiss(mcs3vocab male brmum_nssec_simp ///
					brdad_nssec_simp mum_nssec_simp dad_nssec_simp)
tab samp3

*MCS5 (Age 11) Outcome - missingness on all variables
	
capture drop samp5
egen samp5 = rmiss(mcs5verb male brmum_nssec_simp ///
					brdad_nssec_simp mum_nssec_simp dad_nssec_simp)
tab samp5


*Dad Survey not missing
capture drop tag31
gen tag31 = 1 if (dad_nssec_simp!=.)
tab tag31

*Mum Survey not missing
capture drop tag32
gen tag32 = 1 if (mum_nssec_simp!=.)
tab tag32

*Dad birth records not missing
capture drop tag33
gen tag33 = 1 if (brdad_nssec_simp!=.)
tab tag33

*Mum Birth Records not missing
capture drop tag34
gen tag34 = 1 if (brmum_nssec_simp!=.)
tab tag34

*Dad present on both birth records and survey
capture drop tag35
gen tag35 = 1 if ((brdad_nssec_simp!=.)&(dad_nssec_simp!=.))
tab tag35

*Mum present on both birth records and survey
capture drop tag36
gen tag36 = 1 if ((brmum_nssec_simp!=.)&(mum_nssec_simp!=.))
tab tag36


	
	
	
	
	
	
collin male brmum_nssec_simp	brdad_nssec_simp if (samp3==0)
collin male brmum_nssec_simp	brdad_nssec_simp if (samp5==0)

collin male mum_nssec_simp dad_nssec_simp if (samp3==0)
collin male mum_nssec_simp dad_nssec_simp if (samp5==0)
	
	
	
	
****Mean Test Score



summ mcs3vocab if (tag31==1)
*55.0169
capture drop mcs3vocabdadsur
gen mcs3vocabdadsur = mcs3vocab if (tag31==1)
tab mcs3vocab tag31, mi
mean mcs3vocabdadsur
*55.0169

summ mcs3vocab if (tag32==1)
*54.96679
capture drop mcs3vocabmumsur
gen mcs3vocabmumsur = mcs3vocab if (tag32==1)
mean mcs3vocabmumsur
*54.96679

summ mcs3vocab if (tag33==1)
*54.47755
capture drop mcs3vocabdadbr
gen mcs3vocabdadbr = mcs3vocab if (tag33==1)
tab mcs3vocab tag33, mi
mean mcs3vocabdadbr
*54.47755

ttest mcs3vocabdadbr==55.0169
*dad's birth records is significantly lower than survey

summ mcs3vocab if (tag34==1)
*56.21599
capture drop mcs3vocabmumbr
gen mcs3vocabmumbr = mcs3vocab if (tag34==1)
mean mcs3vocabmumbr
*56.21599

summ mcs3vocab if (tag35==1)
*55.13901
capture drop mcs3vocabdadboth
gen mcs3vocabdadboth = mcs3vocab if (tag35==1)
mean mcs3vocabdadboth
*55.13901

ttest mcs3vocabdadboth==54.47755
*Both significantly more than birth record

ttest mcs3vocabdadboth==55.0169
*Both not significantly higher than in survey

summ mcs3vocab if (tag36==1)
*56.29039
capture drop mcs3vocabmumboth
gen mcs3vocabmumboth = mcs3vocab if (tag36==1)
mean mcs3vocabmumboth
*56.29039






svyset SPTN00 [pweight=COVWT2], strata(PTTYPE2) fpc(NH2)	

recode COVWT2 (-1=.)

svy: mean mcs3vocab if (tag31==1)
svy: mean mcs3vocab if (tag32==1)
svy: mean mcs3vocab if (tag33==1)
svy: mean mcs3vocab if (tag34==1)
svy: mean mcs3vocab if (tag35==1)
svy: mean mcs3vocab if (tag36==1)


keep mcs3vocab COVWT2


summ mcs5verb if (tag31==1)
summ mcs5verb if (tag32==1)
summ mcs5verb if (tag33==1)
summ mcs5verb if (tag34==1)
summ mcs5verb if (tag35==1)
summ mcs5verb if (tag36==1)

svyset SPTN00 [pweight=EOVWT2], strata(PTTYPE2) fpc(NH2)	
recode EOVWT2 (-1=.)

svy: mean mcs5verb if (tag31==1)
svy: mean mcs5verb if (tag32==1)
svy: mean mcs5verb if (tag33==1)
svy: mean mcs5verb if (tag34==1)
svy: mean mcs5verb if (tag35==1)
svy: mean mcs5verb if (tag36==1)
	
	

	
	

	
	
**Regressions
	
	
	
svyset SPTN00 [pweight=COVWT2], strata(PTTYPE2) fpc(NH2)	


regress mcs3vocab male ib3.brmum_nssec_simp if (tag36==1)
est sto ccmumm1

regress mcs3vocab male ib3.brdad_nssec_simp  if (tag35==1)
est sto ccdadm1

svy: regress mcs3vocab male ib3.brmum_nssec_simp if (tag36==1)
est sto ccmumm1svy

qv ib3.brmum_nssec_simp



svy: regress mcs3vocab male ib3.brdad_nssec_simp  if (tag35==1)
est sto ccdadm1svy

qv ib3.brdad_nssec_simp
				


				
regress mcs3vocab male ib3.mum_nssec_simp  if (tag36==1)
est sto surccmumm1

regress mcs3vocab male ib3.dad_nssec_simp   if (tag35==1)
est sto surccdadm1

svy: regress mcs3vocab male ib3.mum_nssec_simp  if (tag36==1)
est sto surccmumm1svy

qv ib3.mum_nssec_simp



svy: regress mcs3vocab male ib3.dad_nssec_simp  if (tag35==1)
est sto surccdadm1svy

qv ib3.dad_nssec_simp


								
				
				
				
			
*Ajusted			
esttab ccmumm1svy surccmumm1svy ccdadm1svy surccdadm1svy using blank.rtf, wide replace ///
				b(2) se(2)	
						

*Unadjusted	
esttab ccmumm1 surccmumm1 ccdadm1 surccdadm1 using blank.rtf, wide replace ///
				b(2) se(2)		

	
		
		
svyset SPTN00 [pweight=EOVWT2], strata(PTTYPE2) fpc(NH2)
recode EOVWT2 (-1=.)			
		
regress mcs5verb male ib3.brmum_nssec_simp  if (tag36==1)
est sto ccmumm3

regress mcs5verb male ib3.brdad_nssec_simp  if (tag35==1)
est sto ccdadm3

svy: regress mcs5verb male ib3.brmum_nssec_simp  if (tag36==1)
est sto ccmumm3svy

qv ib3.brmum_nssec_simp




svy: regress mcs5verb male ib3.brdad_nssec_simp  if (tag35==1)
est sto ccdadm3svy
				
qv ib3.brdad_nssec_simp	





regress mcs5verb male ib3.mum_nssec_simp  if (tag36==1)
est sto surccmumm3

regress mcs5verb male ib3.dad_nssec_simp  if (tag35==1)
est sto surccdadm3

svy: regress mcs5verb male ib3.mum_nssec_simp  if (tag36==1)
est sto surccmumm3svy

qv ib3.mum_nssec_simp



svy: regress mcs5verb male ib3.dad_nssec_simp  if (tag35==1)
est sto surccdadm3svy
				
qv ib3.dad_nssec_simp

			
				

*Ajusted			
esttab ccmumm3svy surccmumm3svy ccdadm3svy surccdadm3svy using blank.rtf, wide replace ///
				b(2) se(2)	
						

*Unadjusted	
esttab ccmumm3 surccmumm3 ccdadm3 surccdadm3 using blank.rtf, wide replace ///
				b(2) se(2)		

					
					
					
					
					
					
					
					
					
	
**Graph of these results
*From adjusted models with quasi standard errors


*Age 5


clear
input nssec source mum beta lower upper

/*Mother Birth Record*/
0 1	1 1.8966    0.5022       3.2911
1 1	1 2.4916   1.4777       3.5054
2 1 1 0.0000  -0.6009       0.6009
3 1	1 -2.0185  -2.5266      -1.5104
4 1 1 -2.2222   -3.8594      -0.5851 
5 1 1 -1.6457   -5.0624       1.7709 
6 1 1 -5.3852   -6.1992      -4.5712
7 1	1 -6.0586   -7.1195      -4.9977
/*Mother Survey*/
0.2 2 1	1.0851  -0.1289       2.2991
1.2 2 1	1.6637  0.6090       2.7185
2.2	2 1 0.0000 -0.6721       0.6721
3.2 2 1 -2.5209 -2.9757      -2.0661
4.2 2 1 -2.5324 -3.8049      -1.2600
5.2 2 1 -3.1374 -6.1303      -0.1445
6.2 2 1 -5.3579 -6.0772      -4.6387
7.2 2 1 -6.5745  -7.5974      -5.5516
/*Father Birth Record*/
0 1 0  1.2642 0.2901       2.2383
1 1 0 2.2309 1.3051       3.1568
2 1 0  0.0000 -0.6523       0.6523
3 1 0 -0.4728 -1.2586       0.3130
4 1 0  -3.7180 -4.6318      -2.8042
5 1 0  -2.0965 -2.9655      -1.2274
6 1 0  -5.0483 -6.0383      -4.0583
7 1 0  -5.5043 -6.3047      -4.7040
/*Father Survey*/
0.2 2 0	 1.7168  0.7834       2.6503
1.2 2 0	 2.4765  1.4982       3.4547
2.2 2 0	0.0000 -0.6199       0.6199
3.2 2 0	-1.2131  -2.1121      -0.3140
4.2 2 0	-3.9227  -4.8613      -2.9840
5.2 2 0	-2.8332  -3.6178      -2.0485
6.2 2 0	-5.3819  -6.3045      -4.4594
7.2 2 0	-5.8580  -6.6818      -5.0343
end 
summarize
label variable nssec "Mother's NS-SEC"
label variable beta "Coefficient"
label variable upper "Upper bound"
label variable lower "Lower bound"
label define nssecl 0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", replace
label values nssec nssecl
label define source 1 "Birth Record" 2 "Survey"
label values source source
label define mum 1 "Mum" 0 "Dad"
label values mum mum
summarize
numlabel, add
tab nssec
tab source
tab mum
set scheme s1mono
graph twoway ///
	(scatter beta nssec if ((mum==1)&(source==1)), ///
	  xlabel(0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", alternate ) ///
	  msymbol(circle) mlcolor(gs0) msize(medium)) ///
	(scatter beta nssec if ((mum==1)&(source==2)), ///
	  xlabel(0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", alternate ) ///
	  msymbol(diamond_hollow) mlcolor(gs0) msize(medium)) ///
	(rspike upper lower nssec if ((mum==1)&(source==1))) ///	  
	 (rspike upper lower nssec if ((mum==1)&(source==2)), ///
	  legend( region(lwidth(none)) order(1 2) label(1 "Birth Record") label(2 "Survey")) ///
	  name(g1, replace))
	  
	  
	  
	
clear
input nssec source mum beta lower upper
clear
input nssec source mum beta lower upper

/*Mother Birth Record*/
0 1	1 1.8966    0.5022       3.2911
1 1	1 2.4916   1.4777       3.5054
2 1 1 0.0000  -0.6009       0.6009
3 1	1 -2.0185  -2.5266      -1.5104
4 1 1 -2.2222   -3.8594      -0.5851 
5 1 1 -1.6457   -5.0624       1.7709 
6 1 1 -5.3852   -6.1992      -4.5712
7 1	1 -6.0586   -7.1195      -4.9977
/*Mother Survey*/
0.2 2 1	1.0851  -0.1289       2.2991
1.2 2 1	1.6637  0.6090       2.7185
2.2	2 1 0.0000 -0.6721       0.6721
3.2 2 1 -2.5209 -2.9757      -2.0661
4.2 2 1 -2.5324 -3.8049      -1.2600
5.2 2 1 -3.1374 -6.1303      -0.1445
6.2 2 1 -5.3579 -6.0772      -4.6387
7.2 2 1 -6.5745  -7.5974      -5.5516
/*Father Birth Record*/
0 1 0  1.2642 0.2901       2.2383
1 1 0 2.2309 1.3051       3.1568
2 1 0  0.0000 -0.6523       0.6523
3 1 0 -0.4728 -1.2586       0.3130
4 1 0  -3.7180 -4.6318      -2.8042
5 1 0  -2.0965 -2.9655      -1.2274
6 1 0  -5.0483 -6.0383      -4.0583
7 1 0  -5.5043 -6.3047      -4.7040
/*Father Survey*/
0.2 2 0	 1.7168  0.7834       2.6503
1.2 2 0	 2.4765  1.4982       3.4547
2.2 2 0	0.0000 -0.6199       0.6199
3.2 2 0	-1.2131  -2.1121      -0.3140
4.2 2 0	-3.9227  -4.8613      -2.9840
5.2 2 0	-2.8332  -3.6178      -2.0485
6.2 2 0	-5.3819  -6.3045      -4.4594
7.2 2 0	-5.8580  -6.6818      -5.0343
end
summarize
label variable nssec "Father's NS-SEC"
label variable beta "Coefficient"
label variable upper "Upper bound"
label variable lower "Lower bound"
label define nssecl 0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", replace
label values nssec nssecl
label define source 1 "Birth Record" 2 "Survey"
label values source source
label define mum 1 "Mum" 0 "Dad"
label values mum mum
summarize
numlabel, add
tab nssec
tab source
tab mum
set scheme s1mono
graph twoway ///
	(scatter beta nssec if ((mum==0)&(source==1)), ///
	  xlabel(0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", alternate) ///
	  msymbol(circle) mlcolor(gs0) msize(medium)) ///
	(scatter beta nssec if ((mum==0)&(source==2)), ///
	  xlabel(0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", alternate) ///
	  msymbol(diamond_hollow) mlcolor(gs0) msize(medium)) ///
	(rspike upper lower nssec if ((mum==0)&(source==1))) ///	  
	 (rspike upper lower nssec if ((mum==0)&(source==2)), ///
	  legend( region(lwidth(none)) order(1 2) label(1 "Birth Record") label(2 "Survey")) ///
	  name(g2, replace))
	  
	  
	  
	  
	  
	  
	  
	  
grc1leg  g1 g2, legendfrom(g1)	///
title("Naming Vocabulary Test Age 5", size(med)) ///
	  subtitle("Log Odds and Quasi-Variance Based 95% Comparison Intervals", size(medsmall))  ///
	  note( "Note: UK Millennium Cohort Study (SN4683 & SN5614). Models also contain gender. Models are" ///
	  "adjusted for survey design. Models are run separately with mothers' and fathers' variables and " ///
	  "include families with valid occupational information available for both the survey and birth" ///
	  "record, n(fathers)=8,522, n(mothers)=7,600.") 
	  







	
	
*Age 11	

clear
input nssec source mum beta lower upper
/*Mother Birth Record*/
0 1	1 1.3097  0.0363       2.5831
1 1	1 2.4809  1.5275       3.4343
2 1 1 0.0000  -0.5797       0.5797
3 1	1 -1.8203 -2.3684      -1.2722
4 1 1  -2.2277 -4.0294      -0.4259
5 1 1 -2.2077 -4.5187       0.1034
6 1 1 -3.9100 -4.7239      -3.0962
7 1	1 -5.3608 -6.3539      -4.3676
/*Mother Survey*/
0.2 2 1 0.6238  -0.6121       1.8597
1.2 2 1 1.8439    0.8463       2.8416
2.2	2 1 0.0000  -0.6434       0.6434
3.2 2 1 -2.3476    -2.8518      -1.8433
4.2 2 1 -2.6944  -4.2755      -1.1132
5.2 2 1 -1.8777  -4.6688       0.9133
6.2 2 1 -3.8369  -4.4746      -3.1993
7.2 2 1 -5.6656  -6.6722      -4.6590
/*Father Birth Record*/
0 1 0 0.7964  -0.2562       1.8490
1 1 0 1.6647  0.8494       2.4801
2 1 0 0.0000 -0.6075       0.6075
3 1 0 -0.2972 -1.1374       0.5430
4 1 0 -2.9584 -3.9460      -1.9708
5 1 0 -2.2785 -3.1966      -1.3604
6 1 0 -3.7190 -4.5596      -2.8784
7 1 0 -4.7927 -5.6189      -3.9665
/*Father Survey*/
0.2 2 0 1.6019    0.6494       2.5544
1.2 2 0 2.0488   1.1964       2.9013
2.2 2 0	0.0000  -0.6686       0.6686
3.2 2 0 -0.7797   -1.6921       0.1327
4.2 2 0 -2.5440   -3.4925      -1.5955
5.2 2 0 -2.1318   -3.0775      -1.1860
6.2 2 0 -4.5017   -5.3920      -3.6113
7.2 2 0 -4.6213   -5.3708      -3.8719
end 	
summarize
label variable nssec "Mother's NS-SEC"
label variable beta "Coefficient"
label variable upper "Upper bound"
label variable lower "Lower bound"
label define nssecl 0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", replace
label values nssec nssecl
label define source 1 "Birth Record" 2 "Survey"
label values source source
label define mum 1 "Mum" 0 "Dad"
label values mum mum
summarize
numlabel, add
tab nssec
tab source
tab mum
set scheme s1mono
graph twoway ///
	(scatter beta nssec if ((mum==1)&(source==1)), ///
	  xlabel(0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", alternate ) ///
	  msymbol(circle) mlcolor(gs0) msize(medium)) ///
	(scatter beta nssec if ((mum==1)&(source==2)), ///
	  xlabel(0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", alternate ) ///
	  msymbol(diamond_hollow) mlcolor(gs0) msize(medium)) ///
	(rspike upper lower nssec if ((mum==1)&(source==1))) ///	  
	 (rspike upper lower nssec if ((mum==1)&(source==2)), ///
	  legend( region(lwidth(none)) order(1 2) label(1 "Birth Record") label(2 "Survey")) ///
	  name(g3, replace))
	
	
	
	
	
clear
input nssec source mum beta lower upper
/*Mother Birth Record*/
0 1	1 1.3097  0.0363       2.5831
1 1	1 2.4809  1.5275       3.4343
2 1 1 0.0000  -0.5797       0.5797
3 1	1 -1.8203 -2.3684      -1.2722
4 1 1  -2.2277 -4.0294      -0.4259
5 1 1 -2.2077 -4.5187       0.1034
6 1 1 -3.9100 -4.7239      -3.0962
7 1	1 -5.3608 -6.3539      -4.3676
/*Mother Survey*/
0.2 2 1 0.6238  -0.6121       1.8597
1.2 2 1 1.8439    0.8463       2.8416
2.2	2 1 0.0000  -0.6434       0.6434
3.2 2 1 -2.3476    -2.8518      -1.8433
4.2 2 1 -2.6944  -4.2755      -1.1132
5.2 2 1 -1.8777  -4.6688       0.9133
6.2 2 1 -3.8369  -4.4746      -3.1993
7.2 2 1 -5.6656  -6.6722      -4.6590
/*Father Birth Record*/
0 1 0 0.7964  -0.2562       1.8490
1 1 0 1.6647  0.8494       2.4801
2 1 0 0.0000 -0.6075       0.6075
3 1 0 -0.2972 -1.1374       0.5430
4 1 0 -2.9584 -3.9460      -1.9708
5 1 0 -2.2785 -3.1966      -1.3604
6 1 0 -3.7190 -4.5596      -2.8784
7 1 0 -4.7927 -5.6189      -3.9665
/*Father Survey*/
0.2 2 0 1.6019    0.6494       2.5544
1.2 2 0 2.0488   1.1964       2.9013
2.2 2 0	0.0000  -0.6686       0.6686
3.2 2 0 -0.7797   -1.6921       0.1327
4.2 2 0 -2.5440   -3.4925      -1.5955
5.2 2 0 -2.1318   -3.0775      -1.1860
6.2 2 0 -4.5017   -5.3920      -3.6113
7.2 2 0 -4.6213   -5.3708      -3.8719
end 	
summarize
label variable nssec "Father's NS-SEC"
label variable beta "Coefficient"
label variable upper "Upper bound"
label variable lower "Lower bound"
label define nssecl 0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", replace
label values nssec nssecl
label define source 1 "Birth Record" 2 "Survey"
label values source source
label define mum 1 "Mum" 0 "Dad"
label values mum mum
summarize
numlabel, add
tab nssec
tab source
tab mum
set scheme s1mono
graph twoway ///
	(scatter beta nssec if ((mum==0)&(source==1)), ///
	  xlabel(0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", alternate ) ///
	  msymbol(circle) mlcolor(gs0) msize(medium)) ///
	(scatter beta nssec if ((mum==0)&(source==2)), ///
	  xlabel(0 "1.1" 1 "1.2" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7", alternate ) ///
	  msymbol(diamond_hollow) mlcolor(gs0) msize(medium)) ///
	(rspike upper lower nssec if ((mum==0)&(source==1))) ///	  
	 (rspike upper lower nssec if ((mum==0)&(source==2)), ///
	  legend( region(lwidth(none)) order(1 2) label(1 "Birth Record") label(2 "Survey")) ///
	  name(g4, replace))
		
		
		
grc1leg g3 g4, legendfrom(g3)	///
title("Verbal Similarities Test Age 11", size(med)) ///
	  subtitle("Log Odds and Quasi-Variance Based 95% Comparison Intervals", size(medsmall)) ///
	  note( "Note: UK Millennium Cohort Study (SN4683 & SN5614). Models also contain gender. Models are" ///
	  "adjusted for survey design. Models are run separately with mothers' and fathers' variables and " ///
	  "include families with valid occupational information available for both the survey and birth" ///
	  "record, n(fathers)=7,614, n(mothers)=6,710.") 
	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
********************************************************************************
********************************************************************************
/* 

Additional Element: Comparing the amount of occupational changes
over time in a similar group of adult males and females

Is the amount of change in occupations between birth registration and 
nine months more than we would expect?


*******Comparison to the British Household Panel Survey

The MCS was in the field over seventeen fieldwork waves

Waves 1-13 of fieldwork took place in England and Wales from June 2001
to July 2002. The alst wave in England and Wales, wave 13, which included
babies born on August 31, was delayed by 4 weeks for operational reasons, 
so this wave contained interviews mostly conducted at ten rather than nine
months for these two countries. 

The last wave in Scotland and Northern Ireland, wave 17, was the extended
sample spanning 7 weeks of births. The latest interview
took place in Northern Ireland on the last but one eligible day, 
January 10th 2003. Fieldwork in Scotland finished before the end of 2002.


Wave 1		DOB 1-28 Sept 2000				Field 11 June - 8 July 2001
Wave 2		DOB 29 Sept - 26 Oct 2000		Field 9 July - 5 Aug 2001
Wave 3		DOB 27 Oct - 23 Nov	2000		Field 6 Aug - 2 Sept 2001
Wave 4		DOB 24 Nov - 21 Dec	2000		Field 3 Sept - 30 Sept 2001
Wave 5		DOB 22 Dec 2000 - 18 Jan 2001	Field 1 Oct - 28 Oct 2001
Wave 6		DOB 19 Jan - 15 Feb 2001		Field 29 Oct - 25 Nov 2001
Wave 7		DOB 16 Feb - 15 March 2001		Field 26 Nov - 23 Dec 2001
Wave 8		DOB 16 March - 12 Apr 2001		Field 14 Dec 2001 - 20 Jan 2002
Wave 9		DOB 13 Apr - 10 May 2001		Field 21 Jan - 17 Feb 2002
Wave 10		DOB 11 May - 7 June 2001		Field 18 Feb - 17 March 2002
Wave 11		DOB 8 June - 5 July 2001		Field 18 March - 14 April 2002
Wave 12		DOB 6 July - 2 Aug 2001			Field 15 April - 12 May 2002
Wave 13		DOB 3 Aug - 30 Aug 2001			Field 13 May - 9 June 2002
Wave 14		DOB 31 Aug - 27 Sept 2001		Field 10 June - 7 July 2002
Wave 15		DOB 28 Sept - 25 Oct 2001		Field 8 July - 4 Aug 2002
Wave 16		DOB 26 Oct - 23 Nov 2001		Field 5 Aug - 22 Sept 2002
Wave 17		DOB 24 Nov 2001 - 11 Jan 2002	Field 23 Sept - Jan 10 2003


British Household Panel Survey

Wave 10 1st September 2000 to 31st May 2001
Wave 11 1st September 2001 to 25th May 2002

*N.B The BHPS uses SOC90 */








********************************************************************************
********************************************************************************


***What is the age of natural mothers and fathers in the sample

use $path1\ARCHIVE\MCS1\stata9_se\mcs1_derived_variables.dta, clear

keep MCSID AMDRES00 AMDAGB00 APDAGB00 APDRES00

rename MCSID mcsid
sort mcsid

numlabel, add

************

*identity of main respondent
tab AMDRES00
*mother = 1 | 15
*father = 2
*identity of partner respondent
tab APDRES00
*mother = 1 | 11 | 15 
*father = 2 | 12 | 16 | 24

***********
*Age of natural mother and father at birth of the cohort member

tab AMDAGB00
tab APDAGB00

*this is a categorical measure - however there are lots of additional numbers
*so will need to recode these separately into the categories

capture drop mumageyrs
gen mumageyrs = .
replace mumageyrs = AMDAGB00 if (AMDRES00==1)|(AMDRES00==15)
replace mumageyrs = APDAGB00 if (APDRES00==1)|(APDRES00==11)|(APDRES00==15)
tab mumageyrs
*2 and 3 must be coding errors so I will get rid of these
recode mumageyrs -1=. -2=. 2=. 3=.
tab mumageyrs, mi

capture drop dadageyrs
gen dadageyrs = .
replace dadageyrs = AMDAGB00 if (AMDRES00==2)
replace dadageyrs = APDAGB00 if (APDRES00==2)|(APDRES00==12)| ///
				(APDRES00==16)|(APDRES00==24)
tab dadageyrs
*2, 3 and 4 must be coding errors so I will get rid of these
recode dadage -1=. -2=. 2=. 3=. 4=.
tab dadage, mi

***********

summ mumageyrs
*mean 28.32 sd 5.96 min 14 max 51

summ dadageyrs
*mean 31.91 sd 6.27 min 15 max 68

**********



*BHPS Wave 10 (J)

use $path1\ARCHIVE\BHPS\UKDA-5151-stata8\stata8\jindresp.dta, clear

keep pid jhgsex jage jjbsoc jdoid jdoim jdoiy4 jlprnt

sort pid

save $path3\BHPSwave10.dta, replace

*BHPS Wave 11 (K)

use $path1\ARCHIVE\BHPS\UKDA-5151-stata8\stata8\kindresp.dta, clear


keep pid khid khgsex kage kjbsoc kjbbgd kjbbgm kjbbgy4 klprnt

sort pid

save $path3\BHPSwave11.dta, replace

*Add these together

use $path3\BHPSwave10.dta, clear
merge 1:1 pid using $path3\BHPSwave11.dta
*14,258 in both datasets
*I'll keep _merge as it may be useful later

save $path3\BHPSwave10and11.dta, replace

***

*get the weights

use $path1\ARCHIVE\BHPS\UKDA-5151-stata8\stata8\khhsamp.dta, clear

keep khid kfid kpsu kstrata kxhwtuk2 kxhwtuk1 

sort khid

save $path3\bhps_kweights.dta, replace



use $path3\BHPSwave10and11.dta, clear
sort khid
capture drop _merge
merge m:m khid using $path3\bhps_kweights.dta
sort _merge
*not matched are those who are not in sweep j or k
drop _merge
sort pid
save $path3\BHPSwave10and11.dta, replace










*Select a sample within 2 standard deviations of the mean

*Mum mean 28 sd 6
*Dad mean 32 sd 6

*Women aged 16 to 40
*Men aged 20 to 44

use $path3\BHPSwave10and11.dta, clear
numlabel, add


svyset kpsu [pweight=kxhwtuk1], strata(kstrata)

tab jjbsoc
tab kjbsoc

mvdecode jjbsoc kjbsoc, mv(-9=. \ -8=.)


*Keep if these is a soc in both waves
keep if (jjbsoc!=.)&(kjbsoc!=.)
tab jjbsoc
tab kjbsoc

tab jhgsex

capture drop match
gen match = 0
replace match = 1 if (jjbsoc==kjbsoc)
label variable match "SOC90 matched in waves 10 and 11"
tab match
*61% match

*Mothers/Women
preserve
keep if (jhgsex==2)
keep if (jage>=16)&(jage<=40)
tab match
restore

*n=1165
*number of matching socs 695 (60%) nonmatching soc (40%)

*Fathers/Men
preserve
keep if (jhgsex==1)
keep if (jage>=20)&(jage<=44)
tab match
restore

*n=1441
*number of matching socs 852 (60%) nonmatching soc (40%)



/*
Longhi and Brynin (2009) Occupational Change in Britain and Germany. 
ISER Working Paper 2009-10

They only count as changes in occupation those which are explicitly associated
with a change of job. 

They find that the correction of measurement error substantially reduces the 
degree of apparent occupational change.

Over 10% of people change their occupation in Britain year on year.

Those who change occupation tend to be relatively poorly matched to their job
(either over or underqualified), compared to those who change job while 
remaining in the same occupation.

*/


******
***Did they also change job?


*Date of last interview

tab jdoid 
tab jdoim 
tab jdoiy4

*Date of wave 10 interview
capture drop intdate
gen intdate = mdy(jdoim, jdoid, jdoiy4)
format intdate %td
tab intdate


/* What was the date you started working in your present position ? 
If you have been promoted or changed grades, please give me the date 
of that change. Otherwise please give me the date when you started doing 
the job you are doing now for your present employer.*/


*Date changed job
capture drop jobdate
gen jobdate = mdy(kjbbgd, kjbbgm, kjbbgy4)
format jobdate %td
tab jobdate
*1868 changed job


*is the change in job after the date of interview

capture drop durationjobchange
gen durationjobchange = jobdate-intdate
tab durationjobchange, mi

*if changejob >= 0 the job change occurred after the last interview
*no change in job and therefore unlikely to be a real change in occupation
capture drop change
gen change = 1
replace change = 0 if ((durationjobchange<0)|(durationjobchange==.))
tab change, mi

tab match
tab change

tab change match , mi col


*Mothers/Women
preserve
keep if (jhgsex==2)
keep if (jage>=16)&(jage<=40)
tab change match , mi col
restore

*n=1165
*number of matching socs  (60%) nonmatching soc (40%)
*6.5% change job and change occupation


preserve
keep if (jhgsex==2)
keep if (jage>=16)&(jage<=40)
svy:tab change match 
restore
*4.39%


preserve
keep if (jhgsex==2)
keep if (jage==28)
tab change match , mi col
restore
*8.33%

preserve
keep if (jhgsex==2)
keep if (jage==28)
svy: tab change match
restore
*5.16%





*Fathers/Men
preserve
keep if (jhgsex==1)
keep if (jage>=20)&(jage<=44)
tab change match , mi col
restore

*n=1441
*number of matching socs 852 (60%) nonmatching soc (40%)
*5.87 change job and change occupation


preserve
keep if (jhgsex==1)
keep if (jage>=20)&(jage<=44)
svy: tab change match 
restore
*3.83%




preserve
keep if (jhgsex==1)
keep if (jage==32)
tab change match , mi col
restore
*5%

preserve
keep if (jhgsex==1)
keep if (jage==32)
svy: tab change match
restore
*2.84%


save $path3\BHPSwave10and11_v2.dta, replace


********************************************************************************


*Do you have, or have you ever had/fathered any children?


use "E:\Data\RAWDATA\ARCHIVE\BHPS\UKDA-5151-stata8\stata8\kegoalt.dta", clear

numlabel, add
tab klwstat

capture drop tag
gen tag = 1 if (klwstat==3)

egen tag2 = max(tag), by(khid)

tab tag2
keep if tag2==1
drop tag2

tab krel
tab klwstat

numlabel, add
tab klwstat

sort khid
capture drop newparent_pid
generate long newparent_pid = 0
replace newparent_pid = pid if (krel == 4)&(klwstat==3)



keep if newparent_pid !=0

duplicates report newparent_pid
*14 duplicates, most likely twins (two new babies in household)
capture drop tag
duplicates tag newparent_pid, gen(tag)
sort tag newparent_pid

egen tag2 = max(kopno), by(khid)
drop if (tag==1)&(tag2!=kopno)


keep newparent_pid  
rename newparent_pid   pid
capture drop newparent
gen newparent = 1

duplicates report pid

sort pid
save $path3\BHPSwaveparents.dta, replace 


use $path3\BHPSwave10and11_v2.dta, clear
duplicates report pid
sort pid 
merge 1:1 pid using $path3\BHPSwaveparents.dta
sort _merge
drop if _merge==2


save $path3\BHPSwaveparents_v2.dta, replace 






use $path3\BHPSwaveparents_v2.dta, clear

svyset kpsu [pweight=kxhwtuk1], strata(kstrata)


tab jhgsex newparent, col

*Mothers/Women
preserve
keep if (jhgsex==2)
keep if (jage>=16)&(jage<=40)
tab change match , mi col
restore
*6.5% change job and change occupation

preserve
keep if (jhgsex==2)
keep if (jage>=16)&(jage<=40)
svy:tab change match 
restore
*4.39%


preserve
keep if (jhgsex==2)
keep if (jage==28)
tab change match , mi col
restore
*8.33%

preserve
keep if (jhgsex==2)
keep if (jage==28)
svy: tab change match
restore
*5.16%

preserve
keep if (jhgsex==2)
keep if (jage>=16)&(jage<=40)
keep if (newparent==1)
tab change match , mi col
restore
*1.64%

preserve
keep if (jhgsex==2)
keep if (jage>=16)&(jage<=40)
keep if (newparent==1)
svy: tab change match
restore
*0.73%




*Fathers/Men
preserve
keep if (jhgsex==1)
keep if (jage>=20)&(jage<=44)
tab change match , mi col
restore
*5.87 change job and change occupation


preserve
keep if (jhgsex==1)
keep if (jage>=20)&(jage<=44)
svy: tab change match 
restore
*3.83%




preserve
keep if (jhgsex==1)
keep if (jage==32)
tab change match , mi col
restore
*5%

preserve
keep if (jhgsex==1)
keep if (jage==32)
svy: tab change match
restore
*2.84%


preserve
keep if (jhgsex==1)
keep if (jage>=20)&(jage<=44)
keep if (newparent==1)
tab change match , mi col
restore
*8.89%

preserve
keep if (jhgsex==1)
keep if (jage>=20)&(jage<=44)
keep if (newparent==1)
svy: tab change match
restore
*8.53%

		
		
		
		
		
		
		
		
		

		
		
		
		
		
		
		
		
		
		
********************************************************************************
********************************************************************************
*EOF
















