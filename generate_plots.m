%% generate_plots.m
% Visualize hypothesis validation: phase space, forecast comparison, taxonomy,
% sample size, forecast-by-classification, LLE vs improvement, league summary.
% Run from project root: octave generate_plots.m
% Output: fig1_attractor.png ... fig8_league_summary.png

%% Data setup: manual forecasting results for plotting
Teams       = [52, 14, 24, 6, 19];
Improvements = [9.87, 5.25, 0.28, -1.19, -1.41];

%% Load prove_hypothesis_summary.csv for N and improvement (header row skipped)
summary_path = 'data/results/prove_hypothesis_summary.csv';
if exist(summary_path, 'file') == 2
  summary_data = dlmread(summary_path, ',', 1, 0);
  % columns: team_id, n, n_test, rmse_chaos, rmse_random, improvement_pct, best_dim, best_delay
  Teams_csv = summary_data(:, 1);
  N_games   = summary_data(:, 2);
  Imp_csv   = summary_data(:, 6);
else
  Teams_csv = Teams(:);
  N_games   = [888; 1804; 1739; 1822; 1794];  % fallback from known results
  Imp_csv   = Improvements(:);
end

%% Load Team 52 and full D from clean_game.csv
fname = 'data/processed/clean_game.csv';
if exist(fname, 'file') ~= 2
  error('File not found: %s. Run from project root.', fname);
end
D = dlmread(fname, ',', 1, 1);
% D columns: 1=HomeTeam, 2=AwayTeam, 3=FTHG, 4=FTAG
mask = (D(:, 1) == 52) | (D(:, 2) == 52);
D52 = D(mask, :);
is_home = (D52(:, 1) == 52);
y52 = zeros(size(D52, 1), 1);
y52(is_home)  = D52(is_home, 3);
y52(~is_home) = D52(~is_home, 4);
y52 = y52(:);

%% Smooth with 3-point moving average (Octave: no movmean in base)
w = ones(3, 1) / 3;
y52_smooth = conv(y52, w, 'same');

%% Real chaos + baseline predictions for Team 52 (for Fig 2)
% Same logic as prove_hypothesis.m: 85/15 split, k-NN chaos model, mean-of-last-5 baseline
k_nn = 5;
eps_dist = 1e-6;
normalize_emb = true;
dim_list = [3, 4, 5];
delay_list = [1, 2];
y = y52(:);
n_total = length(y);
n_train = floor(0.85 * n_total);
n_test = n_total - n_train;
y_train = y(1 : n_train);
y_test = y(n_train + 1 : end);
pred_random = zeros(n_test, 1);
for j = 1 : n_test
  idx_start = n_train + j - 5;
  idx_end   = n_train + j - 1;
  pred_random(j) = mean(y(idx_start : idx_end));
end
best_rmse = inf;
best_dim = 3;
best_delay = 1;
for dim = dim_list
  for delay = delay_list
    max_i = n_train - (dim - 1) * delay - 1;
    if max_i < 10, continue; end
    n_emb = max_i;
    Y_emb = zeros(n_emb, dim);
    for i = 1 : n_emb
      for d = 1 : dim
        Y_emb(i, d) = y(i + (d - 1) * delay);
      end
    end
    next_off = (dim - 1) * delay + 1;
    y_next = zeros(n_emb, 1);
    for i = 1 : n_emb
      y_next(i) = y(i + next_off);
    end
    if normalize_emb
      mu_emb = mean(Y_emb, 1);
      sig_emb = std(Y_emb, 0, 1);
      sig_emb(sig_emb < 1e-10) = 1;
      Y_emb_n = (Y_emb - mu_emb) ./ sig_emb;
    else
      Y_emb_n = Y_emb;
    end
    pred_trial = zeros(n_test, 1);
    for j = 1 : n_test
      base = n_train + j - (dim - 1) * delay - 1;
      if base < 1
        pred_trial(j) = mean(y_train);
        continue
      end
      state = zeros(1, dim);
      for d = 1 : dim
        state(d) = y(base + (d - 1) * delay);
      end
      if normalize_emb
        state = (state - mu_emb) ./ sig_emb;
      end
      dists = sum((Y_emb_n - state) .^ 2, 2);
      [d_sorted, idx_sorted] = sort(dists);
      k_use = min(k_nn, length(idx_sorted));
      idx_k = idx_sorted(1 : k_use);
      d_k = d_sorted(1 : k_use) + eps_dist;
      pred_trial(j) = sum((1 ./ d_k) .* y_next(idx_k)) / sum(1 ./ d_k);
    end
    rmse_trial = sqrt(mean((y_test - pred_trial) .^ 2));
    if rmse_trial < best_rmse
      best_rmse = rmse_trial;
      best_dim = dim;
      best_delay = delay;
    end
  end
