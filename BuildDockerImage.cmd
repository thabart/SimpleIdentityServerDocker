# Build the docker image
docker build -t simpleidserver -f Dockerfile-Authorization .
docker build -t uma -f Dockerfile-Uma .
docker build -t websiteapi -f Dockerfile-WebSiteApi .
docker build -t website -f Dockerfile-WebSite .

# Run postgresql
docker run --name postgresql -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=postgres -d postgres

# Run simpleidserver
docker run --name simpleidserver -e DB_ALIAS=postgresql -e DB_PORT=5432 --link postgresql simpleidserver

# Run postgresql - uma
docker run --name postgresql_uma -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=postgres -d postgres

# Run UMA
docker run --name uma -e DB_ALIAS=postgresql -e DB_PORT=5432 --link postgresql_uma:postgresql --link simpleidserver:simpleidserver uma

# Run mongo db
docker run --name mongo -d mongo

# Run application
docker run --name websiteapi --link mongo:mongo -d websiteapi