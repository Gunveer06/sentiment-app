FROM alpine:latest

# Install lightweight web server darkhttpd
RUN apk add --no-cache darkhttpd

# Create web root and index.html
RUN mkdir -p /var/www && echo "Sentiment Engine ingesting" > /var/www/index.html

# Expose container port 80
EXPOSE 80

# Print the required log message and launch HTTP server
CMD ["sh", "-c", "echo 'Sentiment Engine ingesting' && darkhttpd /var/www --port 80"]
