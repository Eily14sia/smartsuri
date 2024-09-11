const fs = require('fs')
const path = require('path')

// Get the current working directory
const currentDir = process.cwd()
// console.log(`Current working directory: ${currentDir}`);

// Get the date directory name from command-line arguments
const dateDirName = process.argv[2]

if (!dateDirName) {
  // console.error('Please provide a date directory name as an argument.');
  process.exit(1)
}

// Define the relative path to the logs directory
const relativeLogDir = '../sspiaccount_api/public/logs'

// Resolve the absolute path to the logs directory
const logDir = path.resolve(currentDir, relativeLogDir, dateDirName)

// console.log(`Testing directory existence: ${logDir}`);

function checkLogsInDirectory(directory) {
  try {
    const items = fs.readdirSync(directory)
    // console.log(`Directory contents:`, items);

    items.forEach((item) => {
      const itemPath = path.join(directory, item)
      const stats = fs.lstatSync(itemPath)

      if (stats.isDirectory()) {
        // console.log(`Entering directory: ${itemPath}`);
        // Recursively check subdirectories
        checkLogsInDirectory(itemPath)
      } else if (path.extname(item) === '.txt') {
        // console.log(`Checking file: ${itemPath}`);
        try {
          const content = fs.readFileSync(itemPath, 'utf-8')
          if (content.includes('error') || content.includes('Error') || content.includes('ERROR')) {
            console.log(`Error found in file: ${itemPath}`)
          }
        } catch (err) {
          console.error(`Error reading file ${itemPath}: ${err.message}`)
        }
      }
    })
  } catch (err) {
    console.error(`Error reading directory ${directory}: ${err.message}`)
  }
}

try {
  if (fs.existsSync(logDir)) {
    // console.log('Directory exists.');
    // Start checking logs in the date directory
    checkLogsInDirectory(logDir)
  } else {
    console.log('Directory does not exist.')
  }
} catch (err) {
  console.error(`Error checking directory: ${err.message}`)
}
