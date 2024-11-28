% Alcoholism Dynamics Model Analysis
% -----------------------------------
% This script models the dynamics of alcoholism in a population with
% compartments for moderate drinkers (S), heavy drinkers (D), treatment (T),
% and recovered (R). The script also includes sensitivity analysis and 
% visualization of results.
%
% Author: Tharun Raj D, Yogesh Kumar R V
% Date: 27.11.2024

%% SECTION 1: Parameter Definitions and Initial Conditions
% --------------------------------------------------------

% Define primary parameters for the model
Lambda = 2.44e6;  % Recruitment rate into the population
mu = 0.005;       % Natural death rate
delta1 = 0.01;    % Alcohol-related death rate for heavy drinkers
delta2 = 0.008;   % Alcohol-related death rate during treatment
beta1 = 0.148;    % Transition rate from moderate to heavy drinking
alpha = 0.25;     % Social influence parameter
gamma = 93.4;     % Transition rate to treatment
sigma = 0.02;     % Recovery rate from treatment
eta = 0.015;      % Relapse rate from recovered to moderate drinking

% Initial conditions for the compartments
% Small perturbation near the Disease-Free Equilibrium (DFE)
initial_conditions = [Lambda/mu, 1, 0, 0];  % [S, D, T, R]

% Define time span for simulation
tspan = [0, 200];  % Time range in months

%% SECTION 2: Define the ODE System
% --------------------------------------------------------

% The alcoholism model as a system of ODEs
alcoholism_model = @(t, y) [
    Lambda - beta1 * y(1) * (1 + alpha * y(2) / sum(y)) - mu * y(1) + eta * y(4); % dS/dt
    beta1 * y(1) * (1 + alpha * y(2) / sum(y)) - (mu + delta1 + gamma) * y(2);   % dD/dt
    gamma * y(2) - (mu + delta2 + sigma) * y(3);                                 % dT/dt
    sigma * y(3) - (mu + eta) * y(4)                                             % dR/dt
];

%% SECTION 3: Solve the ODE System
% --------------------------------------------------------

% Solve the ODEs using MATLABs ode45 solver
[t, y] = ode45(alcoholism_model, tspan, initial_conditions);

%% SECTION 4: Visualize Results
% --------------------------------------------------------

% Extract compartment values for plotting
S = y(:, 1);  % Moderate drinkers
D = y(:, 2);  % Heavy drinkers
T = y(:, 3);  % Treatment
R = y(:, 4);  % Recovered

% Create a plot of the dynamics
figure;
plot(t, S, 'b-', 'LineWidth', 2); hold on;
plot(t, D, 'r-', 'LineWidth', 2);
plot(t, T, 'g-', 'LineWidth', 2);
plot(t, R, 'k-', 'LineWidth', 2);
xlabel('Time (Months)');
ylabel('Population');
title('Alcoholism Population Dynamics Near DFE');
legend({'Moderate Drinkers (S)', 'Heavy Drinkers (D)', 'Treatment (T)', 'Recovered (R)'});
grid on;
hold off;

%% SECTION 5: Sensitivity Analysis
% --------------------------------------------------------

% Parameters to vary for sensitivity analysis
sensitivity_params = {'beta1', 'gamma', 'sigma', 'alpha'};  % Parameters to vary
variations = [-0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3];         % ±30% variation

% Store sensitivity results
sensitivity_results = struct();

for p = 1:length(sensitivity_params)
    param_name = sensitivity_params{p};
    base_value = eval(param_name);  % Get the base value of the parameter
    sensitivity_results.(param_name) = struct('Dmax', [], 'Rend', []);
    
    for v = 1:length(variations)
        % Adjust parameter value
        eval([param_name ' = base_value * (1 + variations(v));']);
        
        % Solve ODE system with the adjusted parameter
        [t, y] = ode45(alcoholism_model, tspan, initial_conditions);
        
        % Calculate metrics
        Dmax = max(y(:, 2));  % Peak heavy drinkers
        Rend = y(end, 4);     % Final recovered
        
        % Store results
        sensitivity_results.(param_name).Dmax(end+1) = Dmax;
        sensitivity_results.(param_name).Rend(end+1) = Rend;
    end
    
    % Reset parameter to its base value
    eval([param_name ' = base_value;']);
end

%% SECTION 6: Sensitivity Analysis Plots
% --------------------------------------------------------

% Plot sensitivity results for each parameter
variations_percent = variations * 100;  % Convert to percentage change

figure;
subplot(2, 1, 1);
for p = 1:length(sensitivity_params)
    param_name = sensitivity_params{p};
    plot(variations_percent, sensitivity_results.(param_name).Dmax, '-o', 'LineWidth', 2); hold on;
end
title('Sensitivity of Peak Heavy Drinkers to Parameter Variations');
xlabel('Parameter Variation (%)');
ylabel('Peak Heavy Drinkers');
legend(sensitivity_params, 'Location', 'best');
grid on;

subplot(2, 1, 2);
for p = 1:length(sensitivity_params)
    param_name = sensitivity_params{p};
    plot(variations_percent, sensitivity_results.(param_name).Rend, '-o', 'LineWidth', 2); hold on;
end
title('Sensitivity of Final Recovered to Parameter Variations');
xlabel('Parameter Variation (%)');
ylabel('Final Recovered Population');
legend(sensitivity_params, 'Location', 'best');
grid on;
