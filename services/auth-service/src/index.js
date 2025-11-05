const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', service: 'auth-service' });
});

app.post('/auth/login', (req, res) => {
  res.json({ message: 'Login endpoint' });
});

app.post('/auth/register', (req, res) => {
  res.json({ message: 'Register endpoint' });
});

app.listen(PORT, () => {
  console.log(`Auth service running on port ${PORT}`);
});