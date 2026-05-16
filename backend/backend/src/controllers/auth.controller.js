const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const prisma = new PrismaClient();

const register = async (req, res) => {
  try {
    const { nombre, apellidos, fechaNac, DNI, correo, contrasena } = req.body;

    if (!nombre || !apellidos || !fechaNac || !DNI || !correo || !contrasena) {
      return res.status(400).json({ error: 'Todos los campos son obligatorios' });
    }

    const usuarioExistente = await prisma.usuario.findFirst({
      where: {
        OR: [
          { correo },
          { DNI }
        ]
      }
    });

    if (usuarioExistente) {
      return res.status(400).json({ error: 'El correo o DNI ya está registrado' });
    }

    const hashedPassword = await bcrypt.hash(contrasena, 10);

    const usuario = await prisma.usuario.create({
      data: {
        nombre,
        apellidos,
        fechaNac: new Date(fechaNac),
        DNI,
        correo,
        contrasena: hashedPassword,
        estado: true
      }
    });

    const { contrasena: _, ...usuarioSinPassword } = usuario;

    res.status(201).json(usuarioSinPassword);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { correo, contrasena } = req.body;

    if (!correo || !contrasena) {
      return res.status(400).json({ error: 'Correo y contraseña son obligatorios' });
    }

    const usuario = await prisma.usuario.findUnique({
      where: { correo }
    });

    if (!usuario) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    if (!usuario.estado) {
      return res.status(403).json({ error: 'Usuario inactivo' });
    }

    const passwordValido = await bcrypt.compare(contrasena, usuario.contrasena);

    if (!passwordValido) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    const token = jwt.sign(
      { id: usuario.id, correo: usuario.correo },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    const fechaExpiracion = new Date();
    fechaExpiracion.setDate(fechaExpiracion.getDate() + 7);

    await prisma.sesiones.create({
      data: {
        idUsuario: usuario.id,
        token,
        activo: true,
        fechaInicio: new Date(),
        fechExp: fechaExpiracion
      }
    });

    const { contrasena: _, ...usuarioSinPassword } = usuario;

    res.status(200).json({
      token,
      usuario: usuarioSinPassword
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const logout = async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (token) {
      await prisma.sesiones.updateMany({
        where: {
          token,
          activo: true
        },
        data: {
          activo: false
        }
      });
    }

    res.status(200).json({ message: 'Sesión cerrada exitosamente' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const getProfile = async (req, res) => {
  try {
    const usuario = await prisma.usuario.findUnique({
      where: { id: req.usuarioId },
      select: {
        id: true,
        nombre: true,
        apellidos: true,
        fechaNac: true,
        DNI: true,
        correo: true,
        fechaRegistro: true,
        estado: true
      }
    });

    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    res.status(200).json(usuario);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const updateProfile = async (req, res) => {
  try {
    const { nombre, apellidos, fechaNac, correo } = req.body;

    if (correo) {
      const correoExistente = await prisma.usuario.findFirst({
        where: {
          correo,
          NOT: { id: req.usuarioId }
        }
      });

      if (correoExistente) {
        return res.status(400).json({ error: 'El correo ya está en uso' });
      }
    }

    const datosActualizar = {};
    if (nombre) datosActualizar.nombre = nombre;
    if (apellidos) datosActualizar.apellidos = apellidos;
    if (fechaNac) datosActualizar.fechaNac = new Date(fechaNac);
    if (correo) datosActualizar.correo = correo;

    const usuario = await prisma.usuario.update({
      where: { id: req.usuarioId },
      data: datosActualizar,
      select: {
        id: true,
        nombre: true,
        apellidos: true,
        fechaNac: true,
        DNI: true,
        correo: true,
        fechaRegistro: true,
        estado: true
      }
    });

    res.status(200).json(usuario);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const changePassword = async (req, res) => {
  try {
    const { contrasenaActual, contrasenaNueva } = req.body;

    if (!contrasenaActual || !contrasenaNueva) {
      return res.status(400).json({ error: 'Contraseña actual y nueva son obligatorias' });
    }

    const usuario = await prisma.usuario.findUnique({
      where: { id: req.usuarioId }
    });

    const passwordValido = await bcrypt.compare(contrasenaActual, usuario.contrasena);

    if (!passwordValido) {
      return res.status(401).json({ error: 'Contraseña actual incorrecta' });
    }

    const hashedPassword = await bcrypt.hash(contrasenaNueva, 10);

    await prisma.usuario.update({
      where: { id: req.usuarioId },
      data: { contrasena: hashedPassword }
    });

    res.status(200).json({ message: 'Contraseña actualizada exitosamente' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const deleteAccount = async (req, res) => {
  try {
    await prisma.usuario.update({
      where: { id: req.usuarioId },
      data: { estado: false }
    });

    await prisma.sesiones.updateMany({
      where: {
        idUsuario: req.usuarioId,
        activo: true
      },
      data: { activo: false }
    });

    res.status(200).json({ message: 'Cuenta desactivada exitosamente' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  register,
  login,
  logout,
  getProfile,
  updateProfile,
  changePassword,
  deleteAccount
};
