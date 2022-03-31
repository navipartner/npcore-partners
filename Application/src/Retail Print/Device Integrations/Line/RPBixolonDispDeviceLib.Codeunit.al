codeunit 6014541 "NPR RP BixolonDisp Device Lib." implements "NPR ILine Printer"
{
    Access = Internal;

    var
        _PrintBuffer: Codeunit "Temp Blob";
        _DotNetStream: Codeunit DotNet_Stream;
        _DotNetEncoding: Codeunit DotNet_Encoding;

    procedure InitJob(var DeviceSettings: Record "NPR RP Device Settings")
    var
        OStream: OutStream;
    begin
        Clear(OStream);
        Clear(_PrintBuffer);
        Clear(_DotNetStream);
        Clear(_DotNetEncoding);
        _PrintBuffer.CreateOutStream(OStream);
        _DotNetEncoding.Encoding(437);
        _DotNetStream.FromOutStream(OStream);

        InitializePrinter();
    end;

    local procedure AddStringToBuffer(String: Text)
    var
        DotNetCharArray: Codeunit "DotNet_Array";
        DotNetByteArray: Codeunit "DotNet_Array";
        DotNetString: Codeunit "DotNet_String";
    begin
        //This function over allocates and is verbose, all because of the beautiful DotNet wrapper codeunits.

        DotNetString.Set(String);
        DotNetString.ToCharArray(0, DotNetString.Length(), DotNetCharArray);
        _DotNetEncoding.GetBytes(DotNetCharArray, 0, DotNetCharArray.Length(), DotNetByteArray);
        _DotNetStream.Write(DotNetByteArray, 0, DotNetByteArray.Length());
    end;

    procedure PrintData(var POSPrintBuffer: Record "NPR RP Print Buffer" temporary)
    begin
        AddStringToBuffer(POSPrintBuffer.Text);
    end;

    procedure GetPageWidth(FontFace: Text[30]; var Width: Integer)
    begin
        Width := GetPageWidth(FontFace);
    end;

    procedure EndJob()
    begin
    end;

    procedure LookupFont(var Font: Text): Boolean
    begin
        Font := '';
        Exit(false);
    end;

    procedure LookupCommand(var Command: Text): Boolean
    begin
        Command := '';
        Exit(false);
    end;

    procedure GetPrintBufferAsBase64(): Text
    var
        base64: Codeunit "Base64 Convert";
        IStream: InStream;
    begin
        _PrintBuffer.CreateInStream(IStream);
        exit(base64.ToBase64(IStream));
    end;

    procedure GetPageWidth(FontFace: Text[30]) Width: Integer
    begin
        Width := 20;
    end;

    local procedure InitializePrinter()
    begin
        _DotNetStream.WriteByte(27); //ESC
        AddStringToBuffer('@');
        _DotNetStream.WriteByte(27);
        AddStringToBuffer('=');
        _DotNetStream.WriteByte(2);
        _DotNetStream.WriteByte(27);
        AddStringToBuffer('R');
        _DotNetStream.WriteByte(4); //EOT        
    end;

    procedure LineFeed();
    begin
    end;

    procedure LookupDeviceSetting(var tmpDeviceSetting: Record "NPR RP Device Settings" temporary): Boolean;
    begin
    end;

    procedure PrepareJobForHTTP(var HTTPEndpoint: Text): Boolean;
    begin
        HTTPEndpoint := '';
        exit(false);
    end;

    procedure PrepareJobForBluetooth(): Boolean;
    begin
    end;
}

