FROM alpine:3.12
WORKDIR /home/work
RUN apk add --no-cache gcc libc-dev
CMD [ "/bin/ash" ]