const express = require('express');
const router = express.Router();
const cacaoController = require('../controllers/cacao.controller');
const upload = require('../middlewares/upload.middleware');

// GET all cacao records
router.get('/', cacaoController.getAll);

// GET single cacao record by ID
router.get('/:id', cacaoController.getById);

// POST create new cacao record
router.post('/', cacaoController.create);

// PUT update cacao record
router.put('/:id', cacaoController.update);

// DELETE cacao record
router.delete('/:id', cacaoController.delete);

module.exports = router;
