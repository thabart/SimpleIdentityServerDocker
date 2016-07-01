# Build the docker image
docker build -t simpleidserver -f Dockerfile-Authorization .
docker build -t uma -f Dockerfile-Uma .
docker build -t websiteapi -f Dockerfile-WebSiteApi .
docker build -t website -f Dockerfile-WebSite .

# delete all images
docker rm -f $(docker ps -aq)
docker rmi simpleidentityserverdocker_websiteapi
docker rmi simpleidentityserverdocker_simpleidserver
docker rmi simpleidentityserverdocker_configuration
docker rmi simpleidentityserverdocker_website
docker rmi simpleidentityserverdocker_uma
docker rmi simpleidentityserverdocker_manager

# Run postgresql
docker run --name postgresql -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=postgres -d postgres

# Run simpleidserver
docker run --name simpleidserver -e DB_ALIAS=postgresql -e DB_PORT=5432 -p 5443:5443 -p 5000:5000 --link postgresql -it simpleidserver /bin/bash

# Run postgresql - uma
docker run --name postgresql_uma -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=postgres -d postgres

# Run UMA
docker run --name uma -e DB_ALIAS=postgresql -e DB_PORT=5432 --link postgresql_uma:postgresql --link simpleidserver:simpleidserver uma

# Run mongo db
docker run --name mongo -d mongo

# Run application
docker run --name websiteapi --link mongo:mongo -d websiteapi

# Export certificate
openssl x509 -inform der -in LokitCa.cer -out LokitCa.pem