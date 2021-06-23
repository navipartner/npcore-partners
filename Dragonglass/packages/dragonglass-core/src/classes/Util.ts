const base64abc = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"
];

export class Util {

    static utf8to16(str: string): Uint8Array {
        const buffer8 = new ArrayBuffer(str.length * 2);
        const buffer16 = new Uint16Array(buffer8);
        for (let i = 0, strLen = str.length; i < strLen; i++) {
            buffer16[i] = str.charCodeAt(i);
        }
        return new Uint8Array(buffer16.buffer, buffer16.byteOffset, buffer16.byteLength);
    }

    static normalizeFromUtf16(str: string): string {
        const buffer = [];
        for (let i = 0; i < str.length; i += 2) {
            buffer.push(str.charCodeAt(i));
        }
        return String.fromCharCode.apply(null, buffer);
    }

    static guid(): string {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            let r = Math.random() * 16 | 0,
                v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    static bytesToBase64(bytes: any) {
        let result = '', i, l = bytes.length;
        for (i = 2; i < l; i += 3) {
            result += base64abc[bytes[i - 2] >> 2];
            result += base64abc[((bytes[i - 2] & 0x03) << 4) | (bytes[i - 1] >> 4)];
            result += base64abc[((bytes[i - 1] & 0x0F) << 2) | (bytes[i] >> 6)];
            result += base64abc[bytes[i] & 0x3F];
        }
        if (i === l + 1) {
            result += base64abc[bytes[i - 2] >> 2];
            result += base64abc[(bytes[i - 2] & 0x03) << 4];
            result += "==";
        }
        if (i === l) {
            result += base64abc[bytes[i - 2] >> 2];
            result += base64abc[((bytes[i - 2] & 0x03) << 4) | (bytes[i - 1] >> 4)];
            result += base64abc[(bytes[i - 1] & 0x0F) << 2];
            result += "=";
        }
        return result;
    }
    
}
