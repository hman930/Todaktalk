from langchain.chains import RetrievalQA
from langchain_community.vectorstores import FAISS
from langchain_community.chat_models import ChatOpenAI
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.prompts import PromptTemplate
from langchain.document_loaders import TextLoader
from langchain.text_splitter import CharacterTextSplitter
import os

class LangchainRAGBot:
    def __init__(self, retriever, openai_api_key):
        self.retriever = retriever
        self.api_key = openai_api_key
        self.llm = ChatOpenAI(temperature=0.3, model_name="gpt-4", openai_api_key=self.api_key)

    def ask(self, question):
        qa = RetrievalQA.from_chain_type(
            llm=self.llm,
            retriever=self.retriever,
            return_source_documents=True,
            chain_type="stuff"
        )

        rag_result = qa.invoke({"query": question})
        rag_answer = rag_result["result"]

        prompt = f"""
    아래는 유저 질문에 대한 검색 결과입니다. 사용자에게 이해하기 쉽도록 조리 있고 간결하게 정리해 주세요. 친절한 어투로 3~5문장으로 정리해 주세요.

    [검색 결과]
    {rag_answer}

    [질문]
    {question}

    [정리된 답변]
    """
        response = ChatOpenAI(
            model_name="gpt-4",
            temperature=0.5,
            openai_api_key=self.api_key
        ).invoke(prompt)

        return response.content
