const Tesseract = require('node-tesseract-ocr');
const translate = require('translate-google')
const express = require('express');
const multer = require('multer');
const path = require('path');
//npx kill-port 3000
let resultsText
const puppeteer = require('puppeteer-extra')
const StealthPlugin = require('puppeteer-extra-plugin-stealth')
puppeteer.use(StealthPlugin())
const AdblockerPlugin = require('puppeteer-extra-plugin-adblocker')
puppeteer.use(AdblockerPlugin({ blockTrackers: true }))
const UserAgent = require('user-agents');
let text2 
const axios = require('axios');
const fs = require('fs'); // Required for file operations

async function translateAndContinue(selectedLanguage) {

  (async () => {
    try {
      const browser = await puppeteer.launch({
        headless: false, // Set to false to show the browser window
        devtools: false,  // Open DevTools for debugging
      });
  
      const page = await browser.newPage();
      await page.goto('https://translatepic.com/');
  
      console.log('Google Translate page opened successfully!');
  
      // Select Turkish as the target language
      await page.select('#des_lang', selectedLanguage);
  
      // Click the button to upload an image
      await page.click('.uploadimg');
  
      // Wait for the file chooser dialog to appear
      const fileChooser = await page.waitForFileChooser();
  
      // Original image URL (assuming the file is in the same directory as the script)
      const imageUrl = './uploads/file.png'; // Adjust if the file is in a different location
  
      // Upload the image
      await fileChooser.accept([imageUrl]);
      console.log('Image uploaded successfully!');
  
      // Wait for 5 seconds
      await new Promise((resolve) => setTimeout(resolve, 5000));
      console.log('Waited for 5 seconds');
  
      // Wait for the progress bar width to be 100%
      await page.waitForFunction(() => {
        const progressBar = document.querySelector('.progress-bar');
        return progressBar && progressBar.style.width === '100%';
      }, { timeout: 120000 }); // Increased timeout to 2 minutes
  
      console.log('Progress bar reached 100%');
  
      // Click the download button
      await page.click('#download_img');
      await new Promise((resolve) => setTimeout(resolve, 2500));
  
      // Default download directory (assuming Windows or Linux)
      const defaultDownloadPath = `${process.env.HOME || process.env.USERPROFILE}\\Downloads`;
  
      // Construct the source and destination paths
      const sourcePath = `${defaultDownloadPath}\\translatepic.png`;
      const destinationPath = `./translated/translatepic.png`; // Adjust destination folder
  
      // Copy the downloaded file (error handling included)
      try {
        fs.copyFileSync(sourcePath, destinationPath);
        console.log('File copied successfully!');
  
        // Remove the original file after successful copy
        fs.unlinkSync(sourcePath);
        console.log('Original file removed successfully!');
        await browser.close(); // Close the browser
      } catch (error) {
        console.error('Error copying or removing file:', error);
      }
  
    } catch (error) {
      console.error('Error:', error);
    } finally {
      console.log("DONE");
      
    }
  })();

}


const app = express();
const port = 3000;

// Set up multer storage
const storage = multer.diskStorage({
  destination: './uploads',
  filename: function (req, file, cb) {
    cb(null, 'file.png');
  }
});

const upload = multer({ storage: storage });