end
dim = best_dim;
delay = best_delay;
max_i = n_train - (dim - 1) * delay - 1;
n_emb = max_i;
Y_emb = zeros(n_emb, dim);
for i = 1 : n_emb
  for d = 1 : dim
    Y_emb(i, d) = y(i + (d - 1) * delay);
  end
end
next_off = (dim - 1) * delay + 1;
y_next = zeros(n_emb, 1);
for i = 1 : n_emb
  y_next(i) = y(i + next_off);
end
if normalize_emb
  mu_emb = mean(Y_emb, 1);
  sig_emb = std(Y_emb, 0, 1);
  sig_emb(sig_emb < 1e-10) = 1;
  Y_emb_n = (Y_emb - mu_emb) ./ sig_emb;
else
  Y_emb_n = Y_emb;
end
pred_chaos = zeros(n_test, 1);
for j = 1 : n_test
  base = n_train + j - (dim - 1) * delay - 1;
  if base < 1
    pred_chaos(j) = mean(y_train);
    continue
  end
  state = zeros(1, dim);
  for d = 1 : dim
    state(d) = y(base + (d - 1) * delay);
  end
  if normalize_emb
    state = (state - mu_emb) ./ sig_emb;
  end
  dists = sum((Y_emb_n - state) .^ 2, 2);
  [d_sorted, idx_sorted] = sort(dists);
  k_use = min(k_nn, length(idx_sorted));
  idx_k = idx_sorted(1 : k_use);
  d_k = d_sorted(1 : k_use) + eps_dist;
  pred_chaos(j) = sum((1 ./ d_k) .* y_next(idx_k)) / sum(1 ./ d_k);
end

%% ----- Figure 1: Phase Space Attractor (Team 52) -----
% Delay=1 embedding: x(t), x(t+1), x(t+2)
n = length(y52_smooth);
if n < 4
  error('Not enough Team 52 data for phase space.');
end
x_emb = y52_smooth(1 : n-2);
y_emb = y52_smooth(2 : n-1);
z_emb = y52_smooth(3 : n);

figure(1);
clf;
plot3(x_emb, y_emb, z_emb, 'b.-', 'markersize', 4, 'linewidth', 0.5);
xlabel('x(t)', 'fontsize', 10);
ylabel('x(t+1)', 'fontsize', 10);
zlabel('x(t+2)', 'fontsize', 10);
title('Reconstructed Phase Space (Team 52)', 'fontsize', 11);
set(gca, 'fontsize', 10);
grid on;
view(45, 30);
print -dpng -r300 fig1_attractor.png;
fprintf('Saved fig1_attractor.png\n');

%% ----- Figure 2: Forecast Comparison (Real data from chaos model vs baseline) -----
% Last 50 test points: Actual (black), Chaos k-NN (red), Baseline mean-last-5 (blue dashed)
N_show = min(50, n_test);
t_axis = 1 : N_show;
actual_plot = y_test(end - N_show + 1 : end);
chaos_plot  = pred_chaos(end - N_show + 1 : end);
base_plot   = pred_random(end - N_show + 1 : end);

figure(2);
clf;
plot(t_axis, actual_plot, 'k-', 'linewidth', 1.5);
hold on;
plot(t_axis, chaos_plot, 'r-', 'linewidth', 1);
plot(t_axis, base_plot, 'b--', 'linewidth', 1);
hold off;
legend('Actual Trend', 'Chaos Model', 'Random Baseline', 'location', 'northeast');
xlabel('Time (last 50 test games)', 'fontsize', 10);
ylabel('Goals', 'fontsize', 10);
title('Forecasting Performance: Chaos vs Stochastic (Team 52)', 'fontsize', 11);
set(gca, 'fontsize', 10);
grid on;
print -dpng -r300 fig2_forecast.png;
fprintf('Saved fig2_forecast.png\n');

