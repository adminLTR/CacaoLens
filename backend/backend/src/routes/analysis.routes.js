const express = require('express');
const router = express.Router();
const multer = require('multer');
const { analyzeImage, getAnalysisHistory, getAnalysisById } = require('../controllers/analysis.controller');

const upload = multer({ storage: multer.memoryStorage() });

router.post('/image', upload.single('image'), analyzeImage);
router.get('/', getAnalysisHistory);
router.get('/:id', getAnalysisById);

module.exports = router;