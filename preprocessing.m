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
EStorageMax     = 4320000.0*unit("kWh"); % Maximum energy
EStorageMin     = 0.0*unit("kWh"); % Minimum energy
EStorageInitial = 4320000.0*unit("kWh"); % Initial energy

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


% Storage parameters
no_tanks = 2;
tank_volume = 10000;
radius_in = 11.7;
height_in = 23.4;
salt_temp = 838;  % in kelvin
env_temp = 293;  % in kelvin

    % Insulation made of 3 layers
    k1 = 1.2;
    k2 = 0.14;
    k3 = 0.12;

    t1 = 0.1;
    t2 = 0.15;
    t3 = 0.05;
    t4 = 0.015;

conv_coeff = 15;
steel_emissivity = 0.35;
SB_constant = 5.67 * 10^-8;
