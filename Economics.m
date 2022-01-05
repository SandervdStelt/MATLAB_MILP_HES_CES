%% Battery Economics

%NOTE: the PV systems were included in the houseprice, therefore no
%seperate investment costs have been assumed for pv. P_pv is assumed to be free
I = 39;
% Parameters
load PATH/Tablematerial_ALL.mat
Euroyear = 2017;            % monetary reference year
Lifet= 10;                  % Lifetime of the system
Discrreal= 0.02;             % Real discount rate
Infl= 0.02;                  % Inflation 
Discrnom= (1+Discrreal)*(1+Infl) - 1;  % Nominal discount rate, accounted for inflation
Pricech= 0.01;              % Expected trend in energy price change in the future
%% Economic performance indicators - Scenario 1_baseline

tlcc2 = zeros(I,Lifet);

for i = 1:I
for yr = 1:Lifet  
tlcc1 = (netcostsperhouse(i,1))./(1+Discrnom).^(yr-1);%Total Life Cycle Costs
tlcc2(i,yr) = tlcc1; 
TLCC1 = sum(tlcc2,2)';
end
end
for i =1:I
for yr = 1:Lifet 
tleu1 = (Totpowerdem(i,1)./((1+Discrnom).^(yr-1)));
tleu2(i,yr) = tleu1;
TLEU1 = sum(tleu2,2)';
LCOE1(1,i) = TLCC1(1,i)./TLEU1(1,i);
end
end

%% Economic performance indicators - Scenario 2_HES_1PW1

I=39;
Lifet =10;
Investment2 = 7000; 
tlcc2 = zeros(I,Lifet);

for i = 1:I
for yr = 1:Lifet  
tlcc1 = (netcostsperhouse(i,2))./(1+Discrnom).^(yr-1);%Total Life Cycle Costs
tlcc2(i,yr) = tlcc1; 
TLCC2 = ((sum(tlcc2,2)) + Investment2)';
end

end
for i =1:I
for yr = 1:Lifet 
tleu1 = (Totpowerdem(i,2)./((1+Discrnom).^(yr-1)));
tleu2(i,yr) = tleu1;
TLEU1 = sum(tleu2,2)';
LCOE2(1,i) = TLCC2(1,i)./TLEU1(1,i);
end
end
for i = 1:I
pbp2(1,i) =   Investment2 ./ (annualsavings(i,2));                       %Pay Back Period
end
%% Economic performance indicators - Scenario 2_HES_1PW2

I=39;
Lifet =10;
Investment2 = 7000; 
tlcc2 = zeros(I,Lifet);

for i = 1:I
for yr = 1:Lifet  
tlcc1 = (netcostsperhouse(i,3))./(1+Discrnom).^(yr-1);%Total Life Cycle Costs
tlcc2(i,yr) = tlcc1; 
TLCC2 = ((sum(tlcc2,2)) + Investment2)';
end

end
for i =1:I
for yr = 1:Lifet 
tleu1 = (Totpowerdem(i,3)./((1+Discrnom).^(yr-1)));
tleu2(i,yr) = tleu1;
TLEU1 = sum(tleu2,2)';
LCOE3(1,i) = TLCC2(1,i)./TLEU1(1,i);
end
end

for i = 1:I
pbp3(1,i) =   Investment2 ./ (annualsavings(i,3));                       %Pay Back Period
end
%% Economic performance indicators - Scenario 3_CES

Investment3 = 200000;
tlcc2 = zeros(I,Lifet);
load 'Relshare.mat'
for i = 1:I
for yr = 1:Lifet  
Investment3(1,i) = Relshare(1,i) .* 200000;
tlcc1 = (netcostsperhouse(i,4))./(1+Discrnom).^(yr-1);%Total Life Cycle Costs
tlcc2(i,yr) = tlcc1; 
TLCC2 = ((sum(tlcc2,2))+ Investment3(1,i))';
end
end

for i =1:I
for yr = 1:Lifet 
tleu1 = (Totpowerdem(i,4)./((1+Discrnom).^(yr-1)));
tleu2(i,yr) = tleu1;
TLEU1 = sum(tleu2,2)';
LCOE4(1,i) = TLCC2(1,i)./TLEU1(1,i);
end
end

for i = 1:I
pbp4(1,i) = Investment3(1,i) ./ (annualsavings(i,4)); %Pay Back Period
end
%% Economic performance indicators - Scenario 3_CES_OPT

Investment4 = 360000;
tlcc2 = zeros(I,Lifet);
load 'Relshare.mat'
for i = 1:I
for yr = 1:Lifet  
Investment4(1,i) = Relshare(1,i) .* 360000;
tlcc1 = (netcostsperhouse(i,5))./(1+Discrnom).^(yr-1);%Total Life Cycle Costs
tlcc2(i,yr) = tlcc1; 
TLCC3 = ((sum(tlcc2,2))+ Investment4(1,i))';
end
end

for i =1:I
for yr = 1:Lifet 
tleu1 = (Totpowerdem(i,5)./((1+Discrnom).^(yr-1)));
tleu2(i,yr) = tleu1;
TLEU1 = sum(tleu2,2)';
LCOE5(1,i) = TLCC3(1,i)./TLEU1(1,i);
end
end

for i = 1:I
pbp5(1,i) = Investment4(1,i) ./ (annualsavings(i,5)); %Pay Back Period
end

%% Save
LCOE = [LCOE1;LCOE2;LCOE3;LCOE4;LCOE5];
LCOEAV = round([mean(LCOE1) mean(LCOE2) mean(LCOE3) mean(LCOE4) mean(LCOE5)],4);
PBP = [pbp2;pbp3;pbp4;pbp5];
PBPAV = round([mean(pbp2) mean(pbp3) mean(pbp4) mean(pbp5)],0)';
Savings = [annualsavings];
SavingsAV = round(mean(annualsavings,2),0);
InvestmentAV = [ 7000; round(mean(Investment3,2),0);round(mean(Investment4,2),0)];
save('PATH','LCOE','PBP','Savings','LCOEAV','PBPAV','SavingsAV','InvestmentAV')
clear