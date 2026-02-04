%% prove_hypothesis.m
% Chaos vs Random baseline for multiple teams. Target: team's goals per game.
% Test cases: Team 52, 6, 14, 19, 24 (same pipeline each).
% Chaos model: k-NN with inverse-distance weighting; tune dim and delay.

%% Load packages (optional; fallback to built-ins)
try
  pkg load io;
catch
  % proceed without io
end
try
  pkg load statistics;
catch
  % proceed without statistics
end

%% Load data (skip header; read numeric columns Home=2, Away=3, FTHG=4, FTAG=5)
fname = 'data/processed/clean_game.csv';
if exist(fname, 'file') ~= 2
  error('File not found: %s', fname);
end

D = dlmread(fname, ',', 1, 1);
% D columns: 1=HomeTeam, 2=AwayTeam, 3=FTHG, 4=FTAG

%% Test cases: team IDs to run (original + 3–4 more)
team_list = [52, 6, 14, 19, 24];

%% Open results files (compile output for validation)
results_dir = 'data/results';
if exist(results_dir, 'dir') ~= 7
  mkdir(results_dir);
end
results_fid = fopen(fullfile(results_dir, 'prove_hypothesis_results.txt'), 'w');
summary_fid = fopen(fullfile(results_dir, 'prove_hypothesis_summary.csv'), 'w');
fprintf(results_fid, 'Prove Hypothesis — Chaos vs Random Baseline (Team goals)\n');
fprintf(results_fid, '============================================================\n\n');
fprintf(summary_fid, 'team_id,n,n_test,rmse_chaos,rmse_random,improvement_pct,best_dim,best_delay\n');

%% Chaos model settings (shared across teams)
k_nn = 5;
eps_dist = 1e-6;
normalize_emb = true;
dim_list = [3, 4, 5];
delay_list = [1, 2];

%% Run pipeline for each team
for t_idx = 1 : length(team_list)
  team_id = team_list(t_idx);

  %% Filter: this team as Home (col 1) OR Away (col 2)
  mask = (D(:, 1) == team_id) | (D(:, 2) == team_id);
  D_team = D(mask, :);

  %% Target: team's goals (FTHG when home, FTAG when away)
  is_home = (D_team(:, 1) == team_id);
  y = zeros(size(D_team, 1), 1);
  y(is_home)  = D_team(is_home, 3);
  y(~is_home) = D_team(~is_home, 4);

  n = length(y);
  if n < 10
    fprintf('--- Test case: Team %d --- SKIP (too few games: %d)\n', team_id, n);
    continue
  end

  %% Split: first 85% train, last 15% test
  n_train = floor(0.85 * n);
  n_test = n - n_train;
  y_train = y(1 : n_train);
  y_test = y(n_train + 1 : end);

  %% Model A: Random baseline — predict next = mean of last 5 games
  pred_random = zeros(n_test, 1);
  for j = 1 : n_test
    idx_start = n_train + j - 5;
    idx_end   = n_train + j - 1;
    pred_random(j) = mean(y(idx_start : idx_end));
  end

  %% Model B: Chaos — tune dim & delay
  best_rmse = inf;
  best_dim = 3;
  best_delay = 1;

  for dim = dim_list
    for delay = delay_list
      max_i = n_train - (dim - 1) * delay - 1;
      if max_i < 10
        continue
      end
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
        w = 1 ./ d_k;
        pred_trial(j) = sum(w .* y_next(idx_k)) / sum(w);
      end
      rmse_trial = sqrt(mean((y_test - pred_trial) .^ 2));
      if rmse_trial < best_rmse
        best_rmse = rmse_trial;
        best_dim = dim;
        best_delay = delay;
      end
    end
  end

  %% Build final chaos model with best (dim, delay)
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
    w = 1 ./ d_k;
    pred_chaos(j) = sum(w .* y_next(idx_k)) / sum(w);
  end

  %% RMSE and improvement
  rmse_chaos  = sqrt(mean((y_test - pred_chaos) .^ 2));
  rmse_random = sqrt(mean((y_test - pred_random) .^ 2));
  if rmse_random > 0
    improvement_pct = (rmse_random - rmse_chaos) / rmse_random * 100;
  else
    improvement_pct = 0;
  end

  %% Print and compile results for this test case
  fprintf('--- Test case: Team %d (n=%d, test=%d) ---\n', team_id, n, n_test);
  fprintf('Chaos RMSE:  %.4f (dim=%d, delay=%d, k=%d)\n', rmse_chaos, best_dim, best_delay, k_nn);
  fprintf('Random RMSE: %.4f\n', rmse_random);
  fprintf('Improvement: %.2f%%\n', improvement_pct);
  fprintf('\n');
  fprintf(results_fid, '--- Test case: Team %d (n=%d, test=%d) ---\n', team_id, n, n_test);
  fprintf(results_fid, 'Chaos RMSE:  %.4f (dim=%d, delay=%d, k=%d)\n', rmse_chaos, best_dim, best_delay, k_nn);
  fprintf(results_fid, 'Random RMSE: %.4f\n', rmse_random);
  fprintf(results_fid, 'Improvement: %.2f%%\n\n', improvement_pct);
  fprintf(summary_fid, '%d,%d,%d,%.6f,%.6f,%.4f,%d,%d\n', ...
    team_id, n, n_test, rmse_chaos, rmse_random, improvement_pct, best_dim, best_delay);
end

fclose(results_fid);
fclose(summary_fid);
fprintf('Results written to %s/prove_hypothesis_results.txt and prove_hypothesis_summary.csv\n', results_dir);
