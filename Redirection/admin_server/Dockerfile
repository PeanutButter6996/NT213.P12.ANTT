FROM python:3.9-slim

WORKDIR /app

COPY backend.py /app/backend.py

RUN pip install flask

EXPOSE 80

CMD ["python", "backend.py"]




