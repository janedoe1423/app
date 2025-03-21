const express = require('express');
const path = require('path');
const app = express();
const PORT = 5000;

console.log('Starting server to serve existing Flutter web build...');

// Set up MIME types correctly
app.use((req, res, next) => {
  const ext = path.extname(req.url);
  
  if (ext === '.js') {
    res.setHeader('Content-Type', 'application/javascript');
  } else if (ext === '.css') {
    res.setHeader('Content-Type', 'text/css');
  } else if (ext === '.json') {
    res.setHeader('Content-Type', 'application/json');
  } else if (ext === '.png') {
    res.setHeader('Content-Type', 'image/png');
  } else if (ext === '.jpg' || ext === '.jpeg') {
    res.setHeader('Content-Type', 'image/jpeg');
  } else if (ext === '.svg') {
    res.setHeader('Content-Type', 'image/svg+xml');
  } else if (ext === '.woff') {
    res.setHeader('Content-Type', 'font/woff');
  } else if (ext === '.woff2') {
    res.setHeader('Content-Type', 'font/woff2');
  } else if (ext === '.ttf') {
    res.setHeader('Content-Type', 'font/ttf');
  } else if (ext === '.html') {
    res.setHeader('Content-Type', 'text/html');
  } else if (ext === '.dart') {
    res.setHeader('Content-Type', 'application/javascript');
  }
  
  next();
});

// Serve static files from Flutter web build directory
app.use(express.static(path.join(__dirname, 'build/web')));

// Handle all routes by sending the index.html file
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/web', 'index.html'));
});

// Start the server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running at http://0.0.0.0:${PORT}/`);
});