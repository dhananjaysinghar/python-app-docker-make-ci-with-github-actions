# APPROACH-1 File based deployment
#FROM python:3.12-slim
#WORKDIR /app
#COPY requirements.txt .
#RUN pip install --no-cache-dir -r requirements.txt
#COPY . .
#EXPOSE 8501
#CMD ["streamlit", "run", "src/app_1/handler.py"]




# APPROACH-2 ZIP based deployment
#FROM python:3.12-slim
#WORKDIR /app
#RUN apt-get update && apt-get install -y --no-install-recommends unzip
#COPY requirements.txt .
#RUN pip install --no-cache-dir -r requirements.txt
#COPY ./dist/package/applications.zip /app/
#RUN unzip applications.zip
#WORKDIR /app
#EXPOSE 8501
#CMD ["streamlit", "run", "app_1/handler.py"]



# APPROACH-3 Make command based
#FROM python:3.12-slim
#WORKDIR /app
#RUN apt-get update && apt-get install -y --no-install-recommends \
#    make \
#    zip \
#    unzip \
#    && rm -rf /var/lib/apt/lists/*
#
#RUN python -m pip install --upgrade pip && \
#    python -m pip install virtualenv
#
#RUN python -m virtualenv venv
#ENV PATH="/app/venv/bin:${PATH}"
#
#RUN python -m pip install --upgrade poetry
##RUN poetry add streamlit
#
#COPY . /app/
#WORKDIR /app
#
#RUN ls -ltra /app
#RUN make dist-clean clean build ssap package
#
#WORKDIR /app
#
#COPY dist/package/applications.zip /app/
#RUN unzip applications.zip
#
#RUN pip install --no-cache-dir -r requirements.txt
#
#EXPOSE 8501
#CMD ["streamlit", "run", "app_1/handler.py"]
#




# APPROACH-4 Make command based memory optimized
FROM python:3.12-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir poetry
COPY pyproject.toml poetry.toml /app/
RUN poetry install --no-dev --no-interaction --no-ansi

COPY . /app/
RUN make dist-clean clean build ssap package

FROM python:3.12-slim AS final
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:${PATH}"
# OR
#COPY --from=builder /app/requirements.txt /app/requirements.txt
#RUN pip install --no-cache-dir -r requirements.txt

COPY --from=builder /app/dist/package/applications.zip /app/
RUN unzip applications.zip && rm applications.zip

#RUN useradd -m nonrootuser
#RUN chown -R nonrootuser:nonrootuser /app
#USER nonrootuser

EXPOSE 8501
CMD ["streamlit", "run", "app_1/handler.py"]


