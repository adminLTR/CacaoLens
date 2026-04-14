const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get all cacao records
const getAll = async (req, res, next) => {
  try {
    const cacaoRecords = await prisma.cacao.findMany({
      orderBy: { createdAt: 'desc' }
    });
    
    res.status(200).json({
      success: true,
      data: cacaoRecords
    });
  } catch (error) {
    next(error);
  }
};

// Get cacao by ID
const getById = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const cacao = await prisma.cacao.findUnique({
      where: { id: parseInt(id) },
      include: { analyses: true }
    });
    
    if (!cacao) {
      return res.status(404).json({
        success: false,
        message: 'Cacao record not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: cacao
    });
  } catch (error) {
    next(error);
  }
};

// Create new cacao record
const create = async (req, res, next) => {
  try {
    const cacao = await prisma.cacao.create({
      data: req.body
    });
    
    res.status(201).json({
      success: true,
      data: cacao
    });
  } catch (error) {
    next(error);
  }
};

// Update cacao record
const update = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    const cacao = await prisma.cacao.update({
      where: { id: parseInt(id) },
      data: req.body
    });
    
    res.status(200).json({
      success: true,
      data: cacao
    });
  } catch (error) {
    next(error);
  }
};

// Delete cacao record
const deleteRecord = async (req, res, next) => {
  try {
    const { id } = req.params;
    
    await prisma.cacao.delete({
      where: { id: parseInt(id) }
    });
    
    res.status(200).json({
      success: true,
      message: 'Cacao record deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAll,
  getById,
  create,
  update,
  delete: deleteRecord
};
