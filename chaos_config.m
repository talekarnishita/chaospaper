function cfg = chaos_config()
%CHAOS_CONFIG Shared configuration for chaos-analysis pipeline.
%   cfg = chaos_config() returns a struct with column names and paths used by
%   phasechaos.m and finalenonlinear.m. Aligns with README_TECHNICAL.md
%   (multi-metric validation: 14 domain-standard sports metrics, per-column
%   processing).
%
%   cfg.columns       - Cell array of 14 sports metric column names
%   cfg.folder_raw    - Folder containing raw team CSV files (default: 'data/raw')
%   cfg.folder_results - Folder for chaos classification results (default: 'data/results')
%   cfg.folder_denoised - Folder for denoised CSVs (default: 'data/denoised')
%   cfg.folder_nonlinear - Folder for nonlinearity test results (default: 'data/nonlinear_results')
%
%   Override paths by editing this file or by setting cfg fields after calling.

cfg = struct();

% 14 sports metrics: domain-standard performance/outcome variables (README_TECHNICAL §3).
% Same list used by phasechaos.m (chaos classification) and finalenonlinear.m (Keenan etc.).
cfg.columns = {"FTGoalsFor", "FTGoalsAgainst", "TeamGS", "TeamGC", "TeamPoints", "MatchWeek", ...
    "TeamFormPts", "WinStreak3", "WinStreak5", "LossStreak3", "LossStreak5", ...
    "TeamGD", "TeamDiffPts", "TeamDiffFormPts"};

% Paths: relative to current directory for portability. Create these folders or override.
base = "data";
cfg.folder_raw       = fullfile(base, "raw");
cfg.folder_results  = fullfile(base, "results");
cfg.folder_denoised = fullfile(base, "denoised");
cfg.folder_nonlinear = fullfile(base, "nonlinear_results");
end
