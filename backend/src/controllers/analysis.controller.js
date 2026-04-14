const { PrismaClient } = require('@prisma/client');
const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const prisma = new PrismaClient();

// Analyze image using ML service
const analyzeImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided'
      });
    }

    // Send image to ML service
    const formData = new FormData();
    formData.append('image', fs.createReadStream(req.file.path));

    const mlResponse = await axios.post(
      `${process.env.ML_SERVICE_URL}/predict`,
      formData,
      {
        headers: formData.getHeaders()
      }
    );

    // Save analysis result to database
    const analysis = await prisma.analysis.create({
      data: {
        imagePath: req.file.path,
        prediction: mlResponse.data.prediction,
        confidence: mlResponse.data.confidence,
        metadata: mlResponse.data
      }
    });

    res.status(200).json({
      success: true,
      data: analysis
    });
  } catch (error) {
    next(error);
  } finally {
    // Clean up uploaded file
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
  }
};

// Get analysis by ID
const getById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const analysis = await prisma.analysis.findUnique({
      where: { id: parseInt(id) }
    });
    
    if (!analysis) {
      return res.status(404).json({
        success: false,
        message: 'Analysis not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: analysis
    });
  } catch (error) {
    next(error);
  }
};

// Get all analyses
const getAll = async (req, res, next) => {
  try {
    const analyses = await prisma.analysis.findMany({
      orderBy: { createdAt: 'desc' }
    });
    
    res.status(200).json({
      success: true,
      data: analyses
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  analyzeImage,
  getById,
  getAll
};
