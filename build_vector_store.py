# build_vector_store.py


import pandas as pd
from langchain_community.vectorstores import FAISS
from langchain_openai import OpenAIEmbeddings
from langchain.docstore.document import Document
from dotenv import load_dotenv
import os

load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")


# 🔹 CSV 로딩
import chardet

with open("/Users/anhyemin/Desktop/대학원/*2025_봄/프렉티컴/Todak_talk/pythonProject/chatbot/data/QA카테고리2.csv", "rb") as f:
    result = chardet.detect(f.read())
    encoding = result['encoding']

df = pd.read_csv("/Users/anhyemin/Desktop/대학원/*2025_봄/프렉티컴/Todak_talk/pythonProject/chatbot/data/QA카테고리2.csv", encoding=encoding)
df.dropna(subset=["Q", "A"], inplace=True)

# 🔹 Q + A 묶어서 context 구성
docs = [
    Document(page_content=f"질문: {row['Q']}\n답변: {row['A']}")
    for _, row in df.iterrows()
]

# ✅ Embedding 생성
embedding = OpenAIEmbeddings(openai_api_key=api_key)

# ✅ FAISS 인덱스 저장
vectorstore = FAISS.from_documents(docs, embedding)
vectorstore.save_local("rag_faiss")

print("✅ 벡터스토어 저장 완료")

def load_vector_store():
    return FAISS.load_local("rag_faiss", embedding, allow_dangerous_deserialization=True)
