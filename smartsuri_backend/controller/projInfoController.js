const { sequelize, ProjectInfo, LogMaster } = require('../models/database')
const AuthService = require('../middleware/authToken')
const dotenv = require('dotenv')
const { S3Client, PutObjectCommand, HeadObjectCommand } = require('@aws-sdk/client-s3')
const axios = require('axios')
const { Op } = require('sequelize')
const moment = require('moment');
const crypto = require('crypto');

// Compute MD5 hash of file content
function computeFileHash(buffer) {
  return crypto.createHash('md5').update(buffer).digest('hex');
}

dotenv.config()

const useStoredProcedure = process.env.USE_STORED_PROCEDURE

const getLogger = require('../utils/logger')

const logger = getLogger(__filename)

const s3Client = new S3Client({
  region: process.env.AWS_DEFAULT_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
})

class ProjInfoController {
  static async createProjInfo(req, res) {
  const { name, description, project_type_id, company_id, site_id, device_id, app_version, isDemo } = req.body;
  const logo = req.file; 

  // Validate fields
  const validationResult = AuthService.validateFields(req.body, ['name', 'description', 'project_type_id', 'company_id', 'site_id', 'device_id', 'app_version', 'isDemo']);
  if (validationResult) {
    return res.status(validationResult.errorCode).json(validationResult);
  }

  if (!logo) {
    return res.status(400).json({
      resultKey: false,
      errorMessage: 'Logo file is required',
      errorCode: 400,
    });
  }

    let transaction
    let logoUrl;
    debugger;
    try {
      logoUrl = await ProjInfoController.uploadLogoToS3(logo) // Corrected method name

    try {
      // External API verification
      const apiResponse = await axios.post(process.env.API_ENDPOINT, { dbname: process.env.DB_DATABASE })
      if (apiResponse.data.resultKey === 0) {
        logger.error('External API verification failed')
        return res
          .status(400)
          .json({ resultKey: false, errorMessage: 'External API verification failed', errorCode: 400 })
      }

      // Check if project already exists
      const existingProjectInfo = await ProjectInfo.findOne({ where: { name, project_type_id, company_id } })
      if (existingProjectInfo) {
        logger.error('Project already exists for this company and project type')
        return res
          .status(400)
          .json({
            resultKey: false,
            errorMessage: 'Project already exists for this company and project type',
            errorCode: 400,
          })
      }
      const createdBy = req.user.id
      const deletedAt = null 

      transaction = await sequelize.transaction()
      debugger;
      if (process.env.USE_STORED_PROCEDURE === 'false') {
        // Direct insert
        const newProjectInfo = await ProjectInfo.create(
          {
            name,
            description,
            project_type_id,
            isDemo: process.env.DEMO_MODE,
            isActive: true,
            company_id,
            site_id,
            created_by: createdBy,
            updated_by: createdBy,
            deleted_at: deletedAt,
            logo: logoUrl,
            device_id,
            app_version,
          },
          { transaction },
        )

        debugger;
        await transaction.commit()

        return res.json({
          resultKey: true,
          message: 'Project created successfully',
          projectInfo: newProjectInfo,
          resultCode: 200,
        })
      } else {
        const isDemo = process.env.DEMO_MODE

        let isDemoNumber
        if (isDemo === 'true') {
          isDemoNumber = 1
        } else {
          isDemoNumber = 0
        }

        // Stored procedure call
        const params = {
          p_name: name,
          p_description: description,
          p_project_type_id: project_type_id,
          p_is_demo: isDemoNumber,
          p_company_id: company_id,
          p_site_id: site_id,
          p_is_active: 1,
          p_created_by: createdBy,
          p_updated_by: createdBy,
          p_deleted_at: null,
          p_logo: logoUrl,
          p_device_id: device_id,
          p_app_version: app_version,
        }
        debugger;
        try {
          const result = await AuthService.executeStoredProcedure('CreateProjectInfoProcedure', params, transaction)

          if (!result.success) {
            await transaction.rollback()
            logger.error('Failed to create project info using stored procedure')
            return res
              .status(500)
              .json({ resultKey: false, errorMessage: 'Failed to create project info', errorCode: 500 })
          }

          // Fetch the newly created project info
          const newProjectInfo = await ProjectInfo.findOne({
            where: {
              name: params.p_name,
              project_type_id: params.p_project_type_id,
              company_id: params.p_company_id,
            },
            transaction,
          })

          if (!newProjectInfo) {
            throw new Error('New project information is missing after creation')
          }
          // Log creation
          const loggingTransaction = await sequelize.transaction()
          try {
            await LogMaster.create(
              {
                tablename: 'project',
                requested_data: JSON.stringify('Create New Project'),
                change_data: JSON.stringify(newProjectInfo),
                isActive: true,
                created_by: req.user.id,
                updated_by: req.user.id,
                created_at: new Date(),
              },
              { transaction: loggingTransaction },
            )

            await loggingTransaction.commit()
          } catch (logError) {
            await loggingTransaction.rollback()
            logger.error(`Error logging project creation: ${logError.message}`, { stack: logError.stack })
          }
          debugger;
          await transaction.commit()

          return res.json({
            resultKey: true,
            message: 'Project created successfully',
            projectInfo: newProjectInfo,
            resultCode: 200,
          })

        } catch (error) {
          await transaction.rollback()
          logger.error(`Error creating project info using stored procedure: ${error.message}`, { stack: error.stack })
          return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
        }
      }
    } catch (error) {
      if (transaction) await transaction.rollback()
      logger.error(`Error creating project info: ${error.message}`, { stack: error.stack })
      return res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }

  } catch (uploadError) {
    logger.error(`Error uploading logo to S3: ${uploadError.message}`, { stack: uploadError.stack })
    return res.status(500).json({
      resultKey: false,
      errorMessage: 'Failed to upload logo. Logo already exists',
      errorCode: 500,
    })
  }
  }

