% main.m - Compare swarm algorithms on CEC2022 functions
clc;
clear;
close all;

%% Basic settings
nPop     = 30;    % population size
Max_iter = 500;     % max iterations
dim      = 20;    % dimension (e.g., 2/10/20/...)

% Select CEC2022 benchmark function index
Function_name = 9;  % in [1..12]
[lb, ub, dim, fobj] = Get_Functions_cec2022(Function_name, dim);

% Number of repeated runs to compute averages
numRuns = 30;

%% Algorithms to compare: {function_handle, display_name}
algorithms = { ...
    @WOA,   "WOA"; ...
    @HHO,   "HHO"; ...
    @GOOSE, "GOOSE"; ...
    @AOO,   "AOO"; ...
    @DAOA,  "DAOA"; ...
    @PPAHO, "PPAHO"; ...
    @OCSSA, "OCSSA"; ...
    %@SCA,  "SCA"; ...
    @ALO,   "ALO"; ...
    @BA,    "BA"; ...
    @GSA,   "GSA"; ...
};

numAlgos = size(algorithms, 1);

%% Pre-allocate results
Optimal_results = struct();
for i = 1:numAlgos
    Optimal_results(i).Algorithm     = algorithms{i,2};
    Optimal_results(i).BestScores    = zeros(1, numRuns);       % best fitness per run
    Optimal_results(i).Convergence   = zeros(numRuns, Max_iter);% convergence curve per run
    Optimal_results(i).RunTime       = zeros(1, numRuns);       % runtime per run
end

%% Run all algorithms and record results
for i = 1:numAlgos
    algoFunc = algorithms{i,1};
    algoName = algorithms{i,2};
    fprintf('Running %s ...\n', algoName);
    
    for runIdx = 1:numRuns
    rng('shuffle');  % randomize seed
        tic;
        
    % run selected algorithm
        [bestScore, bestPos, convCurve] = algoFunc(nPop, Max_iter, lb, ub, dim, fobj);
        
        runTime = toc;
        
    % store
        Optimal_results(i).BestScores(runIdx)    = bestScore;
        % normalize convCurve length to Max_iter (crop/pad) and ensure row vector
        curve = convCurve(:)';
        if numel(curve) < Max_iter
            if ~isempty(curve)
                curve = [curve, repmat(curve(end), 1, Max_iter - numel(curve))];
            else
                curve = zeros(1, Max_iter);
            end
        elseif numel(curve) > Max_iter
            curve = curve(1:Max_iter);
        end
        Optimal_results(i).Convergence(runIdx,:) = curve;
        Optimal_results(i).RunTime(runIdx)       = runTime;
    end
    
    % aggregate stats
    Optimal_results(i).AvgBestScore = mean(Optimal_results(i).BestScores);
    Optimal_results(i).MinBestScore = min(Optimal_results(i).BestScores);
    Optimal_results(i).StdBestScore = std(Optimal_results(i).BestScores);
    
    % average convergence across runs
    Optimal_results(i).AvgConvergence = mean(Optimal_results(i).Convergence, 1);
    
    % average runtime
    Optimal_results(i).AvgTime = mean(Optimal_results(i).RunTime);
end

%% Print summary table
fprintf('\n===== Summary (Function F%d, Dim %d, Iters %d, Pop %d) =====\n', ...
        Function_name, dim, Max_iter, nPop);
fprintf('%-10s %-20s %-20s %-15s\n', 'Algorithm', 'AvgBest', 'Best(min)', 'AvgTime(s)');
for i = 1:numAlgos
    algName = Optimal_results(i).Algorithm;
    avgBS   = Optimal_results(i).AvgBestScore;
    minBS   = Optimal_results(i).MinBestScore;
    avgT    = Optimal_results(i).AvgTime;
    fprintf('%-10s %-20.3e %-20.3e %-15.3f\n', ...
            algName, avgBS, minBS, avgT);
end

%% Plot averaged convergence curves
figure('Color', [1 1 1], 'Position', [500, 500, 600, 500]);
colors  = lines(numAlgos);
markers = {'o','s','d','^','v','>','<','p','x','h','+'};

% use log-scale for most functions except specific ones
useLog = true;
if any(Function_name == [9,11,16])
    useLog = false;
end

hold on;
for i = 1:numAlgos
    avgCurve = Optimal_results(i).AvgConvergence;
    if useLog
        semilogy(1:Max_iter, avgCurve, ...
            'Color', colors(i,:), ...
            'Marker', markers{i}, ...
            'MarkerIndices', 1:100:Max_iter, ...
            'LineWidth', 1.5);
    else
        plot(1:Max_iter, avgCurve, ...
            'Color', colors(i,:), ...
            'Marker', markers{i}, ...
            'MarkerIndices', 1:100:Max_iter, ...
            'LineWidth', 1.5);
    end
end
grid on;
title(sprintf('F%d Convergence (Dim=%d)', Function_name, dim), 'FontSize', 16);
xlabel('Iteration', 'FontSize', 16);
ylabel('Fitness Value', 'FontSize', 16);

legend({Optimal_results.Algorithm}, 'Location', 'bestoutside', 'FontSize', 14);

% done

hold off;

%% Save if needed
% save(sprintf('F%d_dim%d_results.mat', Function_name, dim), 'Optimal_results');
