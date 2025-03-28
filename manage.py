from fastapi import FastAPI, File, UploadFile
from fastapi.responses import StreamingResponse, JSONResponse
import pdfkit
import uvicorn
import os

# Get APPLICATION_PREFIX from environment or use default "/"
APPLICATION_PREFIX = os.getenv("APPLICATION_PREFIX", "/")

app = FastAPI(
    redoc_url=os.path.join(APPLICATION_PREFIX, "documentation"),
    docs_url=os.path.join(APPLICATION_PREFIX, "swagger"),
    openapi_url=os.path.join(APPLICATION_PREFIX, "openapi.json")
)

# Directory to store generated PDFs
STORAGE_DIR = "storage"
os.makedirs(STORAGE_DIR, exist_ok=True)  # Ensure the storage directory exists

@app.post(os.path.join(APPLICATION_PREFIX, "html-to-pdf/"))
async def convert_html_to_pdf(file: UploadFile = File(...)):
    try:
        # Define storage paths for HTML and PDF files
        html_path = os.path.join(STORAGE_DIR, file.filename)
        pdf_path = os.path.join(STORAGE_DIR, file.filename.replace(".html", ".pdf"))

        # Save uploaded HTML file
        with open(html_path, "wb") as html_file:
            html_file.write(await file.read())

        # Convert HTML to PDF
        pdfkit.from_file(html_path, pdf_path)

        # Stream the PDF file as a response
        def iterfile():
            with open(pdf_path, "rb") as pdf_file:
                yield from pdf_file

        return StreamingResponse(iterfile(), media_type="application/pdf", headers={
            "Content-Disposition": f"attachment; filename={os.path.basename(pdf_path)}"
        })

    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)


if __name__ == "__main__":
    uvicorn.run("manage:app", host="0.0.0.0", port=80, access_log=True, reload=True, workers=2)