$STOP_SERVICE = "docker compose up down"
echo "Starting homepage service..."
cd  homepage/ && $STOP_SERVICE

echo "Starting pyload service..."
cd  ../pyload/ && $STOP_SERVICE

echo "Starting qbittorrent service..."
cd  ../qbittorrent/ && $STOP_SERVICE

echo "Starting monitoring service..."
cd  ../monitoring/ && $STOP_SERVICE