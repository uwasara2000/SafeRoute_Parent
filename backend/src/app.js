const express = require('express');
const cors = require('cors');
const parentRoutes = require('./routes/parentRoutes');
const driverRoutes = require('./routes/driverRoutes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// API Health Check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'School Bus Tracking Backend',
    timestamp: new Date().toISOString()
  });
});

// Mounted Routes
app.use('/api/parent', parentRoutes);
app.use('/api/driver', driverRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled server error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

module.exports = app;

