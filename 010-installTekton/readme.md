# Instalação do Tekton

Tekton é uma poderosa solução de  CI/CD nativa para Kubernetes, permitindo a automação de pipelines de software em um cluster Kubernetes.

## Componentes do Tekton

- **Task**: Representa um conjunto de passos executados em um mesmo container. Cada passo é um comando ou script. As Tarefas são parametrizáveis e podem interagir com outros sistemas ou Tarefas através de recursos de entrada e saída.

- **Pipeline**: Uma sequência de tasks usada para construir ou implantar um projeto.

- **TaskRun**: A execução efetiva de uma Task.

- **PipelineRun**: A execução efetiva de um Pipeline.

- **Triggers**: Utilizados para iniciar Pipelines automaticamente em resposta a eventos externos, como commits em um repositório Git ou atualizações em um pull request. 

## Instalação

### Instalar o Tekton Pipelines

Em seu cluster kubernetes, instale o Tekton Pipelines:

Execute o seguinte comando para instalar a versão mais recente do Tekton Pipelines:

```shell
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

Verifique a instalação monitorando os pods:

```shell
kubectl get pods -w -n tekton-pipelines
```

### Instalar o Tekton Triggers

Para instalar o Tekton Triggers, use:

```shell
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
```

Confirme a instalação:

```shell
kubectl get pods -w -n tekton-pipelines
```

### Instalar o Tekton Dashboard

Instale o Dashboard para uma interface visual:

```shell
kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml
```

Monitore a instalação:

```shell
kubectl get pods -w -n tekton-pipelines
```

Para acessar localmente:

```shell
kubectl port-forward svc/tekton-dashboard 9097:9097 -n tekton-pipelines
```

### Ferramentas Adicionais

Para instalar o CLI do Tekton:

```zsh
brew install tektoncd-cli
```

### Acesso em Provedores de Nuvem

Para acessar o Dashboard em um ambiente de nuvem:

```bash
kubectl edit svc -n tekton-pipelines tekton-dashboard
```

Modifique: `type: ClusterIP` para `type: LoadBalancer`.

### Meu script de instalação

Eu usei um GKE, então varias vezes precisei apagar o cluster para economizar dinheiro e instala-lo, crie um script de instalacão bem basico, em shell script. Disponivel em: 011-install.sh