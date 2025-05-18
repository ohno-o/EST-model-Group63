% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model starts running (initFcn callback function).

%% LOAD THE SUPPLY AND DEMAND DATA

timeUnit   = 's';

supplyFile = "Team63_supply.csv";
supplyUnit = "MW";

% load the supply data
Supply = loadSupplyData(supplyFile, timeUnit, supplyUnit);

demandFile = "Team63_demand.csv";
demandUnit = "MW";

% load the demand data
Demand = loadDemandData(demandFile, timeUnit, demandUnit);

%% SIMULATION SETTINGS

deltat = 5*unit("min");
stopt  = min([Supply.Timeinfo.End, Demand.Timeinfo.End]);

%% SYSTEM PARAMETERS

% Transport from supply
aSupplyTransport = 0.059; % Dissipation coefficient

% Injection system
aInjection = 0.1; % Dissipation coefficient

% Storage system
EStorageMax     = 4320000.0*unit("kWh"); % Maximum energy
EStorageMin     = 0.0*unit("kWh"); % Minimum energy
EStorageInitial = 4320000.0*unit("kWh"); % Initial energy

no_tanks = 2;
radius_in = 11.7; % Inner radius of the tank
height_in = 23.4; % Inner height of the tank
salt_temp = 838; % in kelvin
env_temp = 293; % in kelvin

    % Insulation made of 3 contributing layers.
    % Conductivity coefficients:
    k1 = 1.2; % High−alumina refractory
    k2 = 0.14; % Ceramic fiber blanket
    k3 = 0.008; % VIP layer

    %All layers thickness:
    t1 = 0.1; % H−Al ref
    t2 = 0.15; % CFB
    t3 = 0.015; % St layer
    t4 = 0.025; % VIP layer
    t5 = 0.002; % Al cladding

conv_coeff = 20;
aluminum_emissivity = 0.3;
SB_constant = 5.67 * 10^-8;

% Extraction system

    % Entropy values of Rankine cycle in [kJ/kg]
    entrop1 = 3445; 
    entrop2 = 2100; 
    entrop3 = 151; 
    entrop4 = 153; 

% Transport to demand
aDemandTransport = 0.118; % Dissipation coefficient

%% CALCULATIONS THAT COUDN'T IMPLEMENT INSIDE A SIMULINK BLOCK

%Calculating insulation resistance
A1 = 2*pi*radius_in*height_in + 2*pi*radius_in^2; %Area of refractory

r2 = radius_in + t1;
h2 = height_in + 2*t1;
A2 = 2*pi*r2*h2 + 2*pi*r2^2; %Area of CFB

r3 = radius_in + t1 + t2 + t3;
h3 = height_in + 2*t1 + 2*t2 + 2*t3;
A3 = 2*pi*r3*h3 + 2*pi*r3^2; %Area of VIP layer

Res1 = t1/(k1*A1); %resistance of alumina refractory
Res2 = t2/(k2*A2); %resistance of ceramic fiber blanket
Res3 = t3/(k3*A3); %VIP layer resistance

insulation_resistance = Res1 + Res2 + Res3;

% Calculating outside area
r_total = radius_in + t1 + t2 +t3 + t4 + t5;
h_total = height_in + 2*t1 + 2*t2 + 2*t3 + 2*t4 + 2*t5;
outside_area = 2*pi*r_total*h_total + 2*pi*r_total^2;

% Calcualting surface temp.
% Assuming isnside temp is homogeneous and
% considering conduction, convection & radiation.
heat_balance = @(surface_temp)(salt_temp - surface_temp)/insulation_resistance - ...
conv_coeff*outside_area*(surface_temp - env_temp) - ...
aluminum_emissivity*SB_constant*outside_area*(surface_temp^4 - env_temp^4);

surface_temp_initial = 0.5*(salt_temp + env_temp);  % Initial condition for surface temp

% Solve using fsolve
surface_temp = fsolve(heat_balance, surface_temp_initial);

