FROM golang:1.15-alpine as builder

RUN apk --no-cache add git

ENV REPOSITORY github.com/ishiDACo/vulsrepo

COPY . $GOPATH/src/$REPOSITORY
RUN cd $GOPATH/src/$REPOSITORY/server \
    && go mod download \
    && go build -ldflags "-s -w" -o $GOPATH/bin/vulsrepo-server

RUN mkdir /vulsrepo \
    && mv $GOPATH/src/$REPOSITORY/server/vulsrepo-config.toml.sample /vulsrepo/vulsrepo-config.toml \
    && mv $GOPATH/src/$REPOSITORY /vulsrepo/www \
    && rm -rf /vulsrepo/www/.git* /vulsrepo/www/server \
    && sed -i -e 's/vulsrepo/www/g' /vulsrepo/vulsrepo-config.toml \
    && sed -i -e 's/home\/vuls-user/vulsrepo/g' /vulsrepo/vulsrepo-config.toml \
    && sed -i -e 's/\/opt//g' /vulsrepo/vulsrepo-config.toml

FROM alpine:3.11.7

LABEL maintainer="hikachan sadayuki-matsuno usiusi360 ishiDACo"

COPY --from=builder /go/bin/vulsrepo-server /usr/local/bin/
COPY --from=builder /vulsrepo /vulsrepo

VOLUME /vuls
WORKDIR /vulsrepo

EXPOSE 5111
CMD ["vulsrepo-server"]
