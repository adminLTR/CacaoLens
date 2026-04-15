FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Create a minimal Flutter web project structure
RUN flutter create . --platforms web --project-name cacaolens

# Get dependencies
RUN flutter pub get

# Copy the application files (this will override the generated files)
COPY . .

# Get dependencies again after copying
RUN flutter pub get

# Build web version
RUN flutter build web --release

# For a simple serving solution
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
