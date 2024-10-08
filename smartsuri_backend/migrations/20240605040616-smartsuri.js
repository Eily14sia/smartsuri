'use strict'

module.exports = {
  up: async (queryInterface, Sequelize) => {
     // Create the 'user' table
    await queryInterface.createTable('users', {
      id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        primaryKey: true,
        autoIncrement: true,
      },
      username: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: false,
      },
      password: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      birthday: {
        type: Sequelize.DATE,  // Added 'birthday' field to match model
        allowNull: false,
      },
      city: {
        type: Sequelize.STRING,  // Added 'city' field to match model
        allowNull: false,
      },
      email: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true,
      },
      prof_img: {
        type: Sequelize.TEXT('long'),  // Added 'prof_img' field to match model
        allowNull: true,
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
      },
      created_by: Sequelize.INTEGER,
      updated_by: Sequelize.INTEGER,
      deleted_at: Sequelize.DATE,
      last_login: Sequelize.DATE,
    })

    await queryInterface.createTable('events', {
      id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        primaryKey: true,
        autoIncrement: true,
      },
      name: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: false,
      },
      date: {
        type: Sequelize.DATE,
        allowNull: false,
        unique: false,
      },
      location: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
      },
      created_by: Sequelize.INTEGER,
      updated_by: Sequelize.INTEGER,
      deleted_at: Sequelize.DATE,
    })

    // Create the 'logmaster' table
    await queryInterface.createTable('logmaster', {
      id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        primaryKey: true,
        autoIncrement: true,
      },
      tablename: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      requested_data: {
        type: Sequelize.TEXT('long'),
        allowNull: false,
      },
      change_data: {
        type: Sequelize.TEXT('long'),
        allowNull: false,
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      is_status_change: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
      },
      created_by: Sequelize.INTEGER,
      updated_by: Sequelize.INTEGER,
      deleted_at: Sequelize.DATE,
    })

    await queryInterface.createTable('public.sequelize_meta', {
      name: {
        type: Sequelize.STRING,
        allowNull: false,
        primaryKey: true,
      },
    })
  },

  

  down: async (queryInterface, Sequelize) => {
    try {
      // Drop tables in reverse order of creation
      const tables = [
        'logmaster',
        'users',
      ]

      for (const table of tables) {
        await queryInterface.dropTable(table, { cascade: true })
      }

      // Drop the Sequelize meta table
      await queryInterface.dropTable('public.sequelize_meta', { cascade: true })

      console.log('Migration rollback completed successfully.')
    } catch (error) {
      console.error('Error during migration rollback:', error)
      throw error 
    }
  },
}
