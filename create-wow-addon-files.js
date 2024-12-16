const fs = require('fs');
const path = require('path');

// Define the files and directories to create
const filesToCreate = [
  'Core.lua',
  'Config.lua',
  'Utils.lua',
  'Data/MissionData.lua',
  'Data/FollowerData.lua',
  'UI/MainFrame.lua',
  'UI/MissionList.lua',
  'UI/FollowerList.lua',
  'UI/AutoComplete.lua',
  'UI/Settings.lua',
  'Locales/enUS.lua'
];

// Base directory where you want to create the files (current directory)
const baseDirectory = path.join(__dirname); // This will create the files in the directory where the script is run

// Function to create the files and directories
filesToCreate.forEach(filePath => {
  const fullFilePath = path.join(baseDirectory, filePath);
  const dirPath = path.dirname(fullFilePath);
  
  // Create the directories if they don't exist
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }

  // Create an empty file
  fs.writeFileSync(fullFilePath, '', 'utf8');
  console.log(`Created: ${fullFilePath}`);
});

console.log('File creation complete.');
