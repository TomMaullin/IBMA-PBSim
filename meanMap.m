meanvals = zeros(91, 109, 91);

for i = 1:50
    
    vol = spm_vol(fullfile(fileparts(mfilename('fullpath')), 'data',...
                               sprintf('sim%d.nii', i)));
                           
    vol = spm_read_vols(vol);
    
    meanvals = vol + meanvals;
    
end

meanvals = meanvals./10;

% Create a mean volume.
mean_vol = deal(struct(...
  'fname',    fullfile(fileparts(mfilename('fullpath')), 'data',...
                       'mean.nii'),...
  'dim',      [91 109 91],...
  'dt',       [spm_type('float32') spm_platform('bigend')],...
  'mat',      eye(4),...
  'pinfo',    [1 0 0]',...
  'descrip',  '3D smooth Gaussian random field'));
mean_vol = spm_create_vol(mean_vol);

% Save the mean map.
spm_write_vol(mean_vol, meanvals);