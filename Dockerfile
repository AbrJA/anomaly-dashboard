FROM aiboot/r-minimal:4.4.2

RUN installr -d R6
RUN installr -d pool
RUN installr -d checkmate
RUN installr -d -t "curl-dev" httr
RUN installr -d -t "zlib-dev" yyjsonr
RUN installr -d -a "hiredis-dev" redux
RUN installr -d -t "gfortran" forecast

RUN echo -e 'PKG_CFLAGS+=-fopenmp\nPKG_LIBS+=-fopenmp\n' >> /tmp/Makevars && \
    R_MAKEVARS_USER=/tmp/Makevars \
    installr -a "libgomp zlib" -t "openmp-dev zlib-dev" -d data.table && \
    rm /tmp/Makevars

RUN ldd /usr/local/lib/R/library/data.table/libs/data_table.so 2> /dev/null || true

RUN installr -d AbrJA/healthr
RUN installr -d -t "zlib-dev" shiny
RUN installr -d -t "curl-dev gfortran" plotly

WORKDIR /app

ENV HOME=/app

COPY global.R .
COPY server.R .
COPY ui.R .

EXPOSE 8000

CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 8000)"]
