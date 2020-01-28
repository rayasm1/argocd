ARG REGISTRY=hub.artifactory.gcp.anz
ARG BUILDER_IMAGE=golang:1.13.2-alpine3.10

FROM ${REGISTRY}${REGISTRY:+/}${BUILDER_IMAGE} AS dependency_downloader

ARG GOPROXY=https://artifactory.gcp.anz/artifactory/go
ENV GOPROXY=${GOPROXY}
WORKDIR /src
COPY go.mod ./
RUN go mod download && go mod verify

FROM dependency_downloader AS compiler
# COPY pkg pkg
COPY cmd cmd
RUN CGO_ENABLED=0 go build -ldflags="-w -s" -o /golangapp ./cmd

# https://medium.com/@chemidy/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324
FROM scratch
COPY --from=compiler /golangapp /golangapp
ENTRYPOINT ["/golangapp"]