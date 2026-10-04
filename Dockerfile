FROM mysql:8
EXPOSE 3306
COPY myfile.sql /docker-entrypoint-initdb.d 
ENV MY_SQL_ROOT_PASSWORD=admin123
