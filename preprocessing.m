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

deltat = 15*unit("min");
stopt  = min([Supply.Timeinfo.End, Demand.Timeinfo.End]);

%% SYSTEM PARAMETERS

% Transport from supply
aSupplyTransport = 0.059; % Dissipation coefficient
                          
% Injection system
aInjection = 0.003; % Range: 0.003-0.015 

% Storage system
EStorageMax     = 4320000.0*unit("kWh"); % Maximum energy
EStorageMin     = 0.0*unit("kWh"); % Minimum energy
EStorageInitial = 0.0*unit("kWh"); % Initial energy

no_tanks = 2; % Number of storage tanks
radius_in = 11.7; % Inner radius of the tank
height_in = 23.4; % Inner height of the tank
salt_temp = 838; % in kelvin
env_temp = 284; % in kelvin

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
    t5 = 0.003; % Al cladding

conv_coeff = 20; % Range: 10-20
aluminum_emissivity = 0.2; % Range: 0.09-0.3
SB_constant = 5.67 * 10^-8;

% Extraction system

    % Enthalpy values for ideal Rankine cycle in [kJ/kg]
    enth1 = 151; 
    enth2 = 155; 
    enth3 = 3501; 
    enth4 = 2015; 

pump_eff = 0.9;
turbine_eff = 0.88;
heatexch_eff = 0.91;

% Transport to demand
aDemandTransport = 0.0964; % Dissipation coefficient

%% CALCULATIONS THAT COUDN'T IMPLEMENT INSIDE A SIMULINK BLOCK

%Calculating insulation resistance
A1 = 2*pi*radius_in*height_in + 2*pi*radius_in^2; %Area of refractory

r2 = radius_in + t1;
h2 = height_in + 2*t1;
A2 = 2*pi*r2*h2 + 2*pi*r2^2; %Area of CFB

r3 = radius_in + t1 + t2 + t3;
h3 = height_in + 2*t1 + 2*t2 + 2*t3;
A3 = 2*pi*r3*h3 + 2*pi*r3^2; %Area of VIP layer

Res1 = t1/(k1*A1); % Resistance of alumina refractory
Res2 = t2/(k2*A2); % Resistance of ceramic fiber blanket
Res3 = t4/(k3*A3); % VIP layer resistance

insulation_resistance = Res1 + Res2 + Res3;

% Calculating outside area
r_total = radius_in + t1 + t2 +t3 + t4 + t5;
h_total = height_in + 2*t1 + 2*t2 + 2*t3 + 2*t4 + 2*t5;
outside_area = 2*pi*r_total*h_total + 2*pi*r_total^2;

% Calculating surface temp
heat_balance = @(surface_temp)(salt_temp - surface_temp)/insulation_resistance - ...
conv_coeff*outside_area*(surface_temp - env_temp) - ...
aluminum_emissivity*SB_constant*outside_area*(surface_temp^4 - env_temp^4);

surface_temp_initial = 0.5*(salt_temp + env_temp);  % Initial guess for surface temp

% Solve equation using fsolve
surface_temp = fsolve(heat_balance, surface_temp_initial);

