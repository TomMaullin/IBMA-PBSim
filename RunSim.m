
for i=0:9
    
    % =====================================================================
    % Field Generation
    % ---------------------------------------------------------------------
    
    % Initialise number of subjects for this study and target study 
    % variance.
    numSubj = randi([8 30]);
    sig2 = 2*rand(1)+0.5;
    
    % Make a chi squared field to simulate a varcope.
    varcope = zeros(91, 109, 91);
    for j = 1:numSubj
        
        fprintf('Study %d Subject %d (out of %d) \n', i, j, numSubj)

        % Make a smooth gaussian random field
        normal_rf = datagen(6,1);

        % Add it to the chi squared
        varcope = varcope + normal_rf.^2;

    end
    varcope = varcope./numSubj.*sig2;
    
    % Generate a new smooth gaussian random field with dimensions 
    % [91, 109, 91] and smoothness 5.7.
    normal_rf=datagen(6,1);
    
    % Multiply it by the standard errors
    cope = normal_rf.*sqrt(varcope);
    
    % =====================================================================
    % File saving
    % ---------------------------------------------------------------------
    
    % Create a COPE volume.
    cope_vol = deal(struct(...
      'fname',    sprintf('sim%d.nii', i),...
      'dim',      [91 109 91],...
      'dt',       [spm_type('float32') spm_platform('bigend')],...
      'mat',      eye(4),...
      'pinfo',    [1 0 0]',...
      'descrip',  '3D smooth Gaussian random field'));
    cope_vol = spm_create_vol(cope_vol);
    
    % Create a VARCOPE volume.
    varcope_vol = deal(struct(...
      'fname',    sprintf('sim%d_var.nii', i),...
      'dim',      [91 109 91],...
      'dt',       [spm_type('float32') spm_platform('bigend')],...
      'mat',      eye(4),...
      'pinfo',    [1 0 0]',...
      'descrip',  '3D smooth chi squared random field'));
    varcope_vol = spm_create_vol(varcope_vol);
    
    disp(fileparts(mfilename('fullpath')))
    
    % Save the smooth random field.
    spm_write_vol(cope_vol, cope);
    spm_write_vol(varcope_vol, varcope);
    
    % =====================================================================
    % Biased Selection
    % ---------------------------------------------------------------------
    
    % Record the average value in a 3 by 3 by 3 cube of our choice inside
    % the map.
    cubeOfInterest = cope(50:52, 50:52, 50:52);
    meanValue = mean(cubeOfInterest(:));
    disp(meanValue)
    
end