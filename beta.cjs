const fs = require('fs');
const path = require('path');
const request = require('request');

const URL = "https://local.basiccat.org:51043";

function ajax(filePath) {
    // Read the image file
    fs.readFile(filePath, (err, data) => {
        if (err) {
            console.error('Failed to read the image file:', err);
            return;
        }

        // Convert the image data to a base64-encoded data URL
        const dataURL = 'data:image/jpeg;base64,' + data.toString('base64');

        // Prepare the data for the AJAX request
        const requestData = { src: dataURL };

        console.log("Sending AJAX request...");

        // Send the AJAX request
        request.post({
            url: URL + '/translate',
            form: requestData
        }, (error, response, body) => {
            if (error) {
                console.error('Failed to connect to ImageTrans server:', error);
                return;
            }

            console.log('Response from server:', body);
            // Further processing of the response
        });
    });
}

// Path to the image file
const imagePath = path.join(__dirname, 'uploads', 'file.png');

// Call the ajax function with the path to the image file
ajax(imagePath);