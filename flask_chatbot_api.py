#-------챗봇 실행-------#
# python chatbot/flask_chatbot_api.py

# flask_chatbot_api.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from langchain_bot import LangchainRAGBot
from build_vector_store import load_vector_store
import os

app = Flask(__name__)
CORS(app)

# 벡터스토어 로드
retriever = load_vector_store().as_retriever()
openai_api_key = os.environ.get("OPENAI_API_KEY")  # 환경변수 또는 설정 파일로 대체 가능
chatbot = LangchainRAGBot(retriever, openai_api_key)

@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    query = data.get("query", "")

    if not query:
        return jsonify({"error": "Query is empty."}), 400

    try:
        answer = chatbot.ask(query)
        return jsonify({"answer": answer})
    except Exception as e:
        print("🔥 내부 오류 발생:", e)
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)
