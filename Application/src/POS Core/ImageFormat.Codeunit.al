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

    local procedure GetSignature(SignatureBytes: array[10] of Byte; NoOfBytes: integer): Text;
    var
        i: Integer;
        Result: text;
    begin
        for i := 1 to NoOfBytes do
            Result := Result + ByteToHex(SignatureBytes[i]);
        exit(Result);
    end;

    /// <summary>
    /// Gets image format from stream. It does so by analyzing the stream header bytes, as explained in https://en.wikipedia.org/wiki/List_of_file_signatures
    /// </summary>
    /// <param name="InStr">Input stream to get image format from. It has to be by reference, because the stream is read inside the function.
    /// If it were not by reference, the stream would be unusable after completion of this function.</param>
    /// <returns>Image format (if succesfully identified), or empty string (if not identified)</returns>
    procedure GetImageExtensionFromHeader(var InStr: InStream): Text;
    var
        TempBlob: Codeunit "Temp Blob";
        InStrCopy: InStream;
        OutStr: OutStream;
        SignatureBytes: array[10] of Byte;
        c: Byte;
        i: Integer;
    begin
        // Copy stream for header analysis
        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        TempBlob.CreateInStream(InStrCopy);

        // Resetting the original stream variable (because it was fully read)
        TempBlob.CreateInStream(InStr);

        for i := 1 to ArrayLen(SignatureBytes) do begin
            InStrCopy.Read(c);
            SignatureBytes[i] := c;
        end;

        // JPEG headers
        if GetSignature(SignatureBytes, 4) = 'FFD8FFDB' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFE0' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFEE' then exit('jpeg');
        if GetSignature(SignatureBytes, 4) = 'FFD8FFE1' then exit('jpeg');

        // PNG header
        if GetSignature(SignatureBytes, 4) = '89504E47' then exit('png');

        // BMP header
        if GetSignature(SignatureBytes, 2) = '424D' then exit('bmp');

        // GIF headers
        if GetSignature(SignatureBytes, 6) = '474946383761' then exit('gif');
        if GetSignature(SignatureBytes, 6) = '474946383961' then exit('gif');

        // TIFF headers
        if GetSignature(SignatureBytes, 4) = '49492A00' then exit('tiff');
        if GetSignature(SignatureBytes, 4) = '4D4D002A' then exit('tiff');

        // ICO header
        if GetSignature(SignatureBytes, 4) = '00000100' then exit('ico');

        // WMF header
        if GetSignature(SignatureBytes, 4) = 'D7CDC69A' then exit('wmf');
    end;
}
