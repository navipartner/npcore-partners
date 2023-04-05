
function ResizeImage(base64, imageExtension) {

    var img = document.createElement('img');

    img.setAttribute("src", Base64ToDataUri(base64, imageExtension));

    img.onload = () => {

        var width = img.width;
        var height = img.height;

        if (width >= 513) {
            var ratio = 512 / width;
            width = 512;
            height = Math.round(height * ratio);
        }

        var paddedHeight = height;

        if ((paddedHeight % 24) != 0) {
            paddedHeight = height + (24 - (height % 24));
        }

        var canvas = document.createElement('canvas');

        var ctx = canvas.getContext('2d');

        canvas.width = 512;
        canvas.height = paddedHeight;

        ctx.drawImage(img, 0, 0, width, height);
        ctx.globalCompositeOperation = "destination-over";
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        var idata = ctx.getImageData(0, 0, canvas.width, canvas.height);

        var buffer = idata.data,
            len = buffer.length,
            threshold = 127,
            i, luma;
        var slicebits = '', escpos = '';

        debugger;
        let byteArray = new Uint8Array(Math.ceil(len/4/8));        
        let j = 0;

        for (i = 0; i < len; i += 4) {
            
            luma = buffer[i] * 0.3 + buffer[i + 1] * 0.59 + buffer[i + 2] * 0.11;

            luma = luma < threshold ? 0 : 255;

            buffer[i] = luma;
            buffer[i + 1] = luma;
            buffer[i + 2] = luma;

            if (luma < threshold) {
                slicebits += '1';
            }
            else {
                slicebits += '0';
            }

            if (slicebits.length === 8) {
                byteArray[j] = parseInt(slicebits, 2);                 
                j++;
                slicebits = '';
            }
        }

        if (slicebits != '') {
            slicebits = slicebits.padEnd(8, '0');
            debugger;
            byteArray[j] = parseInt(slicebits, 2);
        }

        ctx.putImageData(idata, 0, 0);

        let newBase64 = canvas.toDataURL('image/bmp');
        let Bytes = GetBytes(canvas.height);
        let Bytes2 = GetBytes(byteArray.length + 10);

        base64arraybuffer(byteArray)
            .then((result) => Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('returnImage', [newBase64, result, Bytes[1], Bytes[0], Bytes2[1], Bytes2[0]]))
            .catch(reason => alert(reason));
    }
}

//https://stackoverflow.com/a/66046176
async function base64arraybuffer(data) {
    // Use a FileReader to generate a base64 data URI
    const base64url = await new Promise((r) => {
        const reader = new FileReader()
        reader.onload = () => r(reader.result)
        reader.readAsDataURL(new Blob([data]))
    })

    /*
    The result looks like 
    "data:application/octet-stream;base64,<your base64 data>", 
    so we split off the beginning:
    */
    return base64url.split(",", 2)[1]
}

function Base64ToDataUri(base64, imageExtension) {
    return 'data:image/' + imageExtension + ';base64,' + base64
}

function GetBytes(int) {
    var b = new ArrayBuffer(8);
    b[0] = int & 0xFF;
    b[1] = (int >> 8) & 0xFF;
    return b;
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('OnCtrlReady', '')