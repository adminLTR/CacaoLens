const express = require('express');
const router = express.Router();


// Base route
router.get('/', (req, res) => {
  res.json({
    message: 'CacaoLens API',
    version: '1.0.0',
    endpoints: {
      
    }
  });
});

module.exports = router;
