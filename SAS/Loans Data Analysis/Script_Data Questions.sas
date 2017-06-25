
/*Q1) What is total default rate?*/

/*Assumptions:*/
/*- Considering the Loan_Status value as Default or Late(31-120) as a definition of defaults.*/
/*- Final result of default rate would be taken out from the combined set of 36 month loans and 60 month loans.*/

/*READ 36 MONTHS TENURE LOANS DATA*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_36; 
sheet="36 MONTHS"; 
run;

/*READ 60 MONTHS TENURE LOANS DATA*/
proc import datafile
="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_60;
sheet="60 MONTHS";
run;

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*ADD NEW VARIABLE DEFAULT TO THE STACKED DATASET INDICATING DEFAULT AS 1 AND REST AS 0*/
data all_loans;
set all_loans;
if loan_status = "Default" then default=1;
else if loan_status="Late (31-120 days)" then default=1;
else default=0;
run;

/*GENERATING FREQUENCY TABLE WITH THE VALUES OF THE VARIABLE default*/
proc freq data=all_loans;
table default;
run;

/***********************************************************************************************************/

/*Q2) Is there a big difference between 3year and 5 year loans default rate.(>3%)*/


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

/*Adding term variable term(3 0R 5) in both data sets*/
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

/*ADDING default VARIABLE TO INDICATE DEFAULT OR NOT*/
data all_loans;
set all_loans;
if loan_status = "Default" then default=1;
else if loan_status="Late (31-120 days)" then default=1;
else default=0;
run;

/*FREQUENCY TABLE GENERATION USING THE LS AND TV VARIABLES*/
proc freq data=all_loans;
table default*term/NOROW  NOPERCENT;
run;

/**********************************************************************************************************/

/*Q3)Most comman reason cited for taking loan.*/
/*We will work on the demo dataset and analyze the variable "purpose"*/

/*READ DEMOGRAPHIC DATA*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=demo ;
sheet="DEMO";
run;

/*USING FREQUENCY PROCEDUCE TO TAKE OUT THE FREQ DISTRIBUTION OF REASON VARIABLE */
proc freq data=demo;
table purpose;
run;

/************************************************************************************************************/

/*Q4) What is the ratio of loan requested to income?*/
/*- We will merge the all loans data set with the demo dataset*/

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

/*READ DEMOGRAPHIC DATA*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=demo ;
sheet="DEMO";
run;

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*INDEXING BOTH THE DATASETS USING THE id VARIABLE */
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

/*CREATE NEW VARIABLE TO TAKE THE REQUIRED RATIO*/
data final;
set final;
amt_per_income = loan_amnt/annual_inc;
run;

/*CALCULATE THE AVERAGE OF RATIO AND STORE IT IN NEW DATASET*/
proc means mean data=final;
output out= ratio_amnt_income
mean( amt_per_income) = ratio_amt_income;
run;

/*******************************************************************************************************/

/*Q5) What is the average grant rate? RATIO OF LOAN REQUESTED AND LOAN FUNDED*/

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

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*ADD VARIABLE TO CALCULATE GRANT RATE*/
data all_loans;
set all_loans;
grant_rate = loan_amnt/funded_amnt;/*It should be funded amt/loan amt*/
run;

/*OUTPUT MEAN VALUE OF GRANT RATE TO A DIFFERENT DATASET*/
proc means mean data=all_loans;
output out = grant_rate
mean(grant_rate)= avg_grant_rate;
run;

/*******************************************************************************************************/

/*Q6) HOW GRANT RATE DIFFERS BY INCOME CATEGORY*/
/*FIRST CREATE INCOME LEVELS*/
/*WE HAVE GENERATED INCOME LEVELS BY REMOVING OUTLIERS FROM INCOME DISTRIBUTION AND HENCE MINIMIZING SKEWNESS*/
/*INCOME LEVELS*/
/*0-42000*/
/*42000-84000*/
/*84000-126000*/
/*126000-168000*/
/*168000-600000*/

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

/*READ DEMOGRAPHIC DATA*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=demo ;
sheet="DEMO";
run;

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*ADD VARIABLE TO CALCULATE GRANT RATE*/
data all_loans;
set all_loans;
grant_rate = loan_amnt/funded_amnt;/*It should be funded amt/loan amt*/
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
length income_level $20.;
if annual_inc le 42000 then income_level = ">42k";
if annual_inc ge 42000 and annual_inc le 84000 then income_level = "42k-84k";
if annual_inc ge 84000 and annual_inc le 126000 then income_level = "84k-126k";
if annual_inc ge 126000 and annual_inc le 168000 then income_level = "126k-168k";
if annual_inc ge 168000 then income_level = ">168k";
run;

/*CREATE FREQUENCY DISTRIBUTION OF INCOME LEVELS WITH MEAN OF GRANT RATE*/
proc tabulate data=final;
class income_level;
var grant_rate;
table income_level,mean*grant_rate;
run;

/*******************************************************************************************************************/

