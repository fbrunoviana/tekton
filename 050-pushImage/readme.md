# 050 Decolando uma Imagem

Neste guia, vamos aprender a construir um pacote e criar uma imagem de container usando Tekton, e depois enviá-la para o Docker Hub.

## Preparativos

Antes de iniciar, é necessário entender o processo de criação da imagem e o envio para o registro (registry).

### Configurando o Docker Hub

1. Crie uma conta no [Docker Hub](https://hub.docker.com/) se ainda não tiver uma.
2. Crie um secret e um ServiceAccount no Kubernetes, semelhante ao feito no exemplo `040-buildDeUmGitPrivado`. Caso não tenha.

    ```bash
    kubectl create -f 050-pushImage/k8s/052-secrectEServiceAccount.yaml 
    ```
3. Crie um serviceAccount para linkar o secret com o ServiceAccount do Tekton. Caso não tenha.
    ```bash
    kubectl create -f 050-pushImage/k8s/053-serviceAccount.yaml 
    ```
### Adicionando o Step de Build e Push

Adicionei o seguinte step na task:

```yaml
    - name: build-and-push-image
      securityContext:
        privileged: true
      image: quay.io/buildah/stable
      script: |
        #!/usr/bin/env bash
        buildah --storage-driver=$STORAGE_DRIVER bud --layers -t $DESTINATION_IMAGE $CONTEXT_DIR
        buildah --storage-driver=$STORAGE_DRIVER push $DESTINATION_IMAGE docker://$DESTINATION_IMAGE
      env:
        - name: DESTINATION_IMAGE
          value: $(params.destinationImage)
        - name: CONTEXT_DIR
          value: "/workspace/source/$(params.contextDir)"
        - name: STORAGE_DRIVER
          value: $(params.storageDriver)
      workingDir: "/workspace/source/$(params.contextDir)"
      volumeMounts:
        - name: varlibc
          mountPath: /var/lib/containers
  volumes:
    - name: varlibc
      emptyDir: {}
```

Este step utiliza o Buildah para construir e enviar a imagem Docker para um repositório.

### Preparação do Repositório

Verifique se o repositório contém um Dockerfile. Exemplo:

```Dockerfile
FROM registry.access.redhat.com/ubi8/openjdk-11
COPY target/spring-boot-complete-0.0.1-SNAPSHOT.jar /deployments/
```

### Executando a Task

1. Substitua `<SEU USUÁRIO DO DOCKERHUB>` e `<SUA SENHA DO DOCKERHUB>` pelas suas credenciais do Docker Hub e aplique o primeiro comando para criar o secret e o ServiceAccount:

    ```bash
    kubectl create -f 050-pushImage/k8s/051-secrectEServiceAccount.yaml
    ```

2. Aplique o comando para criar a task:

    ```bash
    kubectl create -f 050-pushImage/k8s/054-buildarDoGit.yaml
    ```

3. Inicie a task com o seguinte comando, substituindo `<SEU USUARIO DO GITLAB>` e `<SEU PROJETO>` conforme necessário:

    ```bash
    tkn task start build-push-app \
    --serviceaccount='tekton-registry-sa' \
    --param url='https://gitlab.com/<SEU USUARIO DO GITLAB>/<SEU PROJETO>.git' \
    --param destinationImage='docker.io/<SEU USUARIO DO DOCKERHUB>/tekton-greeter:latest' \
    --param contextDir='' \
    --workspace name=source,emptyDir="" \
    --use-param-defaults \
    --showlog
    ```

### Exercícios

1. **Criação de uma Task com Docker**: Use a Task `040-buildDeUmGitPrivado` como base, altere o nome e o comando para utilizar `docker build` e `docker push`.

2. **Execução com Docker Hub**: Execute a task modificada com o `destinationImage` apontando para o seu Docker Hub e verifique a imagem.

3. **Execução com GitLab**: Execute a task apontando para o GitLab e verifique se a imagem foi gerada corretamente.