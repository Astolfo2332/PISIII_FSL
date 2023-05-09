# Base image
FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y fsl && \
    apt-get install -y git build-essential cmake zlib1g-dev  &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN git clone https://github.com/rordenlab/dcm2niix.git && \
    cd dcm2niix && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    cd ../.. && \
    rm -rf dcm2niix
    
   
ENV FSLDIR="/usr/share/fsl/5.0"
ENV PATH="${FSLDIR}/bin:${PATH}"
ENV FSLOUTPUTTYPE="NIFTI_GZ"
ENV LD_LIBRARY_PATH=/usr/local/fsl/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

WORKDIR /app

COPY StudyDir_18042023014906/ST1/ /app


RUN mkdir /nifti && \ 
for folder in /app/*; do dcm2niix -o "$folder" "$folder"; \
mv "$folder"/*.nii /nifti; \ 
done 

#RUN for file in /app/NIfTI/*/*.nii*; do \
#        subfolder=$(basename "$(dirname "$file")"); \
#        filename=$(basename "$file"); \
#mkdir /app/brain && \
#for file in /nifti/*.nii; do base=$(basename $file); bet $file /app/brain/${base%.nii}_brain -f 0.5 -g 0 -m; done && \
#    mv /app/*/*_brain.nii.gz /data/; \
#done

