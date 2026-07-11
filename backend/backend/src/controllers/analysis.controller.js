const axios = require('axios');
const FormData = require('form-data');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:8000';

const analyzeImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No se proporcionó imagen' });
    }

    const formData = new FormData();
    formData.append('file', req.file.buffer, {
      filename: req.file.originalname,
      contentType: req.file.mimetype,
    });

    const flaskResponse = await axios.post(`${ML_SERVICE_URL}/predict`, formData, {
      headers: { ...formData.getHeaders() },
    });

    const prediction = flaskResponse.data;
    const estado = prediction.estado || prediction.prediccion;
    const confiabilidad = Number(prediction.confiabilidad ?? prediction.confianza ?? 0);

    let cacao = null;
    let analisis = null;

    if (req.usuarioId) {
      cacao = await prisma.cacao.create({
        data: {
          imagen: req.file.originalname,
        },
      });

      analisis = await prisma.analisis.create({
        data: {
          estado,
          fechRegistro: new Date(),
          idCacao: cacao.id,
          idUsuario: req.usuarioId,
          contabilidad: Math.round(confiabilidad * 100),
        },
      });
    }

    return res.status(200).json({
      success: true,
      prediction: {
        ...prediction,
        estado,
        prediccion: estado,
        confiabilidad,
        confianza: confiabilidad,
      },
      analisisId: analisis?.id ?? null,
      cacaoId: cacao?.id ?? null,
      persisted: Boolean(analisis),
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
    const analyses = await prisma.analisis.findMany({
      orderBy: { fechRegistro: 'desc' },
      include: {
        cacao: true,
        usuario: {
          select: { id: true, nombre: true, correo: true },
        },
      },
    });
    return res.status(200).json(analyses);
  } catch (error) {
    return res.status(500).json({ error: 'Error al obtener historial' });
  }
};

const getAnalysisById = async (req, res) => {
  try {
    const { id } = req.params;
    const analisis = await prisma.analisis.findUnique({
      where: { id: parseInt(id) },
      include: {
        cacao: true,
        usuario: {
          select: { id: true, nombre: true, correo: true },
        },
      },
    });

    if (!analisis) return res.status(404).json({ error: 'Análisis no encontrado' });

    return res.status(200).json(analisis);
  } catch (error) {
    return res.status(500).json({ error: 'Error al obtener análisis' });
  }
};

module.exports = { analyzeImage, getAnalysisHistory, getAnalysisById };
