require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`=================================================`);
  console.log(`🚌 School Bus Tracking Server Running!`);
  console.log(`📡 URL: http://localhost:${PORT}`);
  console.log(`🩺 Health: http://localhost:${PORT}/health`);
  console.log(`👨‍👩‍👦 Parent API: http://localhost:${PORT}/api/parent/trips/trip_001`);
  console.log(`⏱️ ETA API:    http://localhost:${PORT}/api/parent/trips/trip_001/eta`);
  console.log(`=================================================`);
});

