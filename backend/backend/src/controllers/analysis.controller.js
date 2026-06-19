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
      headers: { ...formData.getHeaders() },
    });

    const prediction = flaskResponse.data;
/*
    // 4. Guardar imagen en tabla Cacao
    const cacao = await prisma.cacao.create({
      data: {
        imagen: req.file.originalname, // nombre del archivo
      },
    });

    // 5. Guardar análisis en tabla Analisis
    const analisis = await prisma.analisis.create({
      data: {
        estado: prediction.estado,
        fechRegistro: new Date(),
        idCacao: cacao.id,
        idUsuario: req.user?.id || 1, // del token JWT cuando esté listo auth
        contabilidad: Math.round((prediction.confiabilidad || 0) * 100), // % como entero
      },
    });
      */

    // 6. Devolver al frontend
    return res.status(200).json({
      success: true,
      prediction,
      analisisId:"ID-Simulado", //analisis.id ,
      cacaoId: "ID-Simulado", //cacao.id,
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