# Instructions from: https://docs.docker.com/language/python/build-images/
FROM python:3-slim

# Set the working directory
WORKDIR /app

# Fulfill requirements
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# Add code
COPY . .

# Set environment variables
ENV FLASK_APP=api.py
ENV FLASK_RUN_PORT=8000

# Expose the application's port
EXPOSE 8000

# Check
RUN apt update && apt install -y curl
HEALTHCHECK CMD curl --fail http://localhost:${FLASK_RUN_PORT}/_health || exit 1

# Run the application
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]