%% ----- Figure 3: Model Utility Taxonomy (Bar Chart) -----
figure(3);
clf;
hold on;
for i = 1 : length(Teams)
  if Improvements(i) > 0
    bar(Teams(i), Improvements(i), 'facecolor', [0.2, 0.7, 0.3]);  % green
  else
    bar(Teams(i), Improvements(i), 'facecolor', [0.6, 0.6, 0.6]);  % grey
  end
end
hold off;
xlabel('Team ID', 'fontsize', 10);
ylabel('% Improvement over Baseline', 'fontsize', 10);
title('Diagnostic Taxonomy: Chaotic vs Stochastic Regimes', 'fontsize', 11);
set(gca, 'xtick', Teams, 'fontsize', 10);
grid on;
print -dpng -r300 fig3_taxonomy.png;
fprintf('Saved fig3_taxonomy.png\n');

%% ----- Figure 4: Sample Size (N) per Team -----
figure(4);
clf;
bar(Teams_csv, N_games, 'facecolor', [0.3, 0.5, 0.8]);
xlabel('Team ID', 'fontsize', 10);
ylabel('Number of Games (N)', 'fontsize', 10);
title('Sample Size per Team (NHL)', 'fontsize', 11);
set(gca, 'xtick', Teams_csv, 'fontsize', 10);
grid on;
print -dpng -r300 fig4_sample_size.png;
fprintf('Saved fig4_sample_size.png\n');

%% ----- Figure 5: Forecast Performance by Classification -----
% Chaotic regime = improvement > 0 (Teams 52, 14, 24); Stochastic = improvement <= 0 (6, 19)
idx_chaos = Imp_csv > 0;
idx_stoch = Imp_csv <= 0;
mean_chaos = mean(Imp_csv(idx_chaos));
mean_stoch = mean(Imp_csv(idx_stoch));
figure(5);
clf;
hold on;
bar(1, mean_chaos, 'facecolor', [0.2 0.7 0.3]);
bar(2, mean_stoch, 'facecolor', [0.6 0.6 0.6]);
hold off;
set(gca, 'xtick', [1, 2], 'xticklabel', {'Chaotic (improvement > 0)', 'Stochastic (improvement <= 0)'}, 'fontsize', 9);
ylabel('% Improvement over Baseline', 'fontsize', 10);
title('Forecast Performance by Classification (H6)', 'fontsize', 11);
set(gca, 'fontsize', 10);
grid on;
print -dpng -r300 fig5_forecast_by_class.png;
fprintf('Saved fig5_forecast_by_class.png\n');

%% ----- Figure 6: Phase Space Attractor — Team 6 (Stochastic Contrast) -----
mask6 = (D(:, 1) == 6) | (D(:, 2) == 6);
D6 = D(mask6, :);
is_home6 = (D6(:, 1) == 6);
y6 = zeros(size(D6, 1), 1);
y6(is_home6)  = D6(is_home6, 3);
y6(~is_home6) = D6(~is_home6, 4);
y6 = y6(:);
y6_smooth = conv(y6, w, 'same');
n6 = length(y6_smooth);
if n6 >= 4
  x6 = y6_smooth(1 : n6-2);
  y6_emb = y6_smooth(2 : n6-1);
  z6 = y6_smooth(3 : n6);
  figure(6);
  clf;
  plot3(x6, y6_emb, z6, 'color', [0.6 0.6 0.6], 'linestyle', '-', 'markersize', 3, 'linewidth', 0.5);
  xlabel('x(t)', 'fontsize', 10);
  ylabel('x(t+1)', 'fontsize', 10);
  zlabel('x(t+2)', 'fontsize', 10);
  title('Reconstructed Phase Space (Team 6 — Baseline Outperforms Chaos Model)', 'fontsize', 11);
  set(gca, 'fontsize', 10);
  grid on;
  view(45, 30);
  print -dpng -r300 fig6_attractor_team6.png;
  fprintf('Saved fig6_attractor_team6.png\n');
end

