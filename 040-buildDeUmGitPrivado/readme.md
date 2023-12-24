# Build de Repositório Privado com Tekton

Neste guia, vamos aprender como configurar o Tekton para fazer build de um aplicativo a partir de um repositório Git privado.

## Preparação

### Fork do Repositório no GitLab

1. Crie uma conta no [GitLab](https://gitlab.com/users/sign_in).
2. Acesse [meu projeto](https://gitlab.com/fbrunoviana/gs-spring-boot.git).
3. Faça um fork para sua conta.
4. Escolha seu username e defina o nível de visibilidade como privado.
5. Confirme o fork do projeto.

## Configuração do Kubernetes

### Criando o Secret

Para autenticação no GitLab, crie um Kubernetes Secret:

1. Nomeie o Secret (`gitlab-secret`).
2. Adicione uma annotation apontando para o GitLab.
3. Escolha o tipo de autenticação (basic-auth).
4. Insira seu username e senha do GitLab.

Criação via YAML:

```bash
kubectl create -f 040-buildDeUmGitPrivado/k8s/041-secret.yaml
```

Ou diretamente via CLI:

```bash
kubectl create secret generic gitlab-secret \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=<USERNAME> \
  --from-literal=password=<PASSWORD>

kubectl annotate secret git-secret tekton.dev/git-0=https://gitlab.com
```

### Criando o ServiceAccount

Crie um ServiceAccount que referencia o Secret:

```yaml
apiVersion: v1 
kind: ServiceAccount 
metadata:
  name: tekton-bot-sa 
secrets:
  - name: gitlab-secret
```

Comando para criação:

```bash
kubectl create -f 040-buildDeUmGitPrivado/k8s/042-serviceAccount.yaml
```

Ou via CLI:

```bash
kubectl create serviceaccount tekton-bot-sa
kubectl patch serviceaccount tekton-bot-sa -p '{"secrets":[{"name": "gitlab-secret"}]}'
```

### Crie a build

```bash
kubectl create -f 040-buildDeUmGitPrivado/k8s/043-buildarDoGit.yaml 
```

## Executando a Build com Tekton

Use o seguinte comando para iniciar a build:

```bash
tkn task start build-app \
  --serviceaccount=tekton-bot-sa \
  --param url='https://gitlab.com/fbrunoviana/gs-spring-boot-privado.git' \
  --param contextDir='' \
  --workspace name=source,emptyDir="" \
  --showlog
```

Substitua a URL do parâmetro pelo endereço do seu projeto no GitLab.

## Exercícios

Estes exercícios ajudarão a reforçar o aprendizado:

### Pré-Exercício

- Gere um par de chaves SSH e adicione ao GitLab.

### Exercício 1

Crie um Secret para armazenar credenciais SSH do GitLab.

### Exercício 2

Crie um ServiceAccount que referencia o Secret do Exercício 1.

### Exercício 3

Crie e execute uma Task para clonar e construir um projeto do GitLab usando SSH.

