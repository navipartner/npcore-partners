
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

            if (((i / 4 + 1) % 8) === 0) {
                var char = String.fromCharCode(parseInt(slicebits, 2));
                escpos += char;
                slicebits = '';
            }

        }

        if (slicebits != '') {
            slicebits = slicebits.padEnd(8, '0');
            var char = String.fromCharCode(parseInt(slicebits, 2));
            escpos += char;
        }

        ctx.putImageData(idata, 0, 0);

        const newBase64 = canvas.toDataURL('image/bmp');

        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('returnImage', [newBase64, escpos]);

        var Bytes = GetBytes(canvas.height);

        var Bytes2 = GetBytes(escpos.length + 10);

        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('returnESCPOSBytes', [Bytes[1], Bytes[0], Bytes2[1], Bytes2[0]]);
    }
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