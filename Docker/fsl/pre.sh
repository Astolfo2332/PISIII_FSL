if [ -z "$(ls -A /output)" ]; then \
        echo "Output directory is empty. Wait until dcm2bids finishes and run the compose again :_(" ;\
    else \
        echo "Starting preprocessing >:/" ;\
        rm -rf output/tmp_dcm2bids && \
        for patient_dir in /output/sub-*; do \
            patient_num=$(basename $patient_dir); \
            if [ -d ${patient_dir}/anat ]; then \
                mkdir -p /output/derivatives/preprocessed/${patient_num}/anat && \
                anat_new_value=$(jq -r '.anat.value' /config/parameters.json); \
                for file in ${patient_dir}/anat/*.nii.gz*; do \
                    base=$(basename $file); \
                    bet $file /output/derivatives/preprocessed/${patient_num}/anat/${base%.nii.gz}_brain -f ${anat_new_value} -g 0; \
                done; \
            fi; \
            if [ -d ${patient_dir}/func ]; then \
                mkdir -p /output/derivatives/preprocessed/${patient_num}/func && \
                func_new_value=$(jq -r '.func.value' /config/parameters.json); \
                for file in ${patient_dir}/func/*.nii.gz*; do \
                    base=$(basename $file); \
                    bet $file /output/derivatives/preprocessed/${patient_num}/func/${base%.nii.gz}_brain -F -f ${func_new_value} -g 0; \
                    rm -f /output/derivatives/preprocessed/${patient_num}/func/${base%.nii.gz}_brain_mask.nii.gz; \
                done; \
            fi; \
            echo "Preprocessing for patient ${patient_num} done :)" ;\
        done && \
        echo "Preprocessing finished, have a nice day ;)" ;\
        post_processing=$(jq -r '.post_processing' /config/parameters.json); \
        if [ "$post_processing" -eq 1 ]; then \
            echo "Starting post-processing..." && \
            volumes_erase=$(jq -r '.post_processed_parameters.volumes_erase' /config/parameters.json); \
            spatial_smoothing=$(jq -r '.post_processed_parameters.spatial_smoothing' /config/parameters.json); \
            non_linear=$(jq -r '.post_processed_parameters.non_linear' /config/parameters.json); \
            off_value=$(jq -r '.post_processed_parameters.stats[0]' /config/parameters.json); \
            on_value=$(jq -r '.post_processed_parameters.stats[1]' /config/parameters.json); \
            Zthresh=$(jq -r '.post_processed_parameters.Zthresh' /config/parameters.json); \
            p_threshold=$(jq -r '.post_processed_parameters.p' /config/parameters.json); \
            for patient_dir in /output/derivatives/preprocessed/*; do \
                patient_num=$(basename $patient_dir); \
                if [ -d ${patient_dir}/func ]; then \
                    for func_file in ${patient_dir}/func/*.nii.gz*; do \
                        func_base=$(basename $func_file); \
                        echo "Modifying desing for ${func_base}"; \
                        output_dir="/output/derivatives/postprocessed/${patient_num}/$func_base/"; \
                        mkdir -p $output_dir; \
                        cp /config/design.fsf $output_dir/design.fsf; \
                        sed -i "s/^set fmri(ndelete) [0-9]*$/set fmri(ndelete) $volumes_erase/" $output_dir/design.fsf; \
                        sed -i "s/^set fmri(smooth) [0-9]*$/set fmri(smooth) $spatial_smoothing/" $output_dir/design.fsf; \
                        sed -i "s/^set fmri(regstandard_nonlinear_yn) [0-1]$/set fmri(regstandard_nonlinear_yn) $non_linear/" $output_dir/design.fsf; \
                        sed -i "s/^set fmri(off1) [0-9]*$/set fmri(off1) $off_value/" $output_dir/design.fsf; \
                        sed -i "s/^set fmri(on1) [0-9]*$/set fmri(on1) $on_value/" $output_dir/design.fsf; \
                        sed -i "s/^set fmri(prob_thresh) [0-9.]*$/set fmri(prob_thresh) $p_threshold/" $output_dir/design.fsf; \
                        sed -i "s/^set fmri(z_thresh) [0-9.]*$/set fmri(z_thresh) $Zthresh/" $output_dir/design.fsf; \
                        func_file_without_preprocessed=$(echo "$func_file" | sed 's/\/derivatives\/preprocessed//')
                        func_file_without_brain="${func_file_without_preprocessed%_brain*}"; \
                        sed -i "s|^set feat_files(1) .*$|set feat_files(1) \"$func_file_without_brain\"|" $output_dir/design.fsf; \
                        anat_file=$(basename /output/derivatives/preprocessed/${patient_num}/anat/*.nii.gz); \
                        anat_file="${anat_file%.nii.gz}"; \
                        sed -i "s|^set highres_files(1) .*$|set highres_files(1) \"/output/derivatives/preprocessed/${patient_num}/anat/$anat_file\"|" $output_dir/design.fsf; \
                        total_voxels=$(fslstats "$func_file_without_brain" -V | awk '{ print $1 }'); \
                        sed -i "s|^set fmri(totalVoxels) .*$|set fmri(totalVoxels) ${total_voxels}|" $output_dir/design.fsf; \
                        sed -i "s|^set fmri(outputdir) .*$|set fmri(outputdir) \"${output_dir%/}\"|" $output_dir/design.fsf
                        echo "Design modified for ${func_base}"; \
                    done; \
                fi; \
            done; \
            echo "All files modified";            
        fi;         
    fi;