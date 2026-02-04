% run_chaos_octave.m
% Load clean_game.csv with Octave built-ins (no io package), filter team 52,
% sort by date, then run chaos_modified in vector mode.
% Run from project directory: octave run_chaos_octave.m

csv_path = 'data/processed/clean_game.csv';
target_team_id = 52;
column_name = 'FTHG';

fid = fopen(csv_path);
if fid == -1
  error('Cannot open %s', csv_path);
end
header = fgetl(fid);
headers = strsplit(header, ',');
headers = cellfun(@strtrim, headers, 'UniformOutput', false);
date_col  = find(strcmpi(headers, 'Date'));
home_col  = find(strcmpi(headers, 'HomeTeam'));
away_col  = find(strcmpi(headers, 'AwayTeam'));
fthg_col  = find(strcmpi(headers, 'FTHG'));
if isempty(date_col) || isempty(home_col) || isempty(away_col) || isempty(fthg_col)
  fclose(fid);
  error('Required columns not found. Header: %s', header);
end

HomeTeam = [];
AwayTeam = [];
FTHG     = [];
Date_str = {};
while true
  line = fgetl(fid);
  if line == -1, break; end
  toks = strsplit(line, ',');
  toks = cellfun(@strtrim, toks, 'UniformOutput', false);
  HomeTeam(end+1) = str2double(toks{home_col});
  AwayTeam(end+1) = str2double(toks{away_col});
  FTHG(end+1)    = str2double(toks{fthg_col});
  Date_str{end+1} = toks{date_col};
end
fclose(fid);

mask = (HomeTeam == target_team_id) | (AwayTeam == target_team_id);
FTHG = FTHG(mask);
Date_str = Date_str(mask);
% Octave: use lowercase for date parts (dd, mm, yyyy) to avoid format warning
datenums = cellfun(@(s) datenum(s, 'dd/mm/yyyy'), Date_str);
[~, ord] = sort(datenums);
y = FTHG(ord);

fprintf('Team %d | Games: %d\n', target_team_id, numel(y));
if numel(y) < 500
  error('Sample size too small for this team. Pick a different Team ID.');
end

% Octave has no adftest; chaos_modified will assume stationary and warn once
warning('off', 'chaos_modified:no_adftest');
out = chaos_modified(y, [], 'adf', 'schreiber', 0, 'AAFT', 'downsample', 0.5);
disp('Result:');
disp(out.result);