app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
  
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.post('/send', upload.single('file'), (req, res) => {
  const selectedLanguage = req.body.language;
  
  (async () => {
    try {
      translateAndContinue(selectedLanguage);
      await new Promise((resolve) => setTimeout(resolve, 45000));
      const config = {
        lang: 'eng', // Adjust for your desired language (e.g., 'tur' for Turkish)
        oem: 1,
        psm: 3,
      };
  
      
  
      // Translate the extracted text (if successful)
      
  
  
  try {
    const text = await Tesseract.recognize('./uploads/file.png', config);
    console.log('Extracted Text:', text);

    if (text) {
      const translatedText = await translate(text, { to: 'en' }); // Replace 'es' with your target language
      console.log('Translated Text:', translatedText);
     

      const browser = await puppeteer.launch({
        headless: false,
        ignoreHTTPSErrors: true,
        slowMo: 0,
        args: ['--window-size=1400,900',
        '--remote-debugging-port=9222',
        "--remote-debugging-address=0.0.0.0", // You know what your doing?
        '--disable-gpu', "--disable-features=IsolateOrigins,site-per-process", '--blink-settings=imagesEnabled=true'
        ]})
    const page = await browser.newPage();
    
    const userAgent = new UserAgent({ deviceCategory: 'desktop' });
    const randomUserAgent = userAgent.toString();
  
    await page.setUserAgent(randomUserAgent);


    await page.evaluateOnNewDocument(() => {
      delete navigator.__proto__.webdriver;
    });

    await page.goto('https://replicate.com/yorickvp/llava-13b', {
      waitUntil: "domcontentloaded",
    });
    console.log('time to get free api');
  
    // Check if there's an input element associated with the upload functionality
    const fileInput = await page.waitForSelector('input[type="file"][id="image"]');
  
    await new Promise((resolve) => setTimeout(resolve, 2500));
   
    // Upload the file using the full path
    await fileInput.uploadFile('./translated/translatepic.png');
    console.log('Image uploaded successfully!');
  
    await new Promise((resolve) => setTimeout(resolve, 2500));


  
//This is a Turkish math problem. Can you solve it for me please? If you dont understand the text translates to this (NUMBER OF THE TABLE MAY NOT BE CORRECT ON THE TRANSLATION) translation:
    // Set the desired text content
   // Remove all newline characters from translatedText
    const fixedtext = translatedText.replace(/\n/g, '');

    // Update text2 with the modified text
    text2 = `This is a math problem in the image. There might be translation issues but the numbers are correct. Can you solve it for me please? Text (might not be correct): ${fixedtext}`;


    console.log(text2);

    const promptSelector = 'textarea[id="prompt"]';

    // Clear any existing text (optional)
    await page.evaluate((selector, text) => {
      document.querySelector(selector).value = "";
    }, promptSelector, text2);
    
    async function typeTextWithShiftEnter(page, selector, text) {
      await page.focus(selector); // Focus on the textarea
    
      // Loop through each character in the text
      for (let char of text) {
        // If newline character, press Shift+Enter
        if (char === '\n') {
          await page.keyboard.press('Shift');
          await page.keyboard.press('Enter');

        } else {
          // Otherwise, type the character
          await page.keyboard.type(char, { delay: 1 }); // Adjust delay as needed
        }
      }
    }
    
    // Call the function to type the text with Shift+Enter for new lines
    await typeTextWithShiftEnter(page, promptSelector, text2);
    
    console.log('Filled textarea with custom text (using Shift+Enter for new lines)');

    console.log('Filled textarea with custom text (including new lines)')
    
    

    await new Promise((resolve) => setTimeout(resolve, 1000));

    
    // Proceed with clicking the "Run" button and other actions...
    const runButton = await page.waitForSelector('button[type="submit"][form="input-form"]');
    await runButton.click();
    console.log('Clicked "Run" button!');
    

  
    await new Promise((resolve) => setTimeout(resolve, 2500));
  



    const resultsElement = await page.waitForSelector('div[data-testid="value-output-string"]', { timeout: 0 });



  
    await new Promise((resolve) => setTimeout(resolve, 7500));
  
    // Extract the text content
    const resultsText = await resultsElement.evaluate(el => el.textContent.trim()); // Extract and trim text

    console.log('Results copied:', resultsText);

  }

      } catch (error) {
        console.error('Error:', error);
      } finally {
        res.send(resultsText)
        console.log("DONE");
        //await browser.close(); // Close the browser
      }
    } catch (error) {
      console.error('Error:', error);
    }
    
  })();

})

