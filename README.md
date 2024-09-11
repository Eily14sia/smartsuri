to run both projects
1. clone project
2. open in vs code
3. To run Flutter App type in console
   - cd smartsuri
   - flutter doctor
   - flutter pub get
   - flutter run -d chrome
  
4. to run backend type in console (open separate console in vs code)
   -cd smartsuri_backend
   -npm install
   -npm start

5. make sure xampp (Apache and MySQL) is running and installed.
   
6. To migrate database (in backend directory)
  -open first phpmyAdmin via Xampp terminal in MYSQL
  -create a new database name (smartsuri)
  -then follow these steps in vs code
  - cd smartsuri_backend
  - npx sequelize db:migrate
  - npx sequelize db:seed:all
    
