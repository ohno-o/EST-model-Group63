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
    t4 = 0.015; %The steel layer

conv_coeff = 15;
steel_emissivity = 0.35;
SB_constant = 5.67 * 10^-8;

%% CALCULATIONS THAT COUDN'T IMPLEMENT INSIDE A SIMULINK BLOCK

%Calculating insulation resistance
A1 = 2*pi*radius_in*height_in + 2*pi*radius_in^2;

r2 = radius_in + t1;
h2 = height_in + 2*t1;
A2 = 2*pi*r2*h2 + 2*pi*r2^2;

r3 = radius_in + t1 + t2;
h3 = height_in + 2*t1 + 2*t2;
A3 = 2*pi*r3*h3 + 2*pi*r3^2;

R1 = t1/k1*A1;
R2 = t2/k2*A2;
R3 = t3/k3*A3;

insulation_resistance = R1 + R2 + R3;

% Calculating outside area
r_total = radius_in + t1 + t2 +t3 + t4;
h_total = height_in + 2*t1 + 2*t2 + 2*t3 + 2*t4;
outside_area = 2*pi*r_total*h_total + 2*pi*r_total^2; 

% Calcualting surface temp.
% Assuming isnside temp is homogeneous and
% considering conduction, convection & radiation.
heat_balance = @(surface_temp)(salt_temp - surface_temp)/insulation_resistance - ...
conv_coeff*outside_area*(surface_temp - env_temp) - ...
steel_emissivity*SB_constant*outside_area*(surface_temp^4 - env_temp^4);

surface_temp_initial = env_temp;  % Initial condition for surface temp

% Solve using fsolve
options = optimoptions('fsolve', 'Display', 'iter');
surface_temp = fsolve(heat_balance, surface_temp_initial, options);
disp(surface_temp);