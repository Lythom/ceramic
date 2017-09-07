
var download = require('download');
var fs = require('fs');
var path = require('path');
var decompress = require('decompress');
var rimraf = require('rimraf');
var ncp = require('ncp').ncp;

var vendorDir = __dirname + '/vendor';
var nodeBin = path.join(vendorDir, 'node/node.exe');

function fixReactIconsTypings(next) {

    var rootPath = path.normalize(path.join(__dirname, 'node_modules/@types/react-icons'));
    var libPath = path.normalize(path.join(__dirname, 'node_modules/@types/react-icons/lib'));

    if (!fs.existsSync(libPath)) {

        console.log('Create ' + libPath);

        ncp(rootPath, libPath, {
            filter: function(name) {
                name = path.normalize(name);
                return !name.startsWith(libPath);
            }
        }, function(err) {
            if (err) throw err;

            downloadNode();
        });

    } else {
        downloadNode();
    }

} //fixReactIconsTypings

function downloadNode() {

    // Download node
    var url;
    if (process.platform == 'darwin') {
        // No need to download node on mac
        return;
    } else if (process.platform == 'win32') {
        url = 'https://nodejs.org/dist/v6.11.1/node-v6.11.1-win-x64.zip';
    }
    var archiveRootDirName = 'node-v6.11.1-win-x64';
    var archiveName = url.substr(url.lastIndexOf('/') + 1);
    if (!fs.existsSync(nodeBin)) {

        console.log('Download ' + url);
        download(url)
        .then(data => {
            // Write tar.gz
            var archivePath = path.join(vendorDir, archiveName);
            fs.writeFileSync(archivePath, data);

            // Extract archive
            decompress(archivePath, vendorDir).then(() => {

                fs.unlinkSync(archivePath);
                fs.renameSync(path.join(vendorDir, archiveRootDirName), path.join(vendorDir, 'node'));

            }, (err) => {
                throw err;
            });

        }, error => {
            throw error;
        });

    }

} //downloadNode

fixReactIconsTypings();