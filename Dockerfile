
FROM python:3.13-slim

# 作業ディレクトリの設定
WORKDIR /app

# 必要なパッケージのインストール（ビルド用）
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# 依存ライブラリのコピーとインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ソースコードのコピー
COPY app.py .

# Streamlitのポート(8501)を公開
EXPOSE 8501

# ヘルスチェックの設定（Azure Container Appsなどで役立ちます）
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

# アプリの起動（CORS設定などはAzureの構成に合わせて調整可能）
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
