# PDF Merge Application

A simple and elegant web application to merge two PDF files into one, built with HTML, CSS, and JavaScript.

## Features

- Select two PDF files from your computer
- Merge them into a single PDF document
- Download the merged PDF instantly
- Clean and responsive user interface
- No server required - runs entirely in the browser
- Secure - all processing happens locally

## How to Use

1. Open `index.html` in your web browser
2. Click on "Select First PDF" and choose your first PDF file
3. Click on "Select Second PDF" and choose your second PDF file
4. Click the "Merge PDFs" button
5. The merged PDF will automatically download to your computer

## Technologies Used

- **HTML5** - Structure and layout
- **CSS3** - Styling and responsive design
- **JavaScript** - Logic and PDF manipulation
- **pdf-lib** - PDF processing library (loaded via CDN)

## File Structure

```
.
├── index.html    # Main HTML file with UI structure
├── style.css     # Stylesheet for the application
├── app.js        # JavaScript logic for PDF merging
└── README.md     # This file
```

## Browser Compatibility

This application works on all modern browsers that support:
- FileReader API
- Blob API
- ES6 JavaScript features

Tested on:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Local Development

Simply open `index.html` in your browser. No build process or server required.

## How It Works

1. The application uses the FileReader API to read the selected PDF files
2. The pdf-lib library loads and parses both PDF documents
3. A new PDF document is created, and all pages from both PDFs are copied into it
4. The merged PDF is saved and offered as a download

## License

Free to use for personal and commercial projects.
