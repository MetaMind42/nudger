FROM dart:3.5.4

RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    libaio1 \
    wget \
    alien \
    odbc-postgresql \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/oracle

RUN wget https://download.oracle.com/otn_software/linux/instantclient/oracle-instantclient-basic-linuxx64.rpm && \
    wget https://download.oracle.com/otn_software/linux/instantclient/oracle-instantclient-odbc-linuxx64.rpm && \
    alien -i oracle-instantclient-basic-linuxx64.rpm && \
    alien -i oracle-instantclient-odbc-linuxx64.rpm && \
    rm *.rpm

ENV ORACLE_HOME=/usr/lib/oracle/client64
ENV LD_LIBRARY_PATH=/usr/lib/oracle/client64/lib

RUN mkdir -p $ORACLE_HOME/lib && \
    echo "[Oracle ODBC Driver]" > $ORACLE_HOME/lib/odbc.ini && \
    echo "Driver=/usr/lib/oracle/client64/lib/libsqora.so.21.1" >> $ORACLE_HOME/lib/odbc.ini && \
    odbcinst -i -d -f $ORACLE_HOME/lib/odbc.ini

WORKDIR /appm

COPY build/ .

RUN dart pub get

RUN dart compile exe bin/server.dart -o bin/app

CMD ["/app/bin/app"]
