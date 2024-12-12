FROM python:3.9-slim

WORKDIR /app

COPY frontend.py /app/frontend.py

RUN pip install flask requests

EXPOSE 5000

CMD ["python", "frontend.py"]




