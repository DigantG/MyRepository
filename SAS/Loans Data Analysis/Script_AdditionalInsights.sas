

/*READ 36 MONTHS TENURE LOANS DATA*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_36; 
sheet="36 MONTHS"; 
run;

/*READ 60 MONTHS TENURE LOANS DATA*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_60;
sheet="60 MONTHS";
run;

/*Adding term(3 0R 5)*/
data months_36;
set months_36;
term = 3 ;
run;
data months_60;
set months_60;
term = 5 ;
run;

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*ADD DEFAULT */
data all_loans;
set all_loans;
if loan_status = "Default" then default=1;
else if loan_status="Late (31-120 days)" then default=1;
else default=0;
run;


/*ADD GRANT RATE*/
data all_loans;
set all_loans;
grant_rate = loan_amnt/funded_amnt;
run;


/*MODIFY THE VALUES OF IS_INC_V TO 0 AND 1 */
data all_loans;
set all_loans;
is_inc_v = put(is_inc_v,1.);
if is_inc_v='*' then is_inc_v=1;
is_inc_v = input(is_inc_v,$1.);
run;


/*READ DEMOGRAPHIC DATA*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=demo ;
sheet="DEMO";
run;

/*INDEXING BOTH THE DATASETS BY ID VARIABLE */
proc sort data=all_loans;
by id;
run;
proc sort data=demo;
by id;
run;

/*MERGE DATASETS BY ID VARIABLE*/
data final;
merge all_loans demo;
by id;
run;

/*CREATE VARIABLE FOR INCOME LEVELS*/
data final;
set final;
if annual_inc le 42000 then income_level = "   >42k   ";
if annual_inc ge 42000 and annual_inc le 84000 then income_level = "42k-84k";
if annual_inc ge 84000 and annual_inc le 126000 then income_level = "84k-126k";
if annual_inc ge 126000 and annual_inc le 168000 then income_level = "126k-168k";
if annual_inc ge 168000 then income_level = ">168k";
run;


/*CREATE NEW VARIABLE TO TAKE THE REQUIRED RATIO*/
data final;
set final;
amt_per_income = loan_amnt/annual_inc;
run;

/****************************************** INSIGHT-1 *****************************************************/

/*READ DEMOGRAPHIC DATA*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=demo ;
sheet="DEMO";
run;

/*USING FREQUENCY PROCEDUCE TO TAKE OUT THE FREQ DISTRIBUTION OF REASON VARIABLE */
proc freq data=demo;
table purpose;
run;

/******************************************* INSIGHT-2 *****************************************************/

proc tabulate data=final;
class is_inc_v grade;
var grant_rate;
table is_inc_v*mean,grant_rate;

/******************************************* INSIGHT-3 *****************************************************/

proc tabulate data=final;
class emp_length;
var grant_rate;
table emp_length*mean,grant_rate;

/******************************************* INSIGHT-4 *****************************************************/

proc tabulate data=final;
class income_level home_ownership;
var grant_rate;
table income_level*Mean,grant_rate*home_ownership;

/******************************************* INSIGHT-5 *****************************************************/

proc tabulate data=final;
class default ;
var installment;
table default,installment*mean;

/******************************************* INSIGHT-6 *****************************************************/

proc tabulate data=final;
class default home_ownership;
var id;
table default *N,home_ownership;

/******************************************* INSIGHT-7 *****************************************************/



/*READ US POPULATION DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\US Population by State.csv "
out=population  replace dbms=csv;
run;

/*CALCULATE THE TOTAL POPULATION AND STORE IN A DIFFERENT DATASET TO BE USED LATER*/
proc means data=population;
output out = sum_population sum(_2013)=total_population;
run;

/*ATTACH A DUMMY VARIABLE FOR INDEXING TO HELP US MERGE THE DATASETS*/
data sum_population(drop = _FREQ_ _TYPE_);
set sum_population;
index= 1;
run;

data population;
set population;
index=1;
run;

/*INDEXING BASED ON DUMMY VARIABLE OF BOTH THE DATASETS*/
proc sort data=population ;
by index;
run;
proc sort data=sum_population;
by index;
run;

/*MERGE THE DATASETS AND STORE THE REALTIVE SHARE OF POPULATION*/
data population ;
merge population sum_population;
by index;
relative_share_pop = _2013/total_population *100;
run;

/*SORTING THE DATASET TO OBTAIN RELATIVE SHARE OF POPULATION IN DECREASING ORDER*/
proc sort  data=population;
by descending relative_share_pop;
run;

/*READ DEMO DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=demo ; sheet="DEMO";
run;

/*COUNT THE NUMBER OF LOANS BY STATE AND OUTPUT TO A NEW DATASET*/
proc freq data=demo;
table addr_state/out = count_loans ;

/*CHANGING VARIABLE NAMES TO INCREASE READABILITY AND FACILITATE MERGE OPERATIONS*/
data count_loans;
set count_loans;
relative_share_loans=percent;
States=addr_state;

/*INDEXING THE DATASETS BY STATES*/
proc sort data=count_loans(drop=percent count addr_state);
by States;
run;

proc sort data=population;
by States;
run;

/*MERGE OPERATION*/
data loan_pop;
merge population count_loans;
by States;
run;

proc plot data=loan_pop;
plot relative_share_pop * relative_share_loans =states;