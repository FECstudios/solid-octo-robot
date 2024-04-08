const path = require('path');

module.exports = {
  mode: 'production',
  entry: './beta.js', // Change this to the path of your script
  output: {
    filename: 'bundle.js', // Output file name
    path: path.resolve(__dirname, 'dist'), // Output directory
  },
  target: 'node',
  externals: {
    'node-fetch': 'commonjs2 node-fetch', // Exclude node-fetch from bundling
  },
};