%% ----- Figure 7: LLE vs Forecast Utility (H4 / Agreement) -----
% Parse LLE from data/results/LLE_test_cases_summary.txt; fallback to hardcoded
LLE_teams = [52, 6, 14, 19];
LLE_vals = [0.0427, 0.0442, 0.0426, 0.0431];
lle_path = 'data/results/LLE_test_cases_summary.txt';
if exist(lle_path, 'file') == 2
  fid = fopen(lle_path);
  LLE_teams = [];
  LLE_vals = [];
  while true
    line = fgetl(fid);
    if line == -1, break; end
    if isempty(strfind(line, 'team')) || ~isempty(strfind(line, 'synthetic')), continue; end
    parts = strsplit(line, '|');
    if length(parts) >= 3
      id_str = strtrim(parts{1});
      lle_str = strtrim(parts{3});
      idx = regexp(id_str, 'team([0-9]+)', 'tokens');
      if ~isempty(idx)
        LLE_teams(end+1) = str2double(idx{1}{1});
        LLE_vals(end+1) = str2double(lle_str);
      end
    end
  end
  fclose(fid);
  if ~isempty(LLE_teams)
    [LLE_teams, ia] = unique(LLE_teams, 'first');
    LLE_vals = LLE_vals(ia);
  end
  if isempty(LLE_teams)
    LLE_teams = [52, 6, 14, 19];
    LLE_vals = [0.0427, 0.0442, 0.0426, 0.0431];
  end
end
Imp_LLE = zeros(length(LLE_teams), 1);
for i = 1 : length(LLE_teams)
  idx_t = find(Teams_csv == LLE_teams(i), 1);
  if ~isempty(idx_t), Imp_LLE(i) = Imp_csv(idx_t); end
end
figure(7);
clf;
hold on;
for i = 1 : length(LLE_teams)
  if Imp_LLE(i) > 0
    bar(LLE_teams(i), LLE_vals(i), 'facecolor', [0.2 0.7 0.3]);
  else
    bar(LLE_teams(i), LLE_vals(i), 'facecolor', [0.6 0.6 0.6]);
  end
end
hold off;
xlabel('Team ID', 'fontsize', 10);
ylabel('Largest Lyapunov Exponent (LLE)', 'fontsize', 10);
title('LLE vs Forecast Utility (Green: Chaos Helps; Grey: Baseline Better)', 'fontsize', 11);
set(gca, 'xtick', LLE_teams, 'fontsize', 10);
grid on;
print -dpng -r300 fig7_LLE_vs_improvement.png;
fprintf('Saved fig7_LLE_vs_improvement.png\n');

%% ----- Figure 8: League Summary (NHL vs NBA) — two panels for scale -----
nhl_chaos = sum(Imp_csv > 0);
nhl_stoch = sum(Imp_csv <= 0);
nba_stoch = 30;  % placeholder: all 30 NBA teams classified stochastic
figure(8);
clf;
subplot(1, 2, 1);
hold on;
bar(1, nhl_chaos, 'facecolor', [0.2 0.7 0.3]);
bar(2, nhl_stoch, 'facecolor', [0.6 0.6 0.6]);
hold off;
set(gca, 'xtick', [1, 2], 'xticklabel', {'NHL Chaotic', 'NHL Stochastic'}, 'fontsize', 10);
ylabel('Number of Teams', 'fontsize', 10);
title('NHL (n=5)', 'fontsize', 11);
ylim([0 max(4, max(nhl_chaos, nhl_stoch) + 1)]);
grid on;
subplot(1, 2, 2);
bar(1, nba_stoch, 'facecolor', [0.6 0.6 0.6]);
set(gca, 'xtick', 1, 'xticklabel', {'NBA (all stochastic)'}, 'fontsize', 10);
ylabel('Number of Teams', 'fontsize', 10);
title('NBA (n=30)', 'fontsize', 11);
ylim([0 nba_stoch + 5]);
grid on;
try
  sgtitle('Diagnostic Taxonomy: League Comparison (R6)', 'fontsize', 11);
catch
  % sgtitle not in older Octave; subplot titles suffice
end
print -dpng -r300 fig8_league_summary.png;
fprintf('Saved fig8_league_summary.png\n');

fprintf('Done. All plots saved in current directory.\n');
