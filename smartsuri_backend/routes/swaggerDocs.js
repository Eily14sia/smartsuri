/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: Authentication related endpoints
 */

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Log in a user
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *                 description: The user's username
 *                 example: User1
 *               password:
 *                 type: string
 *                 description: The user's password
 *                 example: 12345
 *     responses:
 *       200:
 *         description: Successful login
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token:
 *                   type: string
 *                   description: JWT token
 *       401:
 *         description: Invalid username or password / Account Inactive
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * tags:
 *   - name: CRUD
 *     description: Create, Update, Delete related endpoints
 *   - name: Users
 *     description: User related operations
 *   - name: Project
 *     description: Project related operations
 *   - name: Sites
 *     description: Site related operations
 *   - name: Project Types
 *     description: Project Type related operations
 *   - name: Companies
 *     description: Company related operations
 *   - name: Roles
 *     description: Role related operations
 *   - name: Access
 *     description: Access related operations
 */

/**
 * @swagger
 * /api/crud/user/createUser:
 *   post:
 *     summary: Create a new user
 *     tags: [CRUD, Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *                 example: user123
 *               password:
 *                 type: string
 *                 example: password123
 *               email:
 *                 type: string
 *                 example: user@example.com
 *               role_id:
 *                 type: integer
 *                 example: 1
 *               company_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       200:
 *         description: User created successfully
 *       400:
 *         description: Invalid input
 *       404:
 *         description: Account type not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/user/deleteUser/{id}:
 *   put:
 *     summary: Delete a user by ID
 *     tags: [CRUD, Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: User deleted successfully
 *       404:
 *         description: User not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/user/updateUser/{id}:
 *   put:
 *     summary: Update user by ID
 *     tags: [CRUD, Users]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               username:
 *                 type: string
 *                 example: user123
 *               password:
 *                 type: string
 *                 example: password123
 *               role_id:
 *                 type: integer
 *                 example: 1
 *               company_id:
 *                 type: integer
 *                 example: 1
 *               name:
 *                 type: string
 *                 example: Manila
 *               email:
 *                 type: string
 *                 example: user@example.com
 *               isActive:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: User updated successfully
 *       400:
 *         description: Invalid input / Username already exists / Invalid role
 *       404:
 *         description: User not found / Account type not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/projInfo/createProjInfo:
 *   post:
 *     summary: Create a new project
 *     tags: [CRUD, Project]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: LGU
 *               description:
 *                 type: string
 *                 example: Testing
 *               project_type_id:
 *                 type: integer
 *                 example: 2
 *               company_id:
 *                 type: integer
 *                 example: 1
 *               site_id:
 *                 type: integer
 *                 example: 1
 *               isDemo:
 *                 type: boolean
 *                 example: true
 *               logo:
 *                 type: file
 *                 description: "Logo should be an image"
 *               device_id:
 *                 type: string
 *                 example: device id laptop
 *               app_version:
 *                 type: string
 *                 example: 1.0
 *     responses:
 *       200:
 *         description: User created successfully
 *       400:
 *         description: Invalid input
 *       404:
 *         description: Account type not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/projInfo/deleteProjInfo/{id}:
 *   put:
 *     summary: Delete a project by ID
 *     tags: [CRUD, Project]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: User deleted successfully
 *       404:
 *         description: User not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/projInfo/updateProjInfo/{id}:
 *   post:
 *     summary: Update project information by ID
 *     tags: [CRUD, Project]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Updated Name
 *               description:
 *                 type: string
 *                 example: Updated description
 *               project_type_id:
 *                 type: integer
 *                 example: 1
 *               company_id:
 *                 type: integer
 *                 example: 1
 *               site_id:
 *                 type: integer
 *                 example: 1
 *               isDemo:
 *                 type: boolean
 *                 example: true
 *               isActive:
 *                 type: boolean
 *                 example: true
 *               logo:
 *                 type: file
 *                 description: Logo should be an image
 *               device_id:
 *                 type: string
 *                 example: updated device id laptop
 *               app_version:
 *                 type: string
 *                 example: updated 1.0
 *     responses:
 *       200:
 *         description: Project information updated successfully
 *       400:
 *         description: Invalid input
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/site/createSite:
 *   post:
 *     summary: Create a new site
 *     tags: [CRUD, Sites]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: LGU
 *               url:
 *                 type: string
 *                 example: https://
 *               domain:
 *                 type: string
 *                 example: lgu.com
 *               ip:
 *                 type: string
 *                 example: 194.168.01
 *     responses:
 *       200:
 *         description: Site created successfully
 *       400:
 *         description: Site name already exists
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/site/deleteSite/{id}:
 *   put:
 *     summary: Delete a site by ID
 *     tags: [CRUD, Sites]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Site deleted successfully
 *       404:
 *         description: Site not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/site/updateSite/{id}:
 *   put:
 *     summary: Update site by ID
 *     tags: [CRUD, Sites]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Updated Site Name
 *               url:
 *                 type: string
 *                 example: Updated url
 *               domain:
 *                 type: string
 *                 example: Updated domain
 *               ip:
 *                 type: string
 *                 example: Updated ip
 *               isActive:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Site updated successfully
 *       404:
 *         description: Site not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/projType/createProjType:
 *   post:
 *     summary: Create a new project type
 *     tags: [CRUD, Project Types]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               type_name:
 *                 type: string
 *                 example: Makati
 *               description:
 *                 type: string
 *                 example: test
 *     responses:
 *       200:
 *         description: Project type created successfully
 *       400:
 *         description: Project type name already exists
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/projType/deleteProjType/{id}:
 *   put:
 *     summary: Delete a project type by ID
 *     tags: [CRUD, Project Types]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Project type deleted successfully
 *       404:
 *         description: Project type not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/projType/updateProjType/{id}:
 *   put:
 *     summary: Update project type by ID
 *     tags: [CRUD, Project Types]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               type_name:
 *                 type: string
 *                 example: Updated Project Type Name
 *               description:
 *                 type: string
 *                 example: Updated Project Type Description
 *               isActive:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Project type updated successfully
 *       404:
 *         description: Project type not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/company/createCompany:
 *   post:
 *     summary: Create a new company
 *     tags: [CRUD, Companies]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Company1
 *     responses:
 *       200:
 *         description: Company created successfully
 *       400:
 *         description: Company name already exists
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/company/deleteCompany/{id}:
 *   put:
 *     summary: Delete a company by ID
 *     tags: [CRUD, Companies]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Company deleted successfully
 *       404:
 *         description: Company not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/company/updateCompany/{id}:
 *   put:
 *     summary: Update company by ID
 *     tags: [CRUD, Companies]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Updated Company
 *               isActive:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Company updated successfully
 *       404:
 *         description: Company not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/role/createRole:
 *   post:
 *     summary: Create a new role
 *     tags: [CRUD, Roles]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Role1
 *     responses:
 *       200:
 *         description: Role created successfully
 *       400:
 *         description: Role name already exists
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/role/deleteRole/{id}:
 *   put:
 *     summary: Delete a role by ID
 *     tags: [CRUD, Roles]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Role deleted successfully
 *       404:
 *         description: Role not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/role/updateRole/{id}:
 *   put:
 *     summary: Update role by ID
 *     tags: [CRUD, Roles]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: Updated Role
 *               isActive:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Role updated successfully
 *       404:
 *         description: Role not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/access/createAccess:
 *   post:
 *     summary: Create new access
 *     tags: [CRUD, Access]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               web_access:
 *                 type: object
 *                 example: { "key1": "value1", "key2": "value2" }
 *               app_access:
 *                 type: object
 *                 example: { "key1": "value1", "key2": "value2" }
 *               role_id:
 *                 type: integer
 *                 example: 1
 *
 *     responses:
 *       200:
 *         description: Access created successfully
 *       400:
 *         description: Invalid input
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/access/deleteAccess/{id}:
 *   put:
 *     summary: Delete access by ID
 *     tags: [CRUD, Access]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Access deleted successfully
 *       404:
 *         description: Access not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/crud/access/updateAccess/{id}:
 *   put:
 *     summary: Update access by ID
 *     tags: [CRUD, Access]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - name: id
 *         in: path
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/x-www-form-urlencoded:
 *           schema:
 *             type: object
 *             properties:
 *               web_access:
 *                 type: object
 *                 example: { "key1": "Updated value1", "key2": "Updated value2" }
 *               app_access:
 *                 type: object
 *                 example: { "key1": "Updated value1", "key2": "Updated value2" }
 *               isActive:
 *                 type: boolean
 *                 example: true
 *               role_id:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       200:
 *         description: Access updated successfully
 *       400:
 *         description: Invalid input
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * tags:
 *   name: SuperAdmin
 *   description: Super Admin related endpoints
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     Project:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *     ProjectType:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *     Site:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *     Log:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         message:
 *           type: string
 *     Company:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *     Role:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *     Access:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 */

/**
 * @swagger
 * /api/superAdmin/projects:
 *   get:
 *     summary: Get all projects
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successful retrieval of projects
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Project'
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/projectTypes:
 *   get:
 *     summary: Get all project types
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successful retrieval of project types
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/ProjectType'
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/sites:
 *   get:
 *     summary: Get all sites
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successful retrieval of sites
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Site'
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/projects/{id}:
 *   get:
 *     summary: Get project by ID
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Successful retrieval of project
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Project'
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Project not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/projectTypes/{id}:
 *   get:
 *     summary: Get project type by ID
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Successful retrieval of project type
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ProjectType'
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Project type not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/sites/{id}:
 *   get:
 *     summary: Get site by ID
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Successful retrieval of site
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Site'
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Site not found
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/logs:
 *   get:
 *     summary: Get all logs
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successful retrieval of logs
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Log'
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/company:
 *   get:
 *     summary: Get all companies
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successful retrieval of companies
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Company'
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/roles:
 *   get:
 *     summary: Get all roles
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successful retrieval of roles
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Role'
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */

/**
 * @swagger
 * /api/superAdmin/access:
 *   get:
 *     summary: Get all access
 *     tags: [SuperAdmin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successful retrieval of access
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Access'
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Internal server error
 */
