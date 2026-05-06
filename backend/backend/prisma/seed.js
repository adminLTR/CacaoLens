const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Database Seeder
 * 
 * Este archivo se ejecuta automáticamente al iniciar el backend
 * para sincronizar datos iniciales en la base de datos usando UPSERT.
 * 
 * Los seeders son útiles para:
 * - Datos de configuración inicial
 * - Usuarios de prueba
 * - Categorías predefinidas
 * - Datos de demostración
 */



async function main() {
  console.log('🌱 Starting database seeding...');
  console.log('================================');

  try {
    // Ejecutar seeders en orden
    

    console.log('================================');
    console.log('✅ All seeders completed successfully!');
  } catch (error) {
    console.error('❌ Error during seeding:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

// Exportar funciones para uso en tests
module.exports = {
  seedCacao,
  seedAnalysis
};
