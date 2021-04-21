codeunit 6014561 "NPR Image Format"
{
    procedure ByteToHex(ByteValue: Byte): Text;
    var
        a: byte;
        b: byte;
        left: Text;
        right: Text;
    begin
        a := ByteValue DIV 16;
        b := ByteValue MOD 16;

        case a of
            0:
                left := '0';
            1:
                left := '1';
            2:
                left := '2';
            3:
                left := '3';
            4:
                left := '4';
            5:
                left := '5';
            6:
                left := '6';
            7:
                left := '7';
            8:
                left := '8';
            9:
                left := '9';
            10:
                left := 'A';
            11:
                left := 'B';
            12:
                left := 'C';
            13:
                left := 'D';
            14:
                left := 'E';
            15:
                left := 'F';
        end;

        case b of
            0:
                right := '0';
            1:
                right := '1';
            2:
                right := '2';
            3:
                right := '3';
            4:
                right := '4';
            5:
                right := '5';
            6:
                right := '6';
            7:
                right := '7';
            8:
                right := '8';
            9:
                right := '9';
            10:
                right := 'A';
            11:
                right := 'B';
            12:
                right := 'C';
            13:
                right := 'D';
            14:
                right := 'E';
            15:
                right := 'F';
        end;
        exit(left + right);
    end;

    procedure GetSignature(SignatureBytes: array[10] of Byte; NoOfBytes: integer): Text;
    var
        i: Integer;
        Result: text;
    begin
        for i := 1 to NoOfBytes do
            Result := Result + ByteToHex(SignatureBytes[i]);
        exit(Result);
    end;

    procedure GetImageExtensionFromHeader(InS: InStream): Text;
    var
        SignatureBytes: array[10] of Byte;
        c: Char;
        i: Integer;
        UnknownImageFormatErr: Label 'Unknown/unrecognized image format.';
    begin
        for i := 1 to ArrayLen(SignatureBytes) do begin
            InS.Read(c);
            SignatureBytes[i] := c;
        end;

        //File signatues:
        //  https://en.wikipedia.org/wiki/List_of_file_signatures

        //FF D8 FF DB - jpeg
        //FF D8 FF E0 - jpeg
        //FF D8 FF EE - jpeg
        //FF D8 FF E1 - jpeg
        if GetSignature(SignatureBytes, 4) = 'FFD8FFDB' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFE0' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFEE' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFE1' then exit('jpeg');
        //89 50 4E 47 - png
        if GetSignature(SignatureBytes, 4) = '89504E47' then exit('png');
        //42 4D - bmp
        if GetSignature(SignatureBytes, 2) = '424D' then exit('bmp');
        //47 49 46 38 37 61 - gif
        //47 49 46 38 39 61 - gif
        if GetSignature(SignatureBytes, 6) = '474946383761' then exit('gif');
        if GetSignature(SignatureBytes, 6) = '474946383961' then exit('gif');
        //49 49 2A 00 - tiff
        //4D 4D 00 2A - tiff
        if GetSignature(SignatureBytes, 4) = '49492A00' then exit('tiff');
        if GetSignature(SignatureBytes, 4) = '4D4D002A' then exit('tiff');
        //00 00 01 00 - ico
        if GetSignature(SignatureBytes, 4) = '00000100' then exit('ico');
        //D7 CD C6 9A - wmf
        if GetSignature(SignatureBytes, 4) = 'D7CDC69A' then exit('wmf');

        Error(UnknownImageFormatErr);
    end;
}