const axios = require('axios');
const FormData = require('form-data');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:8000';

const analyzeImage = async (req, res) => {
  try {
    // 1. Verificar que llegó imagen
    if (!req.file) {
      return res.status(400).json({ error: 'No se proporcionó imagen' });
    }

    // 2. Preparar FormData para enviar a Flask
    const formData = new FormData();
    formData.append('file', req.file.buffer, {
      filename: req.file.originalname,
      contentType: req.file.mimetype,
    });

    // 3. Llamar al servicio Flask
    const flaskResponse = await axios.post(`${ML_SERVICE_URL}/predict`, formData, {
      headers: {
        ...formData.getHeaders(),
      },
    });

    const prediction = flaskResponse.data;

    // 4. Guardar en BD con Prisma (historial)
    const analysis = await prisma.analysis.create({
      data: {
        estado: prediction.class || prediction.label || 'desconocido',
        fechaRegistro: new Date(),
        idCacao: 1,      // por ahora fijo, luego vendrá del request
        idUsuario: 1,    // por ahora fijo, luego vendrá del token JWT
        confiabilidad: prediction.confidence || 0.0,
      },
    });
    // 5. Devolver al frontend
    return res.status(200).json({
      success: true,
      prediction,
      analysisId: analysis.id,
    });

  } catch (error) {
    console.error('Error en analyzeImage:', error.message);

    if (error.response) {
      return res.status(502).json({
        error: 'Error en el servicio ML',
        detail: error.response.data,
      });
    }

    return res.status(500).json({ error: 'Error interno del servidor' });
  }
};

const getAnalysisHistory = async (req, res) => {
  try {
    const analyses = await prisma.analysis.findMany({
      orderBy: { createdAt: 'desc' },
    });
    return res.status(200).json(analyses);
  } catch (error) {
    return res.status(500).json({ error: 'Error al obtener historial' });
  }
};

module.exports = { analyzeImage, getAnalysisHistory };