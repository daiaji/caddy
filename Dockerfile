FROM caddy:builder-alpine AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM alpine

RUN apk --update add --no-cache ca-certificates curl
RUN set -eux; \
	mkdir -p \
		/etc/caddy \
		/usr/share/caddy \
	; \
	curl -fsSLo /etc/caddy/Caddyfile "https://raw.githubusercontent.com/caddyserver/dist/master/config/Caddyfile"; \
	curl -fsSLo /usr/share/caddy/index.html "https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html"
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN chmod +x /usr/bin/caddy; caddy version; caddy list-modules
	
# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/docker-library/golang/blob/1eb096131592bcbc90aa3b97471811c798a93573/1.14/alpine3.12/Dockerfile#L9
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

EXPOSE 80 443 2019

ENTRYPOINT ["caddy"]
CMD ["run", "--config", "/root/.config/caddy/Caddyfile", "--adapter", "caddyfile"]
