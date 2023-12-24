# Criando uma Task e Compilando um Projeto do Git com Tekton

## Buildando Localmente

Antes de usar o Tekton para buildar aplicações, vamos entender o processo localmente. Neste exemplo, vamos compilar uma aplicação Java simples.

1. Clone o repositório de exemplo:

   ```bash
   git clone https://github.com/spring-guides/gs-spring-boot.git
   ```

2. Entre no diretório do projeto:

   ```bash
   cd gs-spring-boot/complete
   ```

3. Compile o projeto com Maven:

   ```bash
   mvn clean package
   ```

Após a compilação, você deve ver uma saída indicando sucesso. Verifique o artefato gerado com:

```bash
ls -l target/spring-boot-complete-0.0.1-SNAPSHOT.jar
```

## Buildando com o Tekton

Agora, vamos fazer o mesmo processo usando o Tekton no Kubernetes.

1. **Defina a Task do Tekton**: Crie um arquivo YAML para definir a Task do Tekton que irá compilar o projeto Java. Exemplo:

   ```yaml
   # Arquivo: build-app-task.yaml
   apiVersion: tekton.dev/v1beta1
   kind: Task
   metadata:
     name: build-app
   spec:
     workspaces:
       - name: source
     steps:
       - name: build
         image: maven:3-alpine
         command:
           - mvn
         args:
           - clean
           - package
   ```

2. **Crie a Task**: Aplique a Task no seu cluster Kubernetes:

   ```bash
   kubectl create -f 030-buildarDoGit/k8s/031-buildarDoGit.yaml
   ```

3. **Execute a Task**: Inicie a Task com o CLI do Tekton:

   ```bash
   tkn task start build-app --workspace name=source,emptyDir="" --showlog
   ```

   Este comando inicia a Task `build-app`, utilizando um workspace temporário e exibindo o log do processo.

### Observações

- Assegure-se de que o Tekton esteja corretamente configurado em seu cluster Kubernetes.
- Adapte os passos conforme necessário para adequar-se ao seu ambiente e necessidades específicas.
