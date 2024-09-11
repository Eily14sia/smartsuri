------------ START -----------

1. npm install 
2. npx sequelize-cli db:migrate (for creating db) create first a database named nodetrial in mysql to migrate the necessary tables
3. npx sequelize -cli db:seed:all (for inserting dummy data in the db)

--------Credential for logging in the api----------

username: User1
password: 12345

--------Routes---------
1. authRoutes for login generation of JWT for authorization in the other api's
2. superAdminRoutes for getting all the data of users and user by ID API's
3. userRoutes for creating a user and deactivating/deleting a user.

-------In Progress-------
1. UpdateSave API's (DONE)
2. Log Data not yet applied but already created a table for that (DONE)

-------Error Codes-------

1. 500 Internal Server Error: This status code indicates that the server encountered an unexpected condition that prevented it from fulfilling the request. It's a generic error message returned when no more specific message is suitable.
2. 400 Bad Request: This status code indicates that the server could not understand the request due to malformed syntax, missing parameters, or invalid data within the request. It's often used when the server cannot or will not process the request due to something that is perceived to be a client error.
3. 404 Not Found: This status code indicates that the server cannot find the requested resource. It's commonly used when a client requests a URL that does not correspond to any existing resource on the server.
4. 401 Unauthorized: Indicates that the client is not authorized to access the requested resource. This typically happens when the client lacks valid authentication credentials or the provided credentials are invalid/expired.
5. 403 Forbidden: Indicates that the server understood the request but refuses to authorize it. This status code is used when the client's credentials are valid, but they do not have permission to access the requested resource.

-------Result Codes-------
1. 200 Success: The request has succeeded.
