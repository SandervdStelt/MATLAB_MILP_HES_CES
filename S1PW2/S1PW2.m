% Model of i households equiped with powerwalls ,fixed demands, shiftable demands, grid connenction and a
% PV system. Both grid absorption and injection are possible.

%% Data Input

% Colum(1,2,3,4)=(t,Cost, Pv, Pdem)

Td = 8760;                          % number of hours
FirstHID = 111;                     % firsthouseid used as input
LastHID = 149;                      % lasthouseid used as input
Firsthouse = FirstHID+1-FirstHID;   % shifting firsthouse ID to position 1 (make it readable for matlab)
Lasthouse = LastHID+1-FirstHID;     % same thing
I = (Lasthouse+1-Firsthouse);       % total number of houses
D = (1:(Td/24))';                   % matrix with the number of days [ day1; day2]
d = Td/24;                          % total number of days
t24 = D*24;                         % matrix filled with the last hour of every day (used for SoC constraints)
y = reshape(1:Td,24,d);             % matrix with 24 hours per column ( used in daily shiftable power demand constraint)

% reading data from masterfile.xls
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
Batterysize = 13.5;          % size of battery
Soc0 = 50;                  % initial state of charge
Dt = 1;                     % time step
Cbat = 2;                   % battery capacity
Effd = 0.95;                 % battery efficiency discharge 
Effc = 0.95;                 % battery efficiency charge
Fi = ((100/Batterysize)/Effd);                  % battery coefficient (represents a powerwall 1.0)
Obj = 0;


%% Boundaries

Socmin = 25;            % min boundary for SoC %
Socmax = 90;            % max boundary for SoC %

Pbatdmax = 5;         % max boundary for battery discharge capacity
Pbatcmax = 5;           % max boundary for battery charge capacity
Pgridmax = 6.5;           % max boundary for grid capacity of each household

Pbatdmin = 0;           % min boundary for battery discharge capacity
Pbatcmin = 0;           % min boundary for battery charge capacity
Pgridmin = 0;           % min boundary for grid capacity

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

%% Main Model Constraints
con = [];
%% State of charge 
con = [con, Soc(1,:) == Soc0 - (((Fi/Effd))*Pbatd(1,:) - (Fi*Effc)*Pbatc(1,:))];
for t = 2:Td
con = [con, Soc(t,:) == Soc(t-1,:) - (((Fi/Effd))*Pbatd(t,:) - (Fi*Effc)*Pbatc(t,:))];    
end
for t = 1:Td
con = [con, Socmin <= Soc(t,:) <= Socmax];

con = [con, Soc(t24,:) == Soc0];            %ensures state of charge is equal to SoC0 every 24 hours
end

fprintf('SoC done.\n' )
%% Battery Balance

con = [con, Pbatd(:,:) >= Pbatdmin];

con = [con, Pbatd(:,:) <= Pbatdmax];

con = [con, Pbatc(:,:) >= Pbatcmin];

con = [con, Pbatc(:,:) <= Pbatcmax];

fprintf('BB done.\n' )
%% Grid constraints

con = [con, Pgridabs(:,:) <= Pgridmax];

con = [con, Pgridabs(:,:) >= Pgridmin];

con = [con, Pgridinj(:,:) >= Pgridmin];

con = [con, Pgridinj(:,:) <= Pgridmax];

con = [con, PgridinjT(:) >= 0];

con = [con, PgridabsT(:) >= 0];

fprintf('Grid Constraints done.\n' )
%% Grid balance
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
for i = Firsthouse:Lasthouse
Obj = Obj + ((c(t).*Pgridabs(t,i)));
end
end

fprintf('End Solver.\n' )
options = sdpsettings('solver','cplex','verbose',1);
sol = optimize(con,Obj,options);


Mincosts = value(Obj)
%% data display

P = value(P);
Pgridabs = value(Pgridabs);
Pgridinj = value(Pgridinj);
PgridabsT = value(PgridabsT);
PgridinjT = value(PgridinjT);
Pbatc = value(Pbatc);
Pbatd = value(Pbatd);

Psl = value(Psl);
Soc = value(Soc);
%% Additional Results
      
Costsperhouse2 = value(c'*Pgridabs);                  % sum of costs made per household over TD
Savingsperhouse2= value(c'*Pgridinj); 
netcostsperhouse2 = value(Costsperhouse2 -Savingsperhouse2);
Ppvperhouse2 = value(sum(P_pv,1));                      % sum of pv generated power over TD
Pbatdperhouse2 = value(sum(Pbatd,1));                           % Total battery discharge energy over TD
Pbatcperhouse2 = value(sum(Pbatc,1));                           % Total battery charge energy over TD
Pgridinjperhouse2 = value(sum(Pgridinj,1));                     % Total grid injected energy over TD
Pgridabsperhouse2 = value(sum(Pgridabs,1));             % sum of gridabsorption per household over TD
Pavcosts2 = value(Costsperhouse2./Pgridabsperhouse2);           % average costs of elektricity over TD
Totpowerdem2 = value(sum(Pnsl,1) + sum(Psl,1));                 % sum of consumed energy per year



%% Monthlycosts

monthlycosts2 = zeros(12,I);
monthshours = month(realdate);
for m = 1:12
    for i = 1:I
months= find(monthshours == m);
% monthly costs per household
montlyc = sum((c(months,1).*Pgridabs(months,i)),1);
monthlycosts2(m,i) = montlyc;

% monthly savings per household
months= find(monthshours == m);
montlys = sum((c(months,1).*Pgridinj(months,i)),1);
monthlysaving2(m,i) = montlys;
    end
end


save('PATH') 

    