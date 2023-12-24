# 060 - Implementando o CD com Tekton

Este guia demonstra como realizar o Continuous Deployment (CD) de uma aplicação usando o Tekton. Até agora, focamos na parte de Integração Contínua (CI). Vamos agora avançar para o CD.

### 1. Criando a Task do kubectl

O primeiro passo envolve a criação de uma Task que execute o `kubectl`. Podemos utilizar uma versão pré-compilada disponibilizada pelo Bitnami ou escolher outra opção de sua preferência. Também é possível criar uma customizada usando, por exemplo, a imagem do Alpine.

```bash
kubectl apply -f k8s/061-kubectl.yaml
```

### 2. Criando o ServiceAccount

É necessário criar um ServiceAccount que será usado pela Task para executar comandos no cluster.

```bash
kubectl create serviceaccount tekton-deployer-sa
```

### 3. Configurando Role e RoleBinding

Para que o ServiceAccount tenha as permissões necessárias, criaremos uma Role e um RoleBinding.

```bash
kubectl apply -f k8s/062-role.yaml
kubectl apply -f k8s/063-rolebinding.yaml
```

### 4. Executando com TaskRun

Diferente de executar uma Task diretamente, usaremos um `Tekton TaskRun` para iniciar a execução. Ao aplicar o TaskRun no cluster, a Task será automaticamente executada.

```bash
kubectl apply -f k8s/064-taskrun.yaml
```

### 5. Verificando a Execução da TaskRun

Para verificar as TaskRuns que foram criadas, use:

```bash
kubectl get taskrun
```

Ou, para uma visualização mais detalhada com o CLI do Tekton:

```bash
tkn taskrun ls
```

### 6. Acompanhando os Logs

Para acompanhar o progresso da TaskRun em tempo real, observe os logs com:

```bash
tkn taskrun logs
```

### Resumo

Esse guia demostra como criar uma task que executa o `kubectl create deploy tekton-greeter --image=docker.io/c40s/tekton-greeter:latest` em um cluster kubernetes.