#! /bin/bash

dashbordActive="True"

echo "Iniciando a instalação dos pipelines Tekton, por favor aguarde..."

kubectlApplyArquivo() {
    local arquivo="$1"
    local tempo="$2"

    if ! kubectl apply -f "${arquivo}"; then
        echo "Erro ao aplicar o arquivo: ${arquivo}"
        exit 1
    fi

    echo "[+] Aguardando ${tempo} segundos para os pods subirem"
    sleep "${tempo}"
    echo "[!] Exibindo novos elementos:"
    kubectl get pods -n tekton-pipelines || exit 1
    echo ""
}

if ! command -v kubectl &> /dev/null; then
    echo "kubectl não encontrado, por favor instale-o antes de continuar."
    exit 1
fi

kubectlApplyArquivo "https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.52.1/release.yaml" 30
kubectlApplyArquivo "https://storage.googleapis.com/tekton-releases/triggers/previous/v0.25.0/release.yaml" 15
kubectlApplyArquivo "https://storage.googleapis.com/tekton-releases/triggers/previous/v0.25.0/interceptors.yaml" 15

if [ "${dashbordActive}" == "True" ]; then
    kubectlApplyArquivo "https://storage.googleapis.com/tekton-releases/dashboard/previous/v0.40.1/release.yaml" 15
fi

echo "[!] Processo de instalação finalizado com sucesso."