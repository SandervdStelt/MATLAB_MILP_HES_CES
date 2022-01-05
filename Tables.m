a =load('PATH/Baseline_COMPLETE.mat');
b =load('PATH/S1PW1_COMPLETE.mat');
c =load('PATH/S1PW2_COMPLETE.mat');
d =load('PATH/S2CES_COMPLETE.mat');
e =load('PATH/S2CESOPT_COMPLETE.mat');


S.Costsperhouse = [a.Costsperhouse1 ; b.Costsperhouse2 ; c.Costsperhouse2; d.Costsperhouse3; e.Costsperhouse3]';
S.Savingsperhouse = [a.Savingsperhouse1 ; b.Savingsperhouse2 ; c.Savingsperhouse2; d.Savingsperhouse3; e.Savingsperhouse3]';
S.netcostsperhouse = [a.netcostsperhouse1 ; b.netcostsperhouse2 ; c.netcostsperhouse2 ;d.netcostsperhouse3 ;e.netcostsperhouse3]';
S.Pavcosts = [a.Pavcosts1 ; b.Pavcosts2 ;c.Pavcosts2 ; d.Pavcosts3; e.Pavcosts3]';
S.Pbatcperhouse = [zeros(1,39) ; b.Pbatcperhouse2 ; c.Pbatcperhouse2 ; d.Pbatcperhouse3; e.Pbatcperhouse3]';
S.Pbatdperhouse = [zeros(1,39) ; b.Pbatdperhouse2 ; c.Pbatdperhouse2 ; d.Pbatdperhouse3; e.Pbatdperhouse3]';
S.Pgridabsperhouse = [a.Pgridabsperhouse1 ; b.Pgridabsperhouse2 ; c.Pgridabsperhouse2 ; d.Pgridabsperhouse3; e.Pgridabsperhouse3]';
S.Pgridinjperhouse = [a.Pgridinjperhouse1 ; b.Pgridinjperhouse2 ; c.Pgridinjperhouse2 ; d.Pgridinjperhouse3; e.Pgridinjperhouse3]';
S.Ppvperhouse = [a.Ppvperhouse1 ; b.Ppvperhouse2 ; c.Ppvperhouse2; d.Ppvperhouse3; e.Ppvperhouse3]';
S.Pvselfconsumptionperc = [a.Pvselfconsumptionperc1 ; b.Pvselfconsumptionperc2; c.Pvselfconsumptionperc2 ; d.Pvselfconsumptionperc3; e.Pvselfconsumptionperc3]';
S.Totpowerdem = [a.Totpowerdem1 ; b.Totpowerdem2 ; c.Totpowerdem2; d.Totpowerdem3; e.Totpowerdem3]';
S.annualsavings = [zeros(1,39); a.Costsperhouse1 - b.netcostsperhouse2; a.Costsperhouse1 - c.netcostsperhouse2; a.Costsperhouse1 - d.netcostsperhouse3; a.Costsperhouse1 - e.netcostsperhouse3]';
S.netmonthly = [a.netmonthly1  b.netmonthly2 c.netmonthly2 d.netmonthly3 e.netmonthly3];
S.monthlycosts = [a.monthlycosts1  b.monthlycosts2  c.monthlycosts2  d.monthlycosts3 e.monthlycosts3];
S.monthlysaving = [a.monthlysavings1  b.monthlysavings2 c.monthlysavings2 d.monthlysavings3 e.monthlysavings3];

%Yearly distric averages per scenario
S.averages = [round(mean(S.Costsperhouse,2),0)'
 round(mean(S.annualsavings,2),0)'
 round(mean(S.netcostsperhouse,2),0)'
 round(mean(S.Pavcosts,2),2)'
 round(mean(S.Pbatcperhouse,2),0)'
 round(mean(S.Pbatdperhouse,2),0)'
 round(mean(S.Pgridabsperhouse,2),0)'
 round(mean(S.Pgridinjperhouse,2),0)'
 round(mean(S.Ppvperhouse,2),0)'
 round(mean(S.Pvselfconsumptionperc,2),2)'
 round(mean(S.Totpowerdem,2),0)'];

save('PATH/Tablematerial_ALL','-struct','S');
clear