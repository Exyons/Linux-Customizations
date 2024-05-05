# echo "Starting homepage service..."
# cd  homepage/ && docker compose up -d

# echo "Starting pyload service..."
# cd  ../pyload/ && docker compose up -d

# echo "Starting qbittorrent service..."
# cd  ../qbittorrent/ && docker compose up -d

# echo "Starting monitoring service..."
# cd  ../monitoring/ && docker compose up -d

docker stack deploy -c homepage/docker-compose.yml,pyload/docker-compose.yml,qbittorrent/docker-compose.yml,monitoring/docker-compose.yml