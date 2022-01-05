% Model of i households equiped with CES ,fixed demands, shiftable demands, grid connenction and a
% PV system. Both grid absorption and injection are possible.

%% Data Input

% Colum(1,2,3,4)=(t,Cost, Pv, Pdem)

Td = 8760;                           % number of hours
FirstHID = 111;                     % firsthouseid used as input
LastHID = 149;                      % lasthouseid used as input
Firsthouse = FirstHID+1-FirstHID;   % shifting firsthouse ID to position 1 (make it readable for matlab)
Lasthouse = LastHID+1-FirstHID;     % same thing
I = (Lasthouse+1-Firsthouse);       % total number of houses
D = (1:(Td/24))';                   % matrix with the number of days [ day1; day2]
d = Td/24;                          % total number of days
t24 = D*24;                         % matrix filled with the last hour of every day (used for SoC constraints)
y= reshape(1:Td,24,d);              % matrix with 24 hours per column ( used in daily shiftable power demand constraint)

% reading data from masterfile.xl
load out.mat


tdate = out(1:Td,1,1);                          %timesteps in numerical notation
tdate = datetime(tdate,'Convertfrom','datenum');%timesteps in datetime notation
P_pv = out(1:Td,1:I,2);                           %PV profile for house i
P_pv(isnan(P_pv)) = 0;                          %filter for NaN's at the end of the year ( the database ends before the years end
Pnsl= out(1:Td,1:I,3);                            %non shiftable load profile for house i
Pnsl(isnan(Pnsl)) = 0;                          %filter for NaN's at the end of the year ( the database ends before the years end
c = out(1:Td,1,4);                              %costs profile for house i
c(isnan(c)) = 0;                                %filter for NaN's at the end of the year ( the database ends before the years end
realdate = datetime(tdate,'Convertfrom','datenum');%timesteps in datetime notation
%% 
%Battery Specs
Batterysize = 200;          % kWh
Soc0 = 50;                  % initial state of charge
Dt = 1;                     % time step
Cbat = 2;                   % battery capacity
Effd = 0.95;                 % battery efficiency discharge 
Effc = 0.95;                 % battery efficiency charge
Obj = 0;
Investment = 210000;        % investment costs for CES 200 kWh/ 225 kW (source: ATEPS)
Fitot = ((100/Batterysize)/Effd);       %Fi of total battery

%Battery share per household
Sharegridinj = importdata('Relshare.mat');
Sharegridinj = Sharegridinj(1,1:I);
Reqbattcap = [200];
Batteryshare= value(Sharegridinj.* Reqbattcap);              %in kWh, based on share of grid inj
Fi = (100./Batteryshare)./Effd;                  % battery coefficient based on the battery share
Battsurplus = Batterysize - Reqbattcap;

%% Boundaries

Socmin = 25;            % min boundary for SoC %
Socmax = 90;            % max boundary for SoC %

Pbatdmax = 200 .*(Sharegridinj);         % max boundary for battery discharge capacity for each house
Pbatcmax = 200 .*(Sharegridinj);         % max boundary for battery charge capacity for each house
Pgridmax = 6.5;           % max boundary for grid capacity of each household

Pbatdmin = 0;           % min boundary for battery discharge capacity
Pbatcmin = 0;           % min boundary for battery charge capacity
Pgridmin = 0;           % min boundary for grid capacity

% 225 is the total cap (kW) of the battery, will constrain the households
% to their cumulative share of the charge/discharge cap

PbatdTmax = 200;        % max boundary for battery discharge capacity total
PbatcTmax = 200;        % max boundary for battery charge capacity total

%% Decision variables

Pbatd =     sdpvar(Td,I,1);       % Battery discharge power for house i
Pbatc =     sdpvar(Td,I,1);       % Battery charge power for house i
Pgridabs =  sdpvar(Td,I,1);       % Absorbed power from grid for house i
Pgridinj =  sdpvar(Td,I,1);       % Injected power to grid for house i
Soc =       sdpvar(Td,I,1);       % State of charge for house i
Psl=        sdpvar(Td,I,1);       % Sum of shiftable appliance demands for house i
P=          sdpvar(Td,I,1);       % Power action for house i
PgridabsT=  sdpvar(Td,1);         % Absorbed power from the grid by all households
PgridinjT=  sdpvar(Td,1);         % Injected power to the grid by all households
PbatcT=     sdpvar(Td,1);         % CES battery charge
PbatdT=     sdpvar(Td,1);         % CES battery discharge
%% Main Model Constraints
con = [];
%% State of charge
%calculate the state of charge for each individual battery share  
con = [con, Soc(1,:) == Soc0 - ((Fi(1,:)./Effd).*Pbatd(1,:) - Fi(1,:).*Effc.*Pbatc(1,:))];
for t = 2:Td
con = [con, Soc(t,:) == Soc(t-1,:) - ((Fi(1,:)./Effd).*Pbatd(t,:) - (Fi(1,:).*Effc).*Pbatc(t,:))];    
end
for t = 1:Td
con = [con, Socmin <= Soc(t,:) <= Socmax];
end
con = [con, Soc(t24,:) == Soc0];            %ensures state of charge is equal to SoC0 every 24 hours


% SoC Global balance constraint?

fprintf('SoC done.\n' )
%% Battery constraints
for t = 1:Td
con = [con, Pbatdmin <= Pbatd(t,:) <= Pbatdmax(1,:)];

con = [con, Pbatcmin <= Pbatc(t,:) <= Pbatcmax(1,:)];
end
con = [con, 0 <= PbatcT(:) <=PbatcTmax];

