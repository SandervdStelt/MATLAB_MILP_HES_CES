% Model of i households equiped with powerwalls ,fixed demands, shiftable demands, grid connenction and a
% PV system. Both grid absorption and injection are possible.

%% Data Input

% Colum(1,2,3,4)=(t,Cost, Pv, Pdem)

Td = 8760;                            % number of hours
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
c = out(1:Td,1,4);                              %costs profile for houses
c(isnan(c)) = 0;                                %filter for NaN's at the end of the year ( the database ends before the years end

realdate = datetime(tdate,'Convertfrom','datenum');%timesteps in datetime notation

%% Boundaries
Pgridmax = 6.5;         % max boundary for grid capacity of each household
Pgridmin = 0;           % min boundary for grid capacity
Obj = 0;

%% Decision variables
Pgridabs =  sdpvar(Td,I,1);       % Absorbed power from grid house i
Pgridinj =  sdpvar(Td,I,1);       % Injected power to grid house i
P=          sdpvar(Td,I,1);       % Power action house i
PgridabsT=  sdpvar(Td,1);         % Absorbed power from the grid by all households
PgridinjT=  sdpvar(Td,1);         % Injected power to the grid by all households
Psl=        sdpvar(Td,I,1);       % Sum of shiftable appliance demands for house i
%% Main Model Constraints
con = [];                         %list of constraints
%% Grid constraints

con = [con, Pgridabs(:,:) <= Pgridmax];

con = [con, Pgridabs(:,:) >= Pgridmin];

con = [con, Pgridinj(:,:) >= Pgridmin];

con = [con, Pgridinj(:,:) <= Pgridmax];

con = [con, PgridinjT(:) >= 0];

con = [con, PgridabsT(:) >= 0];

fprintf('Grid Constraints done.\n' )
%% Local balance
for t= 1:Td
con = [con, Pnsl(t,:)+ Psl(t,:) - P_pv(t,:) == P(t,:)];

con = [con, P(t,:) == (Pgridabs(t,:)- Pgridinj(t,:))];
end
fprintf('Local Balance done.\n' )
%% Global grid constraints
for t= 1:Td
    
con = [con, PgridinjT(t) - PgridabsT(t) == sum(Pgridinj(t,:) - Pgridabs(t,:),2)];

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

fprintf('Starting solver.\n' )
for i = Firsthouse:Lasthouse
for t = 1:Td
Obj = Obj + c(t).*Pgridabs(t,i);
end
end
options = sdpsettings('solver','cplex','verbose',1);
sol = optimize(con,Obj,options);

fprintf('solver ended.\n' )
Mincosts = value(Obj)
%% Additional Results

Costsperhouse1 = value(c'*Pgridabs(:,:));                  % sum of costs made per household over TD
Savingsperhouse1= value(c'*Pgridinj(:,:)); 
netcostsperhouse1 = Costsperhouse1 -Savingsperhouse1;
Ppvperhouse1 = value(sum(P_pv,1));                      % sum of pv generated power over TD
Pgridinjperhouse1 = value(sum(Pgridinj,1));             % sum of gridinjection per household over TD
Pvselfconsumptionperc = 1-(Pgridinjperhouse1./Ppvperhouse1);
Pgridabsperhouse1 = value(sum(Pgridabs,1));             % sum of gridabsorption per household over TD
Pavcosts1= Costsperhouse1./Pgridabsperhouse1;            % average costs of elektricity over TD
Totpowerdem1 = sum(Pnsl,1)+sum(Psl,1);                            % sum of consumed energy per year

%% Workspace display
P = value(P);
Pgridabs = value(Pgridabs);
Pgridinj = value(Pgridinj);
PgridabsT = value(PgridabsT);
PgridinjT = value(PgridinjT);
Psl = value(Psl);
%%
save('PATH') 
clear
    