# Tekton Pipeline

Chega um momento que criar varias tasks para executar em uma ordem especifica, acaba desorganizando o seu projeto, para organizar suas tarefas, basta criar uma pipeline.

Da mesma forma que no mundo real, você não cria um replicaset ou um pod diretamente, você não cria tasks e steps sozinhos. Você até pode fazer isso, mas te garanto que você não quer fazer isso.

Vamos criar uma pipeline para compilar um pacote e deploy de uma aplicacão k8s com tekton.

Tekton pipelines, é uma coleção de tarefas que você pode definir e compor em uma ordem especifica de execução.

Tekton pipelines suportam parametros e mecanismos diferentes das tasks.

## Sobre o laboratorio

Vamos reultilizar alguns arquivos para os laboratorios, tomei a liberdade de organiza-los em: `070-pipelinesBuilds/050-k8s` e `070-pipelinesBuilds/060-k8s`.

Em `05-k8s/051-secrectEServiceAccount.yaml`: você precisa adicionar o usuario e senha do dockerhub para o deployer do tekton.

Depois disso: `kubectl create -f '070-pipelinesBuilds/050-k8s'` e `kubectl create -f '070-pipelinesBuilds/060-k8s'`

e voila. :)

#### Observacão:
Se faz tempo que você executou as tarefas 050 e 060, revise os arquivos `050-k8s` e `060-k8s` antes de prosseguir.

## Pipeline

`#1` Vamos passar quatro parametros. 

1. `GIT_REPO`: URL do repositório Git (string).
2. `GIT_REF`: Referência Git (branch/tag) (string).
3. `DESTINATION_IMAGE`: Imagem de destino para a build (string).
4. `SCRIPT`: Script para execução do kubectl.

`#2` e `#3` Tarefas:

Essas seções especificam tarefas principais:

`build-push-app`:

1. Constrói e faz um push a aplicação.
2. Utiliza os parâmetros `GIT_REPO`, `GIT_REF` e `DESTINATION_IMAGE`.
3. Usa o Workspace: source.

`deploy-app`:

1. Realiza a implantação, vulgo deploy usando o script fornecido em `SCRIPT`.
2. `runAfter: #4`: Executa após a conclusão da tarefa `build-push-app`.
3. Usa o Workspace: source.

`#5` Workspace utilizado pelas tarefas.

Apresentações oficialmente feitas, vamos executar o comando: `kubectl get tasks`, o resultado deve ser similar ao seguinte:

```
build-push-app       1h
kubectl              1h
```

Em resumo o nosso pipeline executa essas duas tarefas em uma ordem especifica. Criaremos o objeto pipeline com o comando: `kubectl create -f '070-pipelinesBuilds/k8s/071-pipelines.yaml'`. Para exibilas:

```sh
kubectl get pipeline                                                  
NAME                          AGE
tekton-greeter-pipeline       1h
```
Uma alternativa seria usar o `tkn pipeline ls` ou sua forma mais abreviada: `tkn p ls`.

### Para executar uma Pipeline

Bom, para executar uma pipeline no tekton, você pode fazer isso na linha de comando do tkn ou pode criar um objeto `pipelineRun`, é mais aconselhavel criar um objeto pipelineRun.

`070-pipelinesBuilds/k8s/072-pipelineRun.yaml`

O `PipelineRun` especifica como a pipeline deve ser executada, incluindo parâmetros e referências necessárias.

- **API Version**: tekton.dev/v1beta1
- **Kind**: PipelineRun
- **Nome (gerado)**: tekton-greeter-pipeline-run-, logo todas as execuções do pipeline `tekton-greeter-pipeline` terão o prefixo `tekton-greeter-pipeline-run-`, como por exemplo: `tekton-greeter-pipeline-run-pczwj`.

- **Service Account**: Utiliza `tekton-deployer-sa` para permissões de execução.
- **Referência do Pipeline**: `tekton-greeter-pipeline`.

O `PipelineRun` é configurado com os seguintes parâmetros:
1. `GIT_REPO`: `https://gitlab.com/fbrunoviana/gs-spring-boot.git`.
2. `GIT_REF`: `main`.
3. `DESTINATION_IMAGE`: `docker.io/c40s/tekton-greeter3:latest`.
4. `SCRIPT`: `kubectl create deploy tekton-greeter --image=docker.io/c40s/tekton-greeter:latest`.

- **source**: Define um workspace temporário para a execução (`emptyDir: {}`).

Para executarmos precisamos primeiramente criar o serviceAccount: 

```shell
kubectl create serviceaccount tekton-deployer-sa
kubectl patch serviceaccount tekton-deployer-sa -p '{"secrets": [{"name":"dockerhub-credentials"}]}'
```
Depois disso: `kubectl create -f '070-pipelinesBuilds/k8s/072-pipelineRun.yaml'`

Para verificar podemos dar o comando: `tkn pipelinerun ls` ou sua forma abreviada `tkn pr ls `

Podemos também acompanhar os logs do pipelineRun: `tkn pipelinerun -f logs tekton-greeter-pipeline-run-rg28q`

Observe se a sua pipeline foi executada com sucesso: 

```bash
$ tkn pr ls            
NAME                                    STARTED       DURATION   STATUS
tekton-greeter-pipeline-run-pczwj       1 hour ago    2m7s       Succeeded
```

### Introdução ao tekton hub

Com certeza você percebeu que construir uma pipeline pode ser muito complexo, pensando nisso você pode usar o tekton hub.

Definitivamente o https://hub.tekton.dev/ é o nosso parque de diversão, podemos econimizar tempo e codigo. 

Vamos instalar alguns operations, na sua linha de comando execute:

```bash
tkn hub install task git-clone
tkn hub install task maven
tkn hub install task buildah
tkn hub install task kubernetes-actions
```

Adicinamos poderes ao nosso tekton, utilizando o tekton hub. 

Resultando em: `070-pipelinesBuilds/k8s/074-pipeline-hub.yaml`

Em `parms` não vemos nada de novo. 
Em `tasks` reformulamos a pipeline para usar o que instalamos do tekton hub.

- fetch-repo: Clona o repositório Git.
- build-app: Constrói a aplicação usando Maven.
- build-push-image: Constrói e push a imagem Docker usando Buildah.
- deploy: Realiza a implantação usando o script fornecido.

Você pode até deletar as taks do exemplo 050 e 060, com o comando:

```bash
kubectl delete task build-push-app
kubectl delete task kubectl
```

### PipelineRun do Hub

Destaco que antes de você sair executando coisas novas do tekton hub é necessário criar um ler cada um dos operations, como por exemplo o git-clone:

```yaml
  podTemplate:
    securityContext:
      fsGroup: 65532
```

O codigo acima inserido na pipeleineRun é especificada na propia documentacão. 

Antes de colocarmos para rodar, precisamos criar um Persistente Volume, para manter persistidos os dados. 

```bash
kubectl create -f '070-pipelinesBuilds/k8s/073-pv.yaml'
```

Agora é criar o pipelineRun: 

```shell
kubectl create -f '070-pipelinesBuilds/k8s/074-pipeline-hub.yaml'
kubectl create -f '070-pipelinesBuilds/k8s/075-pipelineRun-hub.yaml'
```

Para verificar o pipelineRun: `tkn pr ls` e `tkn pr logs tekton-greeter-pipeline-run-hub-rg28q -f`
