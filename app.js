// Get DOM elements
const pdf1Input = document.getElementById('pdf1');
const pdf2Input = document.getElementById('pdf2');
const file1Name = document.getElementById('file1-name');
const file2Name = document.getElementById('file2-name');
const mergeBtn = document.getElementById('mergeBtn');
const resetBtn = document.getElementById('resetBtn');
const statusDiv = document.getElementById('status');
const progressDiv = document.getElementById('progress');

// Store selected files
let selectedPDF1 = null;
let selectedPDF2 = null;

// Event listeners for file inputs
pdf1Input.addEventListener('change', function(e) {
    const file = e.target.files[0];
    if (file && file.type === 'application/pdf') {
        selectedPDF1 = file;
        file1Name.textContent = file.name;
        checkBothFilesSelected();
        showStatus('First PDF selected: ' + file.name, 'info');
    } else {
        showStatus('Please select a valid PDF file', 'error');
        pdf1Input.value = '';
    }
});

pdf2Input.addEventListener('change', function(e) {
    const file = e.target.files[0];
    if (file && file.type === 'application/pdf') {
        selectedPDF2 = file;
        file2Name.textContent = file.name;
        checkBothFilesSelected();
        showStatus('Second PDF selected: ' + file.name, 'info');
    } else {
        showStatus('Please select a valid PDF file', 'error');
        pdf2Input.value = '';
    }
});

// Check if both files are selected
function checkBothFilesSelected() {
    if (selectedPDF1 && selectedPDF2) {
        mergeBtn.disabled = false;
        showStatus('Both PDFs selected. Ready to merge!', 'success');
    }
}

// Reset functionality
resetBtn.addEventListener('click', function() {
    pdf1Input.value = '';
    pdf2Input.value = '';
    file1Name.textContent = '';
    file2Name.textContent = '';
    selectedPDF1 = null;
    selectedPDF2 = null;
    mergeBtn.disabled = true;
    statusDiv.textContent = '';
    statusDiv.className = 'status-message';
    progressDiv.style.display = 'none';
});

// Show status message
function showStatus(message, type) {
    statusDiv.textContent = message;
    statusDiv.className = 'status-message ' + type;
}

// Show progress
function showProgress(show) {
    progressDiv.style.display = show ? 'block' : 'none';
}

// Merge PDFs
mergeBtn.addEventListener('click', async function() {
    if (!selectedPDF1 || !selectedPDF2) {
        showStatus('Please select both PDF files', 'error');
        return;
    }

    try {
        // Disable button and show progress
        mergeBtn.disabled = true;
        showProgress(true);
        showStatus('Merging PDFs...', 'info');

        // Read files as array buffers
        const pdf1Bytes = await readFileAsArrayBuffer(selectedPDF1);
        const pdf2Bytes = await readFileAsArrayBuffer(selectedPDF2);

        // Load PDFs using pdf-lib
        const pdf1Doc = await PDFLib.PDFDocument.load(pdf1Bytes);
        const pdf2Doc = await PDFLib.PDFDocument.load(pdf2Bytes);

        // Create a new PDF document
        const mergedPdf = await PDFLib.PDFDocument.create();

        // Copy pages from first PDF
        const pages1 = await mergedPdf.copyPages(pdf1Doc, pdf1Doc.getPageIndices());
        pages1.forEach((page) => {
            mergedPdf.addPage(page);
        });

        // Copy pages from second PDF
        const pages2 = await mergedPdf.copyPages(pdf2Doc, pdf2Doc.getPageIndices());
        pages2.forEach((page) => {
            mergedPdf.addPage(page);
        });

        // Save the merged PDF
        const mergedPdfBytes = await mergedPdf.save();

        // Create blob and download
        const blob = new Blob([mergedPdfBytes], { type: 'application/pdf' });
        const url = URL.createObjectURL(blob);

        // Create download link
        const downloadLink = document.createElement('a');
        downloadLink.href = url;
        downloadLink.download = 'merged-document.pdf';
        downloadLink.click();

        // Clean up
        URL.revokeObjectURL(url);

        // Show success message
        showProgress(false);
        showStatus('PDFs merged successfully! Download started.', 'success');

        // Re-enable button
        mergeBtn.disabled = false;

    } catch (error) {
        console.error('Error merging PDFs:', error);
        showProgress(false);
        showStatus('Error merging PDFs: ' + error.message, 'error');
        mergeBtn.disabled = false;
    }
});

// Helper function to read file as array buffer
function readFileAsArrayBuffer(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = function(e) {
            resolve(e.target.result);
        };
        reader.onerror = function(e) {
            reject(new Error('Failed to read file'));
        };
        reader.readAsArrayBuffer(file);
    });
}

// Initial status
showStatus('Select two PDF files to merge', 'info');
