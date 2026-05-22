const express = require('express');
const router = express.Router();
const authRoutes = require('./auth.routes');
const analysisRoutes = require('./analysis.routes');

router.use('/auth', authRoutes);
router.use('/analysis', analysisRoutes);



router.get('/', (req, res) => {
  res.json({
    message: 'CacaoLens API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      analysis: '/api/analysis'
    }
  });
});

module.exports = router;
