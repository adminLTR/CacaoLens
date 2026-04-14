const express = require('express');
const router = express.Router();

// Import route modules
const cacaoRoutes = require('./cacao.routes');
const analysisRoutes = require('./analysis.routes');

// Mount routes
router.use('/cacao', cacaoRoutes);
router.use('/analysis', analysisRoutes);

// Base route
router.get('/', (req, res) => {
  res.json({
    message: 'CacaoLens API',
    version: '1.0.0',
    endpoints: {
      cacao: '/api/cacao',
      analysis: '/api/analysis'
    }
  });
});

module.exports = router;
