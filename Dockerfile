FROM aiboot/r-minimal:4.4.2

RUN installr -d -t "zlib-dev gfortran" AbrJA/anomalyr
RUN installr -d -t "zlib-dev" shiny
RUN installr -d -t "curl-dev gfortran" plotly
RUN installr -d bslib
RUN installr -d DT

WORKDIR /app

ENV HOME=/app

COPY global.r .
COPY server.r .
COPY ui.r .

EXPOSE 8000

CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 8000)"]
