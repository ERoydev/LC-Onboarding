const fs = require('fs');
const path = require('path');

// `node script/CopyABI.js` ====> Execution command


// Helper function to copy and extract ABI
function copyABI(contract) {
    const fileName = contract;
    let contractName = contract;
 
    const sourcePath = path.join(__dirname, `../out/${fileName}.sol/${contractName}.json`);
    const destinationPath = path.join(__dirname, `../frontend/src/abi/${contractName}.json`);

    const destinationDir = path.dirname(destinationPath);
    if (!fs.existsSync(destinationDir)) {
        fs.mkdirSync(destinationDir, { recursive: true });
    }

    fs.readFile(sourcePath, 'utf8', (err, data) => {
        if (err) {
            console.error(`Error reading source file for ${contractName}:`, err);
            return;
        }

        try {
            const jsonData = JSON.parse(data);
            const abi = jsonData.abi;

            fs.writeFile(destinationPath, JSON.stringify(abi, null, 2), 'utf8', (err) => {
                if (err) {
                    console.error(`Error writing ABI for ${contractName}:`, err);
                } else {
                    console.log(`ABI for ${contractName} successfully copied to:`, destinationPath);
                }
            });
        } catch (parseError) {
            console.error(`Error parsing ABI JSON for ${contractName}:`, parseError);
        }
    });
}

// Copy both NFT and Auction ABIs
copyABI("NFT");
copyABI("EnglishAuction");
copyABI("ERC20Mock");