app.get('/translate', (req, res) => {
    const selectedLanguage = req.body.language;
    // Do something with the selected language and uploaded file
    (async () => {
      try {
        const browser = await puppeteer.launch({
          headless: false, // Set to false to show the browser window
          devtools: false,  // Open DevTools for debugging
        });
    
        const page = await browser.newPage();
        await page.goto('https://translatepic.com/');
    
        console.log('Google Translate page opened successfully!');
    
        // Select Turkish as the target language
        await page.select('#des_lang', selectedLanguage);
    
        // Click the button to upload an image
        await page.click('.uploadimg');
    
        // Wait for the file chooser dialog to appear
        const fileChooser = await page.waitForFileChooser();
    
        // Original image URL (assuming the file is in the same directory as the script)
        const imageUrl = './uploads/file.png'; // Adjust if the file is in a different location
    
        // Upload the image
        await fileChooser.accept([imageUrl]);
        console.log('Image uploaded successfully!');
    
        // Wait for 5 seconds
        await new Promise((resolve) => setTimeout(resolve, 5000));
        console.log('Waited for 5 seconds');
    
        // Wait for the progress bar width to be 100%
        await page.waitForFunction(() => {
          const progressBar = document.querySelector('.progress-bar');
          return progressBar && progressBar.style.width === '100%';
        }, { timeout: 120000 }); // Increased timeout to 2 minutes
    
        console.log('Progress bar reached 100%');
    
        // Click the download button
        await page.click('#download_img');
        await new Promise((resolve) => setTimeout(resolve, 2500));
    
        // Default download directory (assuming Windows or Linux)
        const defaultDownloadPath = `${process.env.HOME || process.env.USERPROFILE}\\Downloads`;
    
        // Construct the source and destination paths
        const sourcePath = `${defaultDownloadPath}\\translatepic.png`;
        const destinationPath = `./translated/translatepic.png`; // Adjust destination folder
    
        // Copy the downloaded file (error handling included)
        try {
          fs.copyFileSync(sourcePath, destinationPath);
          console.log('File copied successfully!');
    
          // Remove the original file after successful copy
          fs.unlinkSync(sourcePath);
          console.log('Original file removed successfully!');
        } catch (error) {
          console.error('Error copying or removing file:', error);
        }
    
      } catch (error) {
        console.error('Error:', error);
      } finally {
        console.log("DONE");
        //await browser.close(); // Close the browser
      }
    })();
  
    res.send(`Language: ${selectedLanguage}, File uploaded successfully!`);
})

app.listen(port, () => {
  console.log(`Server is listening at http://localhost:${port}`);
});





/*const inputElement = await page.waitForSelector('input#image'); // Adjust selector if needed

  if (inputElement) {
    // Upload the image directly using the input element
    await page.uploadFile('input#image', './uploads/file.png'); // Adjust paths if needed
  } else {
    console.warn('Input element not found. Trying to upload using other methods...');

    // Alternative approach if no input element is found
    // This might require further investigation of the website's structure
    // to find the appropriate selector for the upload functionality.

    // For example, you could try uploading based on a data attribute
    // await page.uploadFile('[data-test-id="upload-file"]', './uploads/file.png');
  }

  console.log('Image uploaded (hopefully)');

  await page.waitForSelector('textarea#prompt');

  // Inject JavaScript to input the translated text into the textarea
  await page.evaluate(() => {
    const translatedText = `This is a Turkish math problem. The text translates to this (NUMBER OF THE TABLE MAY NOT BE CORRECT ON THE TRANSLATION): + variable`;
    document.querySelector('textarea#prompt').value = translatedText;
  });
*/

/*

const express = require('express');
const multer = require('multer');
const path = require('path');
const puppeteer = require('puppeteer');
const fs = require('fs'); // Required for file operations

const app = express();
const port = 3000;

// Set up multer storage
const storage = multer.diskStorage({
  destination: './uploads',
  filename: function (req, file, cb) {
    cb(null, 'file.png');
  }
});

const upload = multer({ storage: storage });

app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});



app.listen(port, () => {
  console.log(`Server is listening at http://localhost:${port}`);
});
*/