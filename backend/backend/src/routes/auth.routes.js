const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { verificarToken } = require('../middlewares/auth.middleware');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/logout', verificarToken, authController.logout);
router.get('/profile', verificarToken, authController.getProfile);
router.put('/profile', verificarToken, authController.updateProfile);
router.put('/change-password', verificarToken, authController.changePassword);
router.delete('/account', verificarToken, authController.deleteAccount);

module.exports = router;
