const {writeFileSync} = require('fs');

const {version} = require('./package.json');
const elmJSON = require('./elm.json');

elmJSON.version = process.env.npm_package_version;

writeFileSync('elm.json', JSON.stringify(elmJSON, null, 4));
