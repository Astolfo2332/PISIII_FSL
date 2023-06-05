
for subfolder in /output/derivatives/postprocessed/sub-*; do \
        if [ -d "$subfolder" ]; then \
            for design_folder in "$subfolder"/*; do \
                if [ -d "$design_folder" ]; then \
                    design_name=$(basename "$design_folder"); \
                    echo "Performing post-processing for $design_name..."; \
                    feat "$design_folder/design.fsf"; \
                    echo "Finishing post-processing for $design_name..."; \
                fi; \
            done; \
        fi; \
done; \
echo "General post-processing completed."; \
echo "Have a nice day ;)";