/*Q7) Are there any particular states that are overrepresented in the dataset? Create an index of*/
/*   share relative to population size (Hint: you will need to source population by state in the US*/
/*   from an external source)*/
/*       a. There are loans from most of the US states in the dataset (in the addr_state*/
/*           variable). You should compare the share of loans by state to the share of the state’s*/
/*           population to total US population. Identify if there are any states whose share of*/
/*           loans in this dataset to total loans are much higher than expected based on share of*/
/*           population.*/
/*       b. Data for US state population, for the year 2013 can be found online*/

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

/*CALCULATE RATIO OF LOAN SHARE BY POPULATION SHARE FOR STATES */
data loan_pop;
set loan_pop;
loanbypop= relative_share_loans/relative_share_pop;
run;

/*SORT BY DECREASING VALUE OF RATIO TO OBTRAIN TOP STATES WHO HAVE HIGH LOANS SHARE AND LOW POPULATION SHARE*/
proc sort data=loan_pop;
by descending loanbypop;
run;

/**********************************************************************************************************************/

/*Q8). How important is income verification for granting a loan*/

/*READ 3 YEAR TERM LOAN DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_36;
sheet="36 MONTHS";
run;

/*READ 5 YEAR TERM LOAN DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_60;
sheet="60 MONTHS";
run;

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*ADD NEW VARIABLE LS TO THE STACKED DATASET INDICATING DEFAULT AS 1 AND REST AS 0*/
data all_loans;
set all_loans;
if loan_status = "Default" then default=1;
else if loan_status="Late (31-120 days)" then default=1;
else default=0;
run;

/*MODIFY THE VALUES OF IS_INC_V TO 0 AND 1 */
data all_loans;
set all_loans;
is_inc_v = put(is_inc_v,1.);
if is_inc_v='*' then is_inc_v=1;
is_inc_v = input(is_inc_v,$1.);
run;

/*CHECK ANY REALTIONSHIP BETWEEN INCOME VERIFICFATION AND DEFAULT RATE*/
proc freq data=all_loans;
tables default*is_inc_v/ norow nopercent;
run;

/**********************************************************************************************************/

/*Q9) What is the average interest rate by grade and sub-grade*/

/*READ 3 YEAR TERM LOAN DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_36;
sheet="36 MONTHS";
run;

/*READ 5 YEAR TERM LOAN DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_60;
sheet="60 MONTHS";
run;

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*INDEXING DATASET BY GRADE AND SUB_GRADE*/
proc sort data=all_loans;
by grade sub_grade;
run;

/*AVERAGE INTEREST BY GRADE*/
proc tabulate data=all_loans;
var int_rate;
class grade ;
table grade,int_rate*mean ;
run;

/*AVERAGE INTEREST BY SUB_GRADE*/
proc tabulate data=all_loans;
var int_rate;
class sub_grade grade;
table grade*sub_grade, int_rate*mean ;
run;

/***********************************************************************************************************/

/*10. What is the average time between loan acceptance date and loan issuance date?*/

/*READ 3 YEAR TERM LOAN DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_36;
sheet="36 MONTHS";
run;

/*READ 5 YEAR TERM LOAN DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_60;
sheet="60 MONTHS";
run;

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*ADD A VARIABLE WHICH CALCULATES THE DIFFERENCE BETWEEN DATES IN DAYS*/
data all_loans;
set all_loans;
intcks= intck('day',accept_d,issue_d);
run;

/*STORE MEAN OF DIFFERENCE BETWEEN DATES IN DAYS IN A DIFFERENT DATASET */
proc means data=all_loans;
output out= mean_date_diff
mean(intcks) = mean_datediff;
run;

/*******************************************************************************************************************/

/*11. Are there any customers that loan data is available for but not demographic data? How*/
/*    many? Similarly any customers that demo data is available for but not loan data? Please*/
/*    store these observations in a separate dataset*/

/*READ 3 YEAR TERM LOAN DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_36;
sheet="36 MONTHS";
run;

/*READ 5 YEAR TERM LOAN DATASET*/
proc import datafile="Z:\Assignments\Graded Assignment\Topic 6.3 -  SAS\Loandetails.xlsx"
dbms=excel replace out=months_60;
sheet="60 MONTHS";
run;

/*VERTICAL STACKING*/
data all_loans;
set months_36 months_60;
run;

/*INDEXING BOTH THE DATASETS USING THE id VARIABLE */
proc sort data=all_loans;
by id;
run;
proc sort data=demo;
by id;
run;

/*CHECK IF ANY CUSTOMERS WHO ARE PRESENT IN LOANS DATA BUT NOT IN DEMO DATA*/
data loans_notdemo;
merge all_loans(in=a) demo(in=d);
by id;
if a and not d;
run;

/*CHECK IF ANY CUSTOMERS WHO ARE PRESENT IN DEMO DATA BUT NOT IN LOANS DATA*/
data demo_notloans;
merge all_loans(in=a) demo(in=d);
by id;
if d and not a;
run;
/****************************************************************************************************************/

