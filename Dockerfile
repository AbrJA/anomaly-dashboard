FROM aiboot/r-minimal:4.4.2

RUN installr -d -t "zlib-dev gfortran" AbrJA/anomalyr
RUN installr -d -t "zlib-dev" shiny
RUN installr -d -t "curl-dev gfortran" plotly
RUN installr -d bslib
RUN installr -d DT

WORKDIR /detector

ENV HOME=/detector

COPY app ./app

EXPOSE 8000

CMD ["R", "-e", "shiny::runApp('/detector/app', host = '0.0.0.0', port = 8000)"]
