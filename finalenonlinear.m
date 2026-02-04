% Nonlinearity tests (Keenan, Ramsey, Terasvirta, Tsay) on denoised data.
% Uses chaos_config() for column names and paths (README_TECHNICAL.md).
% Requires: NonlinTst(y) and chaos_config.m.

cfg = chaos_config();
baseFolder = cfg.folder_denoised;
outFolder  = cfg.folder_nonlinear;
colNames   = cfg.columns;

if ~exist(outFolder, 'dir')
    mkdir(outFolder);
end

fileList = dir(fullfile(baseFolder, '*.csv'));

for f = 1:numel(fileList)

    %--- Read in the CSV file as a table:
    csvFile = fullfile(fileList(f).folder, fileList(f).name);
    T = readtable(csvFile, 'PreserveVariableNames', true);
    
    %--- Build a name for the output text file:
    [~, baseName, ~] = fileparts(fileList(f).name);
    outName = fullfile(outFolder, [baseName, '_test.txt']);
    
    %--- Open the text file for writing:
    fid = fopen(outName, 'w');
    if fid<0
        warning('Could not open %s for writing. Skipping...', outName);
        continue;
    end
    
    fprintf(fid, 'Results for %s\n\n', fileList(f).name);

    %--- Loop over the columns of interest and run the tests:
    for c = 1:numel(colNames)
        thisCol = colNames{c};
        
        % Make sure the column exists in this table:
        if ~ismember(thisCol, T.Properties.VariableNames)
            fprintf(fid, 'Column "%s" not in file. Skipping.\n\n', thisCol);
            continue;
        end
        
        % Extract the data as a numeric vector:
        y = T.(thisCol);
        
        % Call your nonlinearity test function:
        [PvalRamsey, PvalKeenan, PvalTras, PvalTsay] = NonlinTst(y);
        
        % Write results to file:
        fprintf(fid, 'Column: %s\n', thisCol);
        fprintf(fid, '  Ramsey p-value:    %f\n', PvalRamsey);
        fprintf(fid, '  Keenan p-value:    %f\n', PvalKeenan);
        fprintf(fid, '  Terasvirta p-value:%f\n', PvalTras);
        fprintf(fid, '  Tsay p-value:      %f\n\n', PvalTsay);
    end

    fclose(fid);

    fprintf('Wrote test results to: %s\n', outName);
end
