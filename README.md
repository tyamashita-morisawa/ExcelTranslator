# ExcelTranslator

---

#### 1. Azure へのログインと準備
##### ログイン
az login
##### Container Apps 拡張機能の追加
az extension add --name containerapp --upgrade
##### プロバイダーの登録（初回のみ）
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

---

#### 2. リソースの作成
##### 変数の設定（自分の好きな名前に変えてください）
RESOURCE_GROUP="ICT_AI_ServicesRG"
LOCATION="japaneast"
ACR_NAME="acrmorisawaexceltranslator" # 世界で一意である必要

##### リソースグループ作成
az group create --name $RESOURCE_GROUP --location $LOCATION

##### コンテナレジストリ(ACR)作成
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true

---

#### 3. イメージのビルドとプッシュ
##### Dockerfileがあるディレクトリで実行
az acr build --registry $ACR_NAME --image excel-translator:v1 .

---

### 4. Container Apps へのデプロイ
##### Container Apps 環境の作成
az containerapp env create --name env-exceltranslator --resource-group $RESOURCE_GROUP --location $LOCATION

##### アプリのデプロイ
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

az containerapp create \
  --name exceltranslator-app \
  --resource-group $RESOURCE_GROUP \
  --environment env-exceltranslator \
  --image ${ACR_NAME}.azurecr.io/excel-translator:v1 \
  --target-port 8501 \
  --ingress external \
  --query properties.configuration.ingress.fqdn \
  --env-vars \
    translator-key="7oNO0el9VpEW8HazpLeNQ2Da8CJIY9QxziQD7lp06wJmaRuan0E7JQQJ99BLACi0881XJ3w3AAAbACOG1YL7" \
    translator-region="japaneast" \
    translator-endpoint="https://api.cognitive.microsofttranslator.com"

---

#### 5. 動作確認とコスト最適化の設定
#### コストを抑えるための「スケーリング」設定
az containerapp update \
  --name translator-web \
  --resource-group $RES_GROUP \
  --min-replicas 0 \
  --max-replicas 1




az containerapp update \
  --name exceltranslator-app \
  --resource-group $RESOURCE_GROUP \
  --registry-server ${ACR_NAME}.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD



  az containerapp identity assign \
  --name exceltranslator-app \
  --resource-group $RESOURCE_GROUP \
  --system-assigned


  ACR_ID=$(az acr show --name $ACR_NAME_> --query id --output tsv)
PRINCIPAL_ID=$(az containerapp show --name exceltranslator-app --resource-group $RESOURCE_GROUP --query identity.principalId --output tsv)


az containerapp registry set \
  --name exceltranslator-app \
  --resource-group $RESOURCE_GROUP \
  --server $ACR_NAME.azurecr.io \
  --identity system