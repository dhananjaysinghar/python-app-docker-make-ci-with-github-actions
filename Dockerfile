#FROM python:3.12-slim
#WORKDIR /app
#COPY requirements.txt .
#RUN pip install --no-cache-dir -r requirements.txt
#COPY . .
#EXPOSE 8501
#CMD ["streamlit", "run", "src/app_1/handler.py"]
#
FROM python:3.12-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends unzip
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./dist/package/applications.zip /app/
RUN unzip applications.zip
WORKDIR /app
EXPOSE 8501
CMD ["streamlit", "run", "app_1/handler.py"]

#  docker build -t my-python-app .
# docker run --name my-python-app  -p 8501:8501 -d my-python-app