  static async deleteProjInfo(req, res) {
    const projId = req.params.id

    const transaction = await sequelize.transaction()

    const originalData = await ProjectInfo.findByPk(projId, { transaction })

    if (!originalData) {
      await transaction.rollback()
      logger.error('Project not found')
      return res.status(404).json({ resultKey: false, errorMessage: 'Project not found', errorCode: 404 })
    }
    debugger;
    try {
      if (useStoredProcedure === 'false') {
        // Find the account type
        const projInfo = await ProjectInfo.findByPk(projId, { transaction })

        if (!projInfo) {
          await transaction.rollback()
          logger.error('Project not found')
          return res.status(404).json({ resultKey: false, errorMessage: 'Project not found', errorCode: 404 })
        }

        // Deactivate the account type using ORM
        await projInfo.update(
          {
            isActive: false,
            updated_by: req.user.id,
            deleted_at: new Date(),
          },
          { transaction },
        )
        debugger;
        // Commit transaction
        await transaction.commit()
        return res.json({ resultKey: true, resultValue: 'Project deactivated successfully', resultCode: 200 })
      } else {
        // Use the stored procedure
        const params = {
          p_id: projId,
          p_updated_by: req.user.id,
        }
        await AuthService.executeStoredProcedure('DeleteProjectInfoProcedure', params, transaction)
        debugger;
        await transaction.commit()
        const updatedData = await ProjectInfo.findByPk(projId)

        // Log the change
        await AuthService.createLogEntry(
          originalData.toJSON(),
          updatedData.toJSON(),
          'project',
          req.user.id,
          transaction,
        )
        debugger;
        res.json({ resultKey: true, message: 'Project deactivated successfully', resultCode: 200 })
      }
    } catch (error) {
      if (!transaction.finished) {
        await transaction.rollback()
      }
      logger.error(`Error deactivating project: ${error.message}`, { stack: error.stack })
      res.status(500).json({ resultKey: false, errorMessage: 'Server error', errorCode: 500 })
    }
  }

