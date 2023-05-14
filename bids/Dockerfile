FROM unfmontreal/dcm2bids

WORKDIR /app

CMD for patient_dir in /app/*; do \
        patient_num=$(basename $patient_dir); \
        dcm2bids -d $patient_dir -o /output/ -p $patient_num -c /config/config.json; \
    done && \
    rm -rf /tmp_dcm2bids

