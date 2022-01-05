%% SCENARIO 1
clear
a =load('Baseline_1.mat');
b =load('Baseline_2.mat');
c =load('Baseline_3.mat');
d =load('Baseline_4.mat');

S.P_pv = [a.P_pv b.P_pv c.P_pv d.P_pv];
S.Pnsl = [a.Pnsl b.Pnsl c.Pnsl d.Pnsl];
S.P = [a.P b.P c.P d.P];
S.Pgridabs = [a.Pgridabs b.Pgridabs c.Pgridabs d.Pgridabs];
S.Pgridinj = [a.Pgridinj b.Pgridinj c.Pgridinj d.Pgridinj];
S.PgridabsT = sum(S.Pgridabs,2);
S.PgridinjT = sum(S.Pgridinj,2);
S.Psl = [a.Psl b.Psl c.Psl d.Psl];
S.Pnsl = [a.Pnsl b.Pnsl c.Pnsl d.Pnsl];
S.c = [a.c];
S.realdate = [a.realdate];
S.y = [a.y b.y c.y d.y];

S.Costsperhouse1 = S.c'*S.Pgridabs(:,:);
S.Savingsperhouse1= S.c'*S.Pgridinj(:,:); 
S.netcostsperhouse1 = S.Costsperhouse1 -S.Savingsperhouse1;
S.Ppvperhouse1 = sum(S.P_pv,1);                      % sum of pv generated power over TD
S.Pgridinjperhouse1 = sum(S.Pgridinj,1);             % sum of gridinjection per household over TD
S.Pvselfconsumptionperc1 = 1-(S.Pgridinjperhouse1./S.Ppvperhouse1);
S.Pgridabsperhouse1 = sum(S.Pgridabs,1);             % sum of gridabsorption per household over TD
S.Pavcosts1= S.Costsperhouse1./S.Pgridabsperhouse1;            % average costs of elektricity over TD
S.Totpowerdem1 = sum(S.Pnsl,1)+ sum(S.Psl,1);                            % sum of consumed energy per year
I=39;
monthlycosts1 = zeros(12,I);
monthlysaving1 = zeros(12,I);
monthshours = month(S.realdate);
for m = 1:12
    for i = 1:I
months= find(monthshours == m);
% monthly costs per household
montlyc = sum((S.c(months,1).*S.Pgridabs(months,i)),1);
monthlycosts1(m,i) = montlyc;

% monthly savings per household
months= find(monthshours == m);
montlys = sum((S.c(months,1).*S.Pgridinj(months,i)),1);
monthlysaving1(m,i) = montlys;
    end
end

S.monthlycosts1 = mean(monthlycosts1,2);
S.monthlysavings1 = mean(monthlysaving1,2);
S.netmonthly1 = S.monthlycosts1 - S.monthlysavings1;

save('PATH/Baseline_1_COMPLETE','-struct','S');
clear
%% SCENARIO 2

a =load('S1PW1_1.mat');
b =load('S1PW1_2.mat');
c =load('S1PW1_3.mat');
d =load('S1PW1_4.mat');

S.P_pv = [a.P_pv b.P_pv c.P_pv d.P_pv];
S.Pnsl = [a.Pnsl b.Pnsl c.Pnsl d.Pnsl];
S.P = [a.P b.P c.P d.P];
S.Pgridabs = [a.Pgridabs b.Pgridabs c.Pgridabs d.Pgridabs];
S.Pgridinj = [a.Pgridinj b.Pgridinj c.Pgridinj d.Pgridinj];
S.PgridabsT = sum(S.Pgridabs,2);
S.PgridinjT = sum(S.Pgridinj,2);
S.Psl = [a.Psl b.Psl c.Psl d.Psl];
S.Pbatc = [a.Pbatc b.Pbatc c.Pbatc d.Pbatc];
S.Pbatd = [a.Pbatd b.Pbatd c.Pbatd d.Pbatd];
S.PbatcT = sum(S.Pbatc,2);
S.PbatdT = sum(S.Pbatd,2);
S.Soc = [a.Soc b.Soc c.Soc d.Soc];
S.c = [a.c];
S.realdate = [a.realdate];

