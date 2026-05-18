const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const verificarToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Token no proporcionado' });
    }

    const token = authHeader.split(' ')[1];

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const sesion = await prisma.sesiones.findFirst({
      where: {
        token,
        activo: true,
        idUsuario: decoded.id,
        fechExp: {
          gt: new Date()
        }
      }
    });

    if (!sesion) {
      return res.status(401).json({ error: 'Token inválido o expirado' });
    }

    const usuario = await prisma.usuario.findUnique({
      where: { id: decoded.id }
    });

    if (!usuario || !usuario.estado) {
      return res.status(403).json({ error: 'Usuario no autorizado' });
    }

    req.usuarioId = decoded.id;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Token inválido' });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expirado' });
    }
    res.status(500).json({ error: error.message });
  }
};

module.exports = { verificarToken };
