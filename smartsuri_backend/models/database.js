const { DataTypes } = require('sequelize')
const sequelize = require('../server').sequelize

const commonOptions = {
  timestamps: false, // Disable timestamps
}

const Role = sequelize.define(
  'role',
  {
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: true, // Assuming active by default
    },
    created_by: DataTypes.INTEGER,
    updated_by: DataTypes.INTEGER,
    created_at: DataTypes.DATE,
    updated_at: DataTypes.DATE,
    deleted_at: DataTypes.DATE,
  },
  { ...commonOptions, tableName: 'role' },
)

const User = sequelize.define(
  'user',
  {
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true,
    },
    username: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    birthday: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    city: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    prof_img: {
      type: DataTypes.TEXT('long'),
      allowNull: true,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
    },
    role_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    created_by: DataTypes.INTEGER,
    updated_by: DataTypes.INTEGER,
    created_at: DataTypes.DATE,
    updated_at: DataTypes.DATE,
    deleted_at: DataTypes.DATE,
    last_login: DataTypes.DATE,
  },
  { ...commonOptions, tableName: 'users' },
)

const LogMaster = sequelize.define(
  'logmaster',
  {
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true,
    },
    tablename: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    requested_data: {
      type: DataTypes.TEXT('long'),
      allowNull: false,
    },
    change_data: {
      type: DataTypes.TEXT('long'),
      allowNull: false,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
    },
    is_status_change: {
      type: DataTypes.BOOLEAN,
      defaultValue: 0,
    },
    created_by: DataTypes.INTEGER,
    updated_by: DataTypes.INTEGER,
    created_at: DataTypes.DATE,
    updated_at: DataTypes.DATE,
    deleted_at: DataTypes.DATE,
  },
  { ...commonOptions, tableName: 'logmaster' },
)

User.belongsTo(Role, { foreignKey: 'role_id', as: 'role' })
Role.hasMany(User, { foreignKey: 'role_id' })

const logUpdate = async (instance, options) => {
  const tableName = instance.constructor.tableName
  const primaryKey = instance.constructor.primaryKeyAttributes[0]
  const primaryKeyValue = instance[primaryKey]

  const originalData = instance._previousDataValues
  const updatedData = instance.dataValues

  const changes = {}

  // Compare each field to detect changes
  Object.keys(updatedData).forEach((key) => {
    if (
      updatedData[key] !== originalData[key] &&
      key !== 'created_at' &&
      key !== 'updated_at' &&
      key !== 'created_by' &&
      key !== 'updated_by' &&
      key !== 'deleted_at'
    ) {
      changes[key] = updatedData[key]
    }
  })

  await LogMaster.create(
    {
      tablename: tableName,
      requested_data: JSON.stringify(originalData),
      change_data: JSON.stringify(changes),
      isActive: true,
      is_status_change: originalData.isActive !== updatedData.isActive,
      created_by: updatedData.updated_by,
      updated_by: updatedData.updated_by,
      created_at: new Date(),
      updated_at: new Date(),
    },
    { transaction: options.transaction },
  )
}

const logCreate = async (instance, options) => {
  const tableName = instance.constructor.tableName
  const primaryKey = instance.constructor.primaryKeyAttributes[0]
  const primaryKeyValue = instance[primaryKey]

  const createdData = instance.dataValues

  await LogMaster.create(
    {
      tablename: tableName,
      requested_data: JSON.stringify({}),
      change_data: JSON.stringify(createdData),
      isActive: true,
      is_status_change: false,
      created_by: createdData.created_by,
      updated_by: createdData.updated_by,
      created_at: new Date(),
      updated_at: new Date(),
    },
    { transaction: options.transaction },
  )
}

User.addHook('afterUpdate', logUpdate)

User.addHook('afterCreate', logCreate)


module.exports = { User, Role, LogMaster, sequelize }
