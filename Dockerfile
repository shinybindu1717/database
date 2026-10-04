FROM mysql:8
EXPOSE 3306
COPY myfile.sql /docker-entrypoint-initdb.d 
ENV MYSQL_ROOT_PASSWORD=admin123
