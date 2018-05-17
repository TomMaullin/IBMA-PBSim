function RunSim(id)
    tic
    % Make a directory for simulated data.
    if ~isdir(fullfile(fileparts(mfilename('fullpath')), 'data'))
        mkdir(fullfile(fileparts(mfilename('fullpath')), 'data'))
    end
    
    if ~isdir(fullfile(fileparts(mfilename('fullpath')), 'data', num2str(id)))
        mkdir(fullfile(fileparts(mfilename('fullpath')), 'data', num2str(id)));
    end
    
    currentMaxima = repmat(-100, 1, 50);
    numSubjArray = repmat(-100, 1, 50);

    for i=1:1000

        disp(currentMaxima)

        % =====================================================================
        % Field Generation
        % ---------------------------------------------------------------------

        % Initialise number of subjects for this study and target study 
        % variance.
        numSubj = randi([8 30]);
        sig2 = 3*rand(1)+0.5;

        % Make a chi squared field to simulate a secope.
        secope = zeros(91, 109, 91);
        for j = 1:numSubj

            fprintf('Study %d Subject %d (out of %d) \n', i, j, numSubj)

            % Make a smooth gaussian random field
            normal_rf = datagen(6,1);

            % Add it to the chi squared
            secope = secope + normal_rf.^2;

        end
        secope = sqrt(secope./numSubj.*sig2);

        % Generate a new smooth gaussian random field with dimensions 
        % [91, 109, 91] and smoothness 5.7.
        normal_rf=datagen(6,1);

        % Multiply it by the standard errors
        cope = normal_rf.*sqrt(secope);


        % =====================================================================
        % File saving
        % ---------------------------------------------------------------------

        % We only ever want at most ten copes saved for space efficiency. For
        % the first ten fields we just save them directly.
        if i <= 50

            % Record number of subjects.
            numSubjArray(i) = numSubj;

            % Create a COPE volume.
            cope_vol = deal(struct(...
              'fname',    fullfile(fileparts(mfilename('fullpath')), 'data', num2str(id),...
                                   sprintf('sim%d.nii', i)),...
              'dim',      [91 109 91],...
              'dt',       [spm_type('float32') spm_platform('bigend')],...
              'mat',      eye(4),...
              'pinfo',    [1 0 0]',...
              'descrip',  '3D smooth Gaussian random field'));
            cope_vol = spm_create_vol(cope_vol);

            % Create a secope volume.
            secope_vol = deal(struct(...
              'fname',    fullfile(fileparts(mfilename('fullpath')), 'data', num2str(id),...
                                   sprintf('sim%d_var.nii', i)),...
              'dim',      [91 109 91],...
              'dt',       [spm_type('float32') spm_platform('bigend')],...
              'mat',      eye(4),...
              'pinfo',    [1 0 0]',...
              'descrip',  '3D smooth chi squared random field'));
            secope_vol = spm_create_vol(secope_vol);

            % Save the smooth random field.
            spm_write_vol(cope_vol, cope);
            spm_write_vol(secope_vol, secope);

            % Record the average value in a 3 by 3 by 3 cube of our choice 
            % inside the map.
            cubeOfInterest = cope(50:53, 50:53, 50:53);
            currentMaxima(i) = mean(cubeOfInterest(:));

        else

            % =================================================================
            % Biased Selection
            % -----------------------------------------------------------------
            % We only need the volumes we biasedly select (i.e. those with the
            % highest mean in our cube of interest.


            % Record the average value in a 3 by 3 by 3 cube of our choice 
            % inside the map.
            cubeOfInterest = cope(50:56, 50:56, 50:56);
            meanValue = mean(cubeOfInterest(:));

            % Check whether the mean value from this map is greater than any of
            % those we have recorded already.
            [minmaxval, indx] = min(currentMaxima);

            % If our mean is greater than the smallest maximum mean we have
            % recorded, replace that corresponding.
            if minmaxval < meanValue

                % Create a COPE volume.
                cope_vol = deal(struct(...
                  'fname',    fullfile(fileparts(mfilename('fullpath')),... 
                                       'data', num2str(id),...
                                       sprintf('sim%d.nii', indx)),...
                  'dim',      [91 109 91],...
                  'dt',       [spm_type('float32') spm_platform('bigend')],...
                  'mat',      eye(4),...
                  'pinfo',    [1 0 0]',...
                  'descrip',  '3D smooth Gaussian random field'));
                cope_vol = spm_create_vol(cope_vol);

                % Create a secope volume.
                secope_vol = deal(struct(...
                  'fname',    fullfile(fileparts(mfilename('fullpath')),... 
                                       'data', num2str(id),...
                                       sprintf('sim%d_var.nii', indx)),...
                  'dim',      [91 109 91],...
                  'dt',       [spm_type('float32') spm_platform('bigend')],...
                  'mat',      eye(4),...
                  'pinfo',    [1 0 0]',...
                  'descrip',  '3D smooth chi squared random field'));
                secope_vol = spm_create_vol(secope_vol);

                % Save the smooth random field.
                spm_write_vol(cope_vol, cope);
                spm_write_vol(secope_vol, secope);

                % Record this new map.
                currentMaxima(indx) = meanValue;

                % Record number of subjects.
                numSubjArray(indx) = numSubj;

            end

        end

    end

    save('subj','numSubjArray');
    save('maxVals', 'currentMaxima');
    toc
end