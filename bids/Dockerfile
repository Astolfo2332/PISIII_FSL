FROM unfmontreal/dcm2bids

WORKDIR /app

CMD if [ "$(ls -A /app)" ]; then \
        echo "Output directory is not empty, skipping dcm2bids"; \
    else \
        for patient_dir in /app/*; do \
            patient_num=$(basename $patient_dir); \
            dcm2bids -d $patient_dir -o /output/ -p $patient_num -c /config/config.json; \
        done && \
        rm -rf app/tmp_dcm2bids; \
    fi
