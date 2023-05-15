FROM unfmontreal/dcm2bids

WORKDIR /app

RUN mkdir /tem

CMD if [ "$(ls -A /output)" ]; then \
        echo "Output directory is not empty, skipping dcm2bids"; \
    else \
        for patient_dir in /app/*; do \
            patient_num=$(basename $patient_dir); \
            dcm2bids -d $patient_dir -o /tem/ -p $patient_num -c /config/config.json; \
        done && \
        mv /tem/* /output/ &&\
        cp /config/dataset_description.json /output/ &&\
        cp /config/participants.tsv /output/ &&\
        cp /config/participants.json /output/ &&\
        echo "Please run the docker-compose up to do the preprocessing :^)"; \
    fi; 