  static async updateAndSaveProjInfo(req, res) {
    const id = req.params.id;
    const updated_by = req.user.id; 
    const {
      name,
      description,
      project_type_id,
      company_id,
      site_id,
      isDemo,
      isActive,
      device_id,
      app_version,
    } = req.body;
  
    // Define required fields for updating project info
    const requiredFields = [
      'name',
      'description',
      'project_type_id',
      'company_id',
      'site_id',
      'isDemo',
      'isActive',
      'device_id',
      'app_version',
    ];
  
    // Validate fields
    const validationResult = AuthService.validateFields(req.body, requiredFields);
    if (validationResult) {
      return res.status(validationResult.errorCode).json(validationResult);
    }
  
    const logo = req.file; 
  
    let transaction;
    let logoUrl = null;
  
    try {
      transaction = await sequelize.transaction();
  
      // Retrieve the current project info
      const originalData = await ProjectInfo.findByPk(id, { transaction });
  
      if (!originalData) {
        await transaction.rollback();
        logger.error('Project not found');
        return res.status(404).json({ resultKey: false, errorMessage: 'Project not found', errorCode: 404 });
      }

         // Check if the project info already exists for the same company, project type, and name
         const existingProjectInfo = await ProjectInfo.findOne({
          where: {
            name,
            project_type_id,
            company_id,
            id: { [Op.ne]: id }, // Exclude the current project ID
          },
          transaction,
        });
    
        if (existingProjectInfo) {
          await transaction.rollback();
          return res.status(400).json({
            resultKey: false,
            errorMessage: 'Project with the same name and project type already exists for this company',
            errorCode: 400,
          });
        }
  
      // Upload the new logo if provided
      if (logo) {
        try {
          logoUrl = await ProjInfoController.uploadLogoToS3(logo); // Corrected method name
        } catch (uploadError) {
          logger.error(`Error uploading logo to S3: ${uploadError.message}`, { stack: uploadError.stack });
          return res.status(500).json({
            resultKey: false,
            errorMessage: 'Failed to upload logo. Logo already exists',
            errorCode: 500,
          });
        }
      } else {
        // Retain the existing logo URL if no new logo is provided
        logoUrl = originalData.logo;
      }
  
      if (useStoredProcedure === 'false') {
        // Using ORM
        const projectInfo = await ProjectInfo.findOne({
          where: { id },
          transaction,
        });
  
        if (!projectInfo) {
          await transaction.rollback();
          return res.status(404).json({ resultKey: false, errorMessage: 'Project not found', errorCode: 404 });
        }
  
        // Update the project info fields
        projectInfo.name = name;
        projectInfo.description = description;
        projectInfo.project_type_id = project_type_id;
        projectInfo.isDemo = isDemo;
        projectInfo.isActive = isActive;
        projectInfo.company_id = company_id;
        projectInfo.site_id = site_id;
        projectInfo.updated_by = updated_by;
        projectInfo.deleted_at = isActive === 0 ? new Date() : null;
        projectInfo.logo = logoUrl;
        projectInfo.device_id = device_id;
        projectInfo.app_version = app_version;
  
        // Save the updated project info
        await projectInfo.save({ transaction });
        await transaction.commit();
  
        return res.json({
          resultKey: true,
          message: 'Project updated successfully',
          projectInfo,
          resultCode: 200,
        });
      } else {
        let isActiveNumber, isDemoNumber
        if (isActive === 'true' ) {
          isActiveNumber = 1
        } else {
          isActiveNumber = 0
        }

        if (isDemo === 'true') {
          isDemoNumber = 1
        } else {
          isDemoNumber = 0
        }

        const deletedAt = isActiveNumber === 0 ? moment().format('YYYY-MM-DD HH:mm:ss') : null;

        const params = {
          p_id: id,
          p_name: name,
          p_description: description,
          p_project_type_id: project_type_id,
          p_company_id: company_id,
          p_site_id: site_id,
          p_is_demo: isDemoNumber,
          p_is_active: isActiveNumber,
          p_updated_by: updated_by,
          p_deleted_at: deletedAt,
          p_logo: logoUrl,
          p_device_id: device_id,
          p_app_version: app_version,
        }
  
        // logger.info('Executing stored procedure with parameters:', params);
  
        // Execute the stored procedure to update the project info
        const result = await AuthService.executeStoredProcedure('UpdateProjectInfoProcedure', params, transaction);
  
        if (!result.success) {
          await transaction.rollback();
          logger.error(`Stored procedure 'UpdateProjectInfoProcedure' failed: ${result.errorMessage}`, {
            params,
            stack: new Error().stack,
          });
          return res.status(500).json({
            resultKey: false,
            errorMessage: 'Failed to update project info using stored procedure',
            errorCode: 500,
          });
        }
  
        // Commit the transaction
        await transaction.commit();
  
        const updatedData = await ProjectInfo.findByPk(id);
  
        // Log the change
        try {
          await AuthService.createLogEntry(
            originalData.toJSON(),
            updatedData.toJSON(),
            'project',
            req.user.id,
            transaction,
          );
        } catch (logError) {
          logger.error(`Error logging project update: ${logError.message}`, { stack: logError.stack });
        }
  
        return res.json({
          resultKey: true,
          message: 'Project updated successfully using stored procedure',
          resultCode: 200,
        });
      }
    } catch (error) {
      if (transaction && !transaction.finished) {
        await transaction.rollback();
      }
      logger.error(`Error updating project info: ${error.message}`, { stack: error.stack });
      return res.status(500).json({
        resultKey: false,
        errorMessage: 'Server error',
        errorCode: 500,
      });
    }
  }
  
// Method to upload logo to S3
static async uploadLogoToS3(file) {
  if (!file) {
    throw new Error('No file provided for upload');
  }

  const { buffer, originalname, mimetype } = file;
  const fileHash = computeFileHash(buffer);
  const key = `logos/${fileHash}_${originalname}`; // Use hash for uniqueness
  const bucket = process.env.AWS_BUCKET;

  // Check if file already exists
  try {
    await ProjInfoController.checkIfFileExists(bucket, key);
    throw new Error('File already exists in S3');
  } catch (error) {
    if (error.message === 'File not found') {
      // Proceed with file upload if it does not exist
    } else {
      throw error;
    }
  }

  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: key,
    Body: buffer,
    ContentType: mimetype,
  });

  try {
    await s3Client.send(command);
    const url = `https://${bucket}.s3.${process.env.AWS_DEFAULT_REGION}.amazonaws.com/${key}`;
    return url;
  } catch (error) {
    throw new Error(`Failed to upload file to S3: ${error.message}`);
  }
}

// Method to check if a file exists in S3
static async checkIfFileExists(bucket, key) {
  const command = new HeadObjectCommand({
    Bucket: bucket,
    Key: key,
  });

  try {
    await s3Client.send(command);
  } catch (error) {
    if (error.name === 'NotFound') {
      throw new Error('File not found');
    }
    throw error;
  }
}
}

module.exports = ProjInfoController
