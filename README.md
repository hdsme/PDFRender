PDFRender is a service built on FastAPI that converts HTML to PDF efficiently.

## Usage with Docker

To use the PDFRender service with Docker, follow these steps:

### Pull the Docker Image
```bash
docker pull hdsme/pdfrender:latest
```

### Run the Docker Container
```bash
docker run -d -p 8089:8089 hdsme/pdfrender:latest
```

This will start the service and make it accessible at `http://localhost:8089`.

### Example API Call
You can send a POST request to the `/html-to-pdf/` endpoint with the HTML content to generate a PDF. For example:
```bash
curl -X 'POST' \
    'http://localhost:8089/html-to-pdf/' \
    -H 'accept: application/json' \
    -H 'Content-Type: multipart/form-data' \
    -F 'file=@evoucher.email.approve_step_request.html;type=text/html'
```

This will save the generated PDF as `output.pdf`.

### Stopping the Container
To stop the running container, use:
```bash
docker ps
docker stop <container-id>
```

Replace `<container-id>` with the ID of the running container.