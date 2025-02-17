# zero-nginx (Archived)

⚠️ **This repository is archived. All functionality has been moved to [Zero](https://github.com/yarlson/zero).**

Zero now provides a more robust and simpler solution for SSL certificate management with Nginx. See the [Docker integration guide](https://github.com/yarlson/zero#docker) for setup instructions.

## Migration Guide

If you're using zero-nginx, you can migrate to Zero using this docker-compose.yml:

```yaml
volumes:
  certs:  # Named volume for certificates

services:
  zero:
    image: yarlson/zero:latest
    ports:
      - "80:80"
    volumes:
      - certs:/certs
    command:
      - -d
      - example.com
      - -e
      - user@example.com
      - -c
      - /certs
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - certs:/etc/nginx/certs:ro
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - zero
    restart: unless-stopped
```

Benefits of the new solution:
- Simpler architecture (no certificate renewer container needed)
- More reliable certificate management
- Better Docker integration
- Automatic HTTP to HTTPS redirection
- Support for both AMD64 and ARM64 architectures

See the [Zero documentation](https://github.com/yarlson/zero) for complete setup instructions and configuration options.

## Historical Documentation

<details>
<summary>Click to show original documentation</summary>

# zero-nginx

zero-nginx is an Nginx-based Docker image that integrates [Zero](https://github.com/yarlson/zero), a tool for automatically obtaining and managing SSL/TLS certificates from Let's Encrypt. This image simplifies the process of setting up a secure web server with automatic certificate management.

## Features

- Nginx web server with built-in SSL/TLS support
- Automatic SSL/TLS certificate acquisition and renewal using Zero
- Cross-platform compatibility (supports x86_64 and ARM64)
- Easy configuration through environment variables

## Quick Start

To use zero-nginx, you can pull the image from Docker Hub and run it with the following command:

```bash
docker run -d -p 80:80 -p 443:443 \
  -v /path/to/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v /path/to/certs:/etc/nginx/ssl \
  -e DOMAIN=example.com \
  -e EMAIL=user@example.com \
  --name zero-nginx \
  yarlson/zero-nginx
```

Replace `/path/to/nginx.conf`, `/path/to/certs`, `example.com`, and `user@example.com` with your specific configurations.

## Configuration

### Environment Variables

- `DOMAIN`: The domain name for which to obtain/manage SSL certificates
- `EMAIL`: The email address to use for Let's Encrypt account registration

### Volumes

- `/etc/nginx/nginx.conf`: Mount your custom Nginx configuration file here
- `/etc/nginx/ssl`: Directory where SSL certificates will be stored

## Docker Compose

For easier deployment and automatic certificate renewal, you can use Docker Compose. Create a `docker-compose.yml` file with the following content:

```yaml
services:
  nginx:
    image: yarlson/zero-nginx
    container_name: zero-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - certs:/etc/nginx/ssl
    environment:
      - DOMAIN=example.com
      - EMAIL=user@example.com
    networks:
      - web

  certrenewer:
    image: yarlson/zero-nginx
    volumes:
      - certs:/etc/nginx/ssl
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DOMAIN=example.com
      - EMAIL=user@example.com
      - PROXY_CONTAINER_NAME=nginx
    entrypoint: /renew-certificates.sh
    networks:
      - web

volumes:
  certs:

networks:
  web:
```

Then run:

```bash
docker-compose up -d
```

This setup includes two services:

1. `nginx`: The main web server with SSL/TLS support.
2. `certrenewer`: A service that checks for certificate renewals daily and reloads Nginx if a renewal occurs.

## Customization

You can customize the Nginx configuration by mounting your own `nginx.conf` file to `/etc/nginx/nginx.conf` inside the container.

## Important Notes

- The image automatically handles SSL/TLS certificate acquisition and renewal.
- Ensure that your domain's DNS is properly configured to point to the server where you're running this Docker container.
- The container needs to be accessible on both port 80 and 443 for proper functionality.
- The `certrenewer` service uses the Docker socket to reload Nginx after certificate renewal. Ensure this aligns with your security requirements.

## Contributing

Contributions to improve zero-nginx are welcome. Please feel free to submit issues or pull requests to the [zero-nginx repository](https://github.com/yarlson/zero-nginx).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [Zero](https://github.com/yarlson/zero): The SSL/TLS certificate management tool integrated into this image.
</details>
