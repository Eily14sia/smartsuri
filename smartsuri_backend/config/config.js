require('dotenv').config()

module.exports = {
  development: {
    database: process.env.DB_DATABASE,
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    dialect: process.env.DB_DIALECT,
    define: {
      underscored: true,
      timestamps: false,
    },
    dialectOptions: {
      useUTC: false,
      timezone: 'Etc/GMT0',
    },
    migrationStorageTableName: 'sequelize_meta',
    seederStorageTableName: 'sequelize_data',
    migrationStorageTableSchema: 'public',
    seederStorageTableSchema: 'public',
    modelsPath: 'models',
    seedersPath: 'seeders',
    migrationsPath: 'migrations',
  },
  test: {
    database: process.env.DB_TEST_DATABASE,
    username: process.env.DB_TEST_USERNAME,
    password: process.env.DB_TEST_PASSWORD,
    host: process.env.DB_TEST_HOST,
    dialect: process.env.DB_TEST_DIALECT,
  },
  production: {
    database: process.env.DB_PROD_DATABASE,
    username: process.env.DB_PROD_USERNAME,
    password: process.env.DB_PROD_PASSWORD,
    host: process.env.DB_PROD_HOST,
    dialect: process.env.DB_PROD_DIALECT,
  },
}
