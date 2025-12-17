# Anna Archive Client - Docker

## Build and Run

### 1. Build the Flutter web app first:

```bash
flutter build web --release --web-renderer html
```

### 2. Build the Docker image:

```bash
docker build -t aa-client:latest .
```

### 3. Run with Docker Compose:

```bash
docker-compose up -d
```

The app will be available at: http://localhost:8080

### Alternative: Run directly with Docker:

```bash
docker run -d -p 8080:80 --name aa-client aa-client:latest
```

### Stop and remove:

```bash
docker-compose down
# or
docker stop aa-client && docker rm aa-client
```

## Rebuild after changes

When you make changes to the Flutter app:

```bash
flutter build web --release --web-renderer html
docker build -t aa-client:latest .
docker-compose up -d
```

## Notes

- Build the Flutter web app on the host before creating the Docker image
- The Docker image only contains the built web files served by nginx
- CORS is enabled in nginx for local API calls
- Static assets are cached for 1 year
- Gzip compression is enabled for better performance
