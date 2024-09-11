module.exports = {
  up: async (queryInterface) => {
    try {
      // Truncate data of All tables
      await queryInterface.sequelize.query(`
         DELETE FROM \`site\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`role\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`access\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`company\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`project_type\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`project\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`users\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`company_project_type_mapping\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`logmaster\`;
      `)

      await queryInterface.sequelize.query(`
        DELETE FROM \`public.sequelize_meta\`;
      `)

      // Insert data into Site table
      await queryInterface.sequelize.query(`
      INSERT INTO \`site\` VALUES 
      (1,'Site1','https://example.com','example.com','127.0.0.1',1,'2024-06-05 14:15:09','2024-06-05 14:15:09',NULL,NULL,NULL);
    `)

      // Insert data into Role table
      await queryInterface.sequelize.query(`
      INSERT INTO \`role\` VALUES 
      (1,'super admin',1,'2024-06-05 14:15:09','2024-06-05 14:15:09',NULL,NULL,NULL);
    `)

      // Insert data into Access table
      await queryInterface.sequelize.query(`
      INSERT INTO \`access\` VALUES 
      (1,NULL,NULL ,1 ,1 , '2024-06-05 14:15:09','2024-06-05 14:15:09',NULL,NULL,NULL);
    `)

      // Insert data into Company table
      await queryInterface.sequelize.query(`
      INSERT INTO \`company\` VALUES 
      (1,'Smartech',1,'2024-06-05 14:15:09','2024-06-05 14:15:09',NULL,NULL,NULL),
      (2,'Smartpay',1,'2024-06-05 14:15:09','2024-06-05 14:15:09',NULL,NULL,NULL);
    `)

      // Insert data into Project_Type table
      await queryInterface.sequelize.query(`
        INSERT INTO \`project_type\` VALUES 
        (1,'LGU','test',1,'2024-06-05 11:17:10','2024-06-05 11:17:10',NULL,NULL,NULL),
        (2,'Tour','test2',1,'2024-06-05 11:17:10','2024-06-05 11:17:10',NULL,NULL,NULL),
        (3,'Profession','test3',1,'2024-06-06 11:17:10','2024-06-06 11:17:10',NULL,NULL,NULL);
      `)

      // Insert data into ProjectInfo table
      await queryInterface.sequelize.query(`
        INSERT INTO \`project\` VALUES 
        (1,'New','user',2,1,1,1,1,'','Laptop 123','1.0','2024-06-05 11:16:23','2024-06-05 11:16:23',NULL,NULL,NULL),
        (2,'New','user',2,1,1,1,1,'','Laptop 123','1.0','2024-06-05 11:16:23','2024-06-05 11:16:23',NULL,NULL,NULL),
        (3,'New','user',2,1,1,1,1,'','Laptop 123','1.0','2024-06-05 11:16:23','2024-06-05 11:16:23',NULL,NULL,NULL),
        (4,'New','user',2,1,1,1,1,'','Laptop 123','1.0','2024-06-05 11:16:23','2024-06-05 11:16:23',NULL,NULL,NULL);
      `)

      // Insert data into Users table
      await queryInterface.sequelize.query(`
        INSERT INTO \`users\` VALUES 
        (1,'User1','$2b$10$slexw2cnG4U0diTzPuDlW.sv3ShEMbamEi.Wuh2fu2AL58Sn.UGPq',1, 1, 1,'user1@gmail.com','2024-06-04 14:24:24','2024-06-05 10:20:16',NULL,NULL,NULL,NULL),
        (2,'NewUser2','$2b$10$YQga30DGerF1npGK9bCx5OKMRPMss05k70xVWm5wU7sFRD4CKq5g2',1, 1, 1,'','2024-06-04 15:09:49','2024-06-05 10:17:06',NULL,NULL,NULL,NULL),
        (3,'NewUser3','$2b$10$E.ChTaAgSW8L7vVixN4Kdu2ymuTZL8xlf7hMscZkrVQUwwToFeB5e',1, 1,1,'','2024-06-05 09:55:10','2024-06-05 09:55:10',NULL,NULL,NULL,NULL),
        (4,'User2','$2b$10$dWCJdd5sml1J.2uZ/p4Bnet.UCBLYPB0LUr0YtW7YycDE32w8uwKq',1,1, 1,'','2024-06-05 02:47:59','2024-06-05 02:47:59',NULL,NULL,NULL,NULL);
        `)

      // Insert data into Users table
      await queryInterface.sequelize.query(`
        INSERT INTO \`company_project_type_mapping\` VALUES 
        (1, 1, 1,'2024-06-04 14:24:24','2024-06-05 10:20:16',NULL,NULL,NULL);
        `)

      // Insert data into LogMaster table
      await queryInterface.sequelize.query(`
      INSERT INTO \`logmaster\` VALUES (1,'Table','Requested data','Change data',1,0,'2024-06-05 14:15:09','2024-06-05 14:15:09',NULL,NULL,NULL);
    `)

      // Insert data into Sequelize_Meta table
      await queryInterface.sequelize.query(`
      INSERT INTO \`public.sequelize_meta\` VALUES ('20240605040616-nodetrial.js');
    `)

      console.log('Seed data successfully inserted.')
    } catch (error) {
      console.error('Error during seeding:', error)
    }
  },
}
