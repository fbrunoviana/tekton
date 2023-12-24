# Exemplo Simples com Tekton

## Pré-requisitos

- Cluster Kubernetes configurado.
- `kubectl` instalado.
- Script de instalação do Tekton (`010-installTekton/011-install.sh`) executado.
- CLI do Tekton (`tkn`) instalado.

## Configuração Inicial

Clone o repositório necessário e navegue até o diretório correto:

```bash
git clone [URL_DO_REPOSITORIO]
cd [NOME_DO_DIRETORIO]
```

## Entendendo a Step `k8s/021-helloWorld.yaml`

A step é a unidade fundamental em uma Task do Tekton. Vamos analisar a step definida em `k8s/021-helloWorld.yaml`:

```yaml
    - image: ubuntu #1
      name: exibeguelo #2
      command: #3
        - /bin/bash
      args: #4
        - '-c'
        - 'echo Guelo Queima'
```

### Imagem

No comentário `#1`, especificamos a imagem Docker a ser usada pelo container que executa a step.

### Nome

No comentário `#2`, atribuímos um nome à step. O nome deve ser descritivo e estar relacionado à sua função. Utilize apenas letras minúsculas, separadas por hífens (`-`) ou pontos (`.`).

### Comando e Argumentos

O comando e os argumentos definem o que será executado dentro do container:

```yaml
      command: 
        - /bin/bash #3
      args:
        - '-c'      #4
        - 'echo Guelo Queima'
```

Aqui, usamos o `bash` para executar o comando `echo Guelo Queima`. Os argumentos `-c` instruem o bash a executar o comando fornecido.

## Gerenciando a Task

### Criação

Crie a task com o comando:

```bash
kubectl create -f k8s/021-helloWorld.yaml
```

### Verificação

Confira se a task foi criada corretamente:

```bash
kubectl get tasks
```

### Execução

Execute a task e veja o log:

```bash
tkn task start guelo --showlog
```

### Limpeza (Opcional)

Após a execução, se desejar remover a task:

```bash
kubectl delete task guelo
```