function sanityCheck()
    
    % Read in a cope volume.
    cope = spm_vol('sim0.nii');
    cope = spm_read_vols(cope);
    
    % Read in a varcope volume.
    varcope = spm_vol('sim0_var.nii');
    varcope = spm_read_vols(varcope);
    
    % Create histograms of each.
    figure;
    histogram(cope);
    figure;
    histogram(varcope);

end 