FROM ubuntu:oracular-20240617
# Add metadata labels
LABEL maintainer="S.Kiran Kumar <sappogukirankumar7@gmail.com>"
LABEL description="A Docker container for Wisecow application"

# Set the working directory
WORKDIR /wisecowapp

# Install the application dependencies
RUN apt-get update && apt-get install -y fortune cowsay netcat-openbsd && \
    cp /usr/games/cowsay /usr/local/bin/cowsay && \
    cp /usr/games/fortune /usr/local/bin/fortune

# Copy in the source code
COPY wisecow.sh .

# Copy TLS certificates
COPY tls.crt /etc/ssl/tls.crt
COPY tls.key /etc/ssl/tls.key

EXPOSE 4499

RUN chmod +x wisecow.sh

CMD ["./wisecow.sh"]
