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

async function seedCacao() {
  console.log('📦 Seeding Cacao data...');
  
  // Ejemplo de cómo hacer upsert (descomenta cuando necesites usar)
  /*
  await prisma.cacao.upsert({
    where: { id: 1 },
    update: {},
    create: {
      id: 1,
      name: 'Cacao Criollo',
      variety: 'Criollo',
      origin: 'Ecuador',
      description: 'Cacao de alta calidad con notas florales y afrutadas'
    }
  });

  await prisma.cacao.upsert({
    where: { id: 2 },
    update: {},
    create: {
      id: 2,
      name: 'Cacao Forastero',
      variety: 'Forastero',
      origin: 'Brasil',
      description: 'Variedad más común, resistente y de sabor intenso'
    }
  });
  */

  console.log('   ✅ Cacao seeding complete (no data yet)');
}

async function seedAnalysis() {
  console.log('📦 Seeding Analysis data...');
  
  // Ejemplo de análisis de prueba (descomenta cuando necesites usar)
  /*
  await prisma.analysis.upsert({
    where: { id: 1 },
    update: {},
    create: {
      id: 1,
      imagePath: '/uploads/sample.jpg',
      prediction: 'Alta Calidad',
      confidence: 0.95,
      metadata: {
        model_version: '1.0.0',
        processing_time: 1.2
      }
    }
  });
  */

  console.log('   ✅ Analysis seeding complete (no data yet)');
}

async function main() {
  console.log('🌱 Starting database seeding...');
  console.log('================================');

  try {
    // Ejecutar seeders en orden
    await seedCacao();
    await seedAnalysis();

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