S.Costsperhouse2 = S.c'*S.Pgridabs;                  % sum of costs made per household over TD 
S.Savingsperhouse2 = zeros(1,39);
S.netcostsperhouse2 = S.Costsperhouse2 - S.Savingsperhouse2;
S.Ppvperhouse2 = sum(S.P_pv,1);                      % sum of pv generated power over TD
S.Pbatdperhouse2 = sum(S.Pbatd,1);                           % Total battery discharge energy over TD
S.Pbatcperhouse2 = sum(S.Pbatc,1);                           % Total battery charge energy over TD
S.Pgridinjperhouse2 = sum(S.Pgridinj,1);                     % Total grid injected energy over TD
S.Pgridabsperhouse2 = sum(S.Pgridabs,1);             % sum of gridabsorption per household over TD
S.Pavcosts2 = S.Costsperhouse2./S.Pgridabsperhouse2;           % average costs of elektricity over TD
S.Totpowerdem2 = sum(S.Pnsl,1) + sum(S.Psl,1);                 % sum of consumed energy per year
S.Pvselfconsumptionperc2 = 1-(S.Pgridinjperhouse2./S.Ppvperhouse2);

I=39;
monthlycosts2 = zeros(12,I);
monthlysaving2 = zeros(12,I);
monthshours = month(S.realdate);
for m = 1:12
    for i = 1:I
months= find(monthshours == m);
% monthly costs per household
montlyc = sum((S.c(months,1).*S.Pgridabs(months,i)),1);
monthlycosts2(m,i) = montlyc;

% monthly savings per household
months= find(monthshours == m);
montlys = sum((0.*S.Pgridinj(months,i)),1);
monthlysaving2(m,i) = montlys;
    end
end

S.monthlycosts2 = mean(monthlycosts2,2);
S.monthlysavings2 = mean(monthlysaving2,2);
S.netmonthly2 = S.monthlycosts2 - S.monthlysavings2;

save('PATH/S1PW1_COMPLETE','-struct','S');
clear

%% SCENARIO 3
a =load('S2CES_1.mat');
b =load('S2CES_2.mat');
c =load('S2CES_3.mat');
d =load('S2CES_4.mat');

S.P_pv = [a.P_pv b.P_pv c.P_pv d.P_pv];
S.Pnsl = [a.Pnsl b.Pnsl c.Pnsl d.Pnsl];
S.P = [a.P b.P c.P d.P];
S.Pgridabs = [a.Pgridabs b.Pgridabs c.Pgridabs d.Pgridabs];
S.Pgridinj = [a.Pgridinj b.Pgridinj c.Pgridinj d.Pgridinj];
S.PgridabsT = sum(S.Pgridabs,2);
S.PgridinjT = sum(S.Pgridinj,2);
S.Psl = [a.Psl b.Psl c.Psl d.Psl];
S.Pbatc = [a.Pbatc b.Pbatc c.Pbatc d.Pbatc];
S.Pbatd = [a.Pbatd b.Pbatd c.Pbatd d.Pbatd];
S.PbatcT = sum(S.Pbatc,2);
S.PbatdT = sum(S.Pbatd,2);
S.Soc = [a.Soc b.Soc c.Soc d.Soc];
S.c = [a.c];
S.realdate = [a.realdate];


S.Costsperhouse3 = S.c'*S.Pgridabs;                  % sum of costs made per household over TD
S.Savingsperhouse3 = zeros(1,39);
S.netcostsperhouse3 = S.Costsperhouse3 - S.Savingsperhouse3;
S.Ppvperhouse3 = sum(S.P_pv,1);                      % sum of pv generated power over TD
S.Pbatdperhouse3 = sum(S.Pbatd,1);                           % Total battery discharge energy over TD
S.Pbatcperhouse3 = sum(S.Pbatc,1);                           % Total battery charge energy over TD
S.Pgridinjperhouse3 = sum(S.Pgridinj,1);                     % Total grid injected energy over TD
S.Pgridabsperhouse3 = sum(S.Pgridabs,1);             % sum of gridabsorption per household over TD
S.Pavcosts3 = S.Costsperhouse3./S.Pgridabsperhouse3;             % average costs of elektricity over TD
S.Totpowerdem3 = sum(S.Pnsl,1) + sum(S.Psl,1);                  % sum of consumed energy per year
S.Pvselfconsumptionperc3 = 1-(S.Pgridinjperhouse3./S.Ppvperhouse3);

I=39;
monthlycosts3 = zeros(12,I);
monthlysaving3 = zeros(12,I);
monthshours = month(S.realdate);
for m = 1:12
    for i = 1:I
months= find(monthshours == m);
% monthly costs per household
montlyc = sum((S.c(months,1).*S.Pgridabs(months,i)),1);
monthlycosts3(m,i) = montlyc;

% monthly savings per household
months= find(monthshours == m);
montlys = sum((0.*S.Pgridinj(months,i)),1);
monthlysaving3(m,i) = montlys;
    end
end

S.monthlycosts3 = mean(monthlycosts3,2);
S.monthlysavings3 = mean(monthlysaving3,2);
S.netmonthly3 = S.monthlycosts3 - S.monthlysavings3;

save('PATH/S2CES_COMPLETE','-struct','S');
clear
