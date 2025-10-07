# Script para destruir todos os recursos da infraestrutura Fast Food (Terraform)
# Uso: Execute no PowerShell na pasta do projeto de infraestrutura

Write-Host "[!] ATENÇÃO: Este comando irá destruir TODOS os recursos provisionados (EKS, Lambda, API Gateway, Cognito, RDS, etc)."
Write-Host "Confirme que está no diretório correto antes de continuar."

$confirm = Read-Host "Digite 'sim' para continuar e destruir tudo" 
if ($confirm -ne "sim") {
    Write-Host "Operação cancelada. Nenhum recurso foi destruído."
    exit 0
}

# Executa o comando de destruição do Terraform
terraform destroy -var-file=dev.tfvars -auto-approve

Write-Host "\n---\nTodos os recursos foram destruídos (se o comando foi executado com sucesso)."
