# Base image
FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y fsl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV FSLDIR="/usr/share/fsl/5.0"
ENV PATH="${FSLDIR}/bin:${PATH}"
ENV FSLOUTPUTTYPE="NIFTI_GZ"

WORKDIR /app

COPY bet_analysis.sh /app

ENTRYPOINT ["/app/bet_analysis.sh"]
