% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model starts running (initFcn callback function).

%% Load the supply and demand data

timeUnit   = 's';

supplyFile = "Team63_supply.csv";
supplyUnit = "MW";

% load the supply data
Supply = loadSupplyData(supplyFile, timeUnit, supplyUnit);

demandFile = "Team63_demand.csv";
demandUnit = "MW";

% load the demand data
Demand = loadDemandData(demandFile, timeUnit, demandUnit);

%% Simulation settings

deltat = 5*unit("min");
stopt  = min([Supply.Timeinfo.End, Demand.Timeinfo.End]);

%% System parameters

% transport from supply
aSupplyTransport = 0.01; % Dissipation coefficient

% injection system
aInjection = 0.1; % Dissipation coefficient

% storage system
EStorageMax     = 10.*unit("kWh"); % Maximum energy
EStorageMin     = 0.0*unit("kWh"); % Minimum energy
EStorageInitial = 4320000.0*unit("kWh"); % Initial energy
bStorage        = 1e-6/unit("s");  % Storage dissipation coefficient

% extraction system
aExtraction = 0.1; % Dissipation coefficient
TurbineEfficiency = 0.40;
    %water tank parameters
    wallThickness = 0.2; %meters
    r_in = 1.5;
    height = 4;
    conductivity = 1;   %W/(m*K), realistic value for concrete.
T_env = 10; %degrees C, average temp in the netherlands
T_water = 90;   %this should be changed to a function in order to reflect the cooling due to heat loss


% transport to demand
aDemandTransport = 0.01; % Dissipation coefficient