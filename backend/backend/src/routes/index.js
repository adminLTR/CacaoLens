const express = require('express');
const router = express.Router();
const authRoutes = require('./auth.routes');

router.use('/auth', authRoutes);

router.get('/', (req, res) => {
  res.json({
    message: 'CacaoLens API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth'
    }
  });
});

module.exports = router;