con = [con, 0 <= PbatdT(:) <=PbatdTmax];

fprintf('Bc done.\n' )
%% Battery Balance
for t = 1:Td
con = [con, PbatcT(t) - PbatdT(t) == sum(Pbatc(t,:) - Pbatd(t,:))];
end
fprintf('BB done.\n' )
%% Grid constraints
for t = 1:Td
con = [con, Pgridabs(t,:) <= Pgridmax];

con = [con, Pgridabs(t,:) >= Pgridmin];

con = [con, Pgridinj(t,:) >= Pgridmin];

con = [con, Pgridinj(t,:) <= Pgridmax];

con = [con, PgridinjT(t) >= 0];

con = [con, PgridabsT(t) >= 0];
end

fprintf('Grid Constraints done.\n' )
%% Grid Balance
for t= 1:Td
con = [con, PgridinjT(t)- PgridabsT(t) == sum(Pgridinj(t,:) - Pgridabs(t,:))];
end
fprintf('GB done.\n' )
%% Local balance
for t = 1:Td
con = [con, Pnsl(t,:) + Psl(t,:) - P_pv(t,:) == P(t,:)];

con = [con, P(t,:) == (Pgridabs(t,:)- Pgridinj(t,:)) + (Pbatd(t,:) - Pbatc(t,:))];
end

fprintf('LB done.\n' )
%% Global balance
for t = 1:Td
con = [con, sum(-(Pgridabs(t,:)-Pgridinj(t,:))-(Pbatd(t,:)-Pbatc(t,:))) == PgridinjT(t)- PgridabsT(t) + PbatcT(t) - PbatdT(t)];
end

fprintf('GB done.\n' )
%% Shiftable appliances
% Order of appliances is Dishwasher Washingmachine
N = 1;                            % Number of appliances
Totdem = [1.34];             % Total daily demand in Kwh of both apliances
Peakpower = 1.295;                % peak power for sum of both appliances
minup = [2];                    % minimal operation time of application

% Min/max values
Psdemmin = [0.67];            % minimum power supply of both appliances
Psdemmax = [0.67];            % maximum power supply of both appliances
onoff = binvar(Td,I);        % Binary variable representing onoff status of appliance


% Daily power demand
for i = Firsthouse:Lasthouse
for x = 1:d
con = [con, sum(Psl(y(:,x),i)) == Totdem];       %constraint which ensures the daily demand is ensured every 24 hours
end
end

% Power assignment boundaries
for i = Firsthouse:Lasthouse
for t = 1:Td
con = [con, onoff(t,i) .* Psdemmin <= Psl(t,i) <=  onoff(t,i) .* Psdemmax];
end
end

% Uninteruptible operations
for t = 2:Td
for i = Firsthouse:Lasthouse
    indicator = onoff(t,i) - onoff(t-1,i);  % Indicator 'ind' will be 1 when an appliances switches on
    range = t:min(Td,t+minup-1);            % gives range of timeslots, starting at t, where application must be on (onoff=1)
    con = [con, onoff(range,i) >= indicator];  % This constraint is only active when ind=1, for all other values it is redundant
end
end
fprintf('SA done.\n' )

%% Objective function
fprintf('Start Solver.\n' )

for t = 1:Td
    for i = 1:I
Obj = Obj + ((c(t).*Pgridabs(t,i)));
    end
end

options = sdpsettings('solver','cplex','verbose',1);
sol = optimize(con,Obj,options);
fprintf('End Solver.\n' )
Mincosts = value(Obj)


%% Workspace display

P = value(P);
Pgridabs = value(Pgridabs);
Pgridinj = value(Pgridinj);
PgridabsT = value(PgridabsT);
PgridinjT = value(PgridinjT);
Pbatc = value(Pbatc);
Pbatd = value(Pbatd);
Psl = value(Psl);
Soc = value(Soc);
PbatdT = value(PbatdT);
PbatcT = value(PbatcT);

%% Additional results
     
Costsperhouse3 = value(c'*Pgridabs);                  % sum of costs made per household over TD
Savingsperhouse3= value(c'*Pgridinj); 
netcostsperhouse3 = Costsperhouse3 -Savingsperhouse3;
Ppvperhouse3 = value(sum(P_pv,1));                      % sum of pv generated power over TD
Pbatdperhouse3 = value(sum(Pbatd,1));                           % Total battery discharge energy over TD
Pbatcperhouse3 = value(sum(Pbatc,1));                           % Total battery charge energy over TD
Pgridinjperhouse3 = value(sum(Pgridinj,1));                     % Total grid injected energy over TD
Pgridabsperhouse3 = value(sum(Pgridabs,1));             % sum of gridabsorption per household over TD
Pavcosts3 = value(Costsperhouse3./Pgridabsperhouse3);             % average costs of elektricity over TD
Totpowerdem3 = value(sum(Pnsl,1) + sum(Psl,1));                  % sum of consumed energy per year


%% Monthlycosts

monthlycosts3 = zeros(12,I);
monthshours = month(realdate);
for m = 1:12
    for i = 1:I
months= find(monthshours == m);
% monthly costs per household
montlyc = sum((c(months,1).*Pgridabs(months,i)),1);
monthlycosts3(m,i) = montlyc;

% monthly savings per household
months= find(monthshours == m);
montlys = sum((c(months,1).*Pgridinj(months,i)),1);
monthlysaving3(m,i) = montlys;
    end
end

save('PATH')    
clear