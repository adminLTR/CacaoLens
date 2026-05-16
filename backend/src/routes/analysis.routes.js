const express = require('express');
const router = express.Router();
const multer = require('multer');
const { analyzeImage, getAnalysisHistory } = require('../controllers/analysis.controller');

const upload = multer({ storage: multer.memoryStorage() });

router.post('/image', upload.single('image'), analyzeImage);
router.get('/', getAnalysisHistory);

module.exports = router;