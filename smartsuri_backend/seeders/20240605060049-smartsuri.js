module.exports = {
  up: async (queryInterface) => {
    try {
      // Truncate data of All tables

      await queryInterface.sequelize.query(`
        DELETE FROM \`users\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`logmaster\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`public.sequelize_meta\`;
      `)

      // Insert data into Users table
      await queryInterface.sequelize.query(`
        INSERT INTO \`users\` VALUES 
        (1, 'Admin', '$2b$10$slexw2cnG4U0diTzPuDlW.sv3ShEMbamEi.Wuh2fu2AL58Sn.UGPq', '2024-09-10 05:47:07', 'Manila', 'barveilyengco1214@gmail.com', NULL, 1, '2024-09-10 11:47:38', '2024-09-10 13:56:02', NULL, NULL, NULL, NULL)
        `)

      // Insert data into LogMaster table
      await queryInterface.sequelize.query(`
      INSERT INTO \`logmaster\` VALUES (1,'Table','Requested data','Change data',1,0,'2024-06-05 14:15:09','2024-06-05 14:15:09',NULL,NULL,NULL);
    `)

      // Insert data into Sequelize_Meta table
      await queryInterface.sequelize.query(`
      INSERT INTO \`public.sequelize_meta\` VALUES ('20240605040616-smartsuri.js');
    `)

      console.log('Seed data successfully inserted.')
    } catch (error) {
      console.error('Error during seeding:', error)
    }
  },
}
