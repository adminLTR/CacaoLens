const express = require('express');
const router = express.Router();
const analysisController = require('../controllers/analysis.controller');
const upload = require('../middlewares/upload.middleware');

// POST analyze image
router.post('/image', upload.single('image'), analysisController.analyzeImage);

// GET analysis by ID
router.get('/:id', analysisController.getById);

// GET all analyses
router.get('/', analysisController.getAll);

module.exports = router;
