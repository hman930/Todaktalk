#-------TDF-IDF&Open AI api hybrid-------#
# hybrid_bot.py

from langchain.vectorstores import FAISS
from langchain.chat_models import ChatOpenAI
from langchain.chains import RetrievalQA
import os

class HybridBot:
    def __init__(self, retriever, api_key):
        self.retriever = retriever
        self.api_key = api_key
        self.llm = ChatOpenAI(model_name="gpt-4", temperature=0.3, openai_api_key=api_key)

    def ask(self, question):
        rag_chain = RetrievalQA.from_chain_type(
            llm=self.llm,
            retriever=self.retriever,
            return_source_documents=True,
            chain_type="stuff"
        )

        rag_result = rag_chain.invoke({"query": question})  # ✅ 변경
        raw_answer = rag_result["result"]  # ✅ 추출

        # GPT 후처리
        prompt = f"""
    아래는 유저 질문에 대한 검색 결과입니다. 사용자에게 이해하기 쉽도록 조리 있고 간결하게 정리해 주세요. 친절한 어투로 3~5문장으로 정리해 주세요.

    [검색 결과]
    {raw_answer}

    [질문]
    {question}

    [정리된 답변]
    """
        post_llm = ChatOpenAI(model_name="gpt-4", temperature=0.5, openai_api_key=self.api_key)
        response = post_llm.invoke(prompt)

        return response.content
