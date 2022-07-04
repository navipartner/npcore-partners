codeunit 6014587 "NPR Hardware Connector Mgt."
{
    // This object invokes the local machine from a browser via a modal page, intended to be run from outside the POS. 
    // It will work, even inside POS, but you should avoid the modal page by invoking the hardware connector directly from the javascript of a v3 action.
    Access = Public;

    var
        PrintLbl: Label 'Printing...';
        FileMoveLbl: Label 'Moving file...';        

    internal procedure SendRawPrintRequest(PrinterName: Text; PrintJobBase64: Text)
    var
        Content: JsonObject;
        Response: JsonObject;
    begin
        Content.Add('PrinterName', PrinterName);
        Content.Add('PrintJob', PrintJobBase64);

        SendGenericRequest('RawPrint', Content, PrintLbl, true, 'success', 'errorText', true, Response);
    end;

    internal procedure SendFilePrintRequest(PrinterName: Text; Stream: InStream; FileExtension: Text)
    var
        Content: JsonObject;
        Base64Convert: Codeunit "Base64 Convert";
        AzureKeyVault: Codeunit "NPR Azure Key Vault Mgt.";
        Response: JsonObject;
    begin
        Content.Add('PrinterName', PrinterName);
        Content.Add('FileData', Base64Convert.ToBase64(Stream));
        Content.Add('FileExtension', FileExtension);

        if UpperCase(FileExtension) = 'PDF' then begin
            Content.Add('PrintMethod', 'Spire');
            Content.Add('ExternalLibLicenseKey', AzureKeyVault.GetAzureKeyVaultSecret('SpirePDFDotNetCoreLicenseKey'))
        end else begin
            Content.Add('PrintMethod', 'OSFileHandler');
        end;

        SendGenericRequest('FilePrint', Content, PrintLbl, true, 'Printed', 'ErrorMessage', true, Response);
    end;

    internal procedure MoveFileRequest(SourcePath: Text; DestinationPath: Text);
    var
        Content: JsonObject;
        Response: JsonObject;
    begin
        Content.Add('operation', 'move');
        Content.Add('source', SourcePath);
        Content.Add('destination', DestinationPath);

        SendGenericRequest('File', Content, FileMoveLbl, true, 'success', 'errorText', true, Response);
    end;

    internal procedure ExistsFileRequest(Path: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Checking if file exists...';
    begin
        Request.Add('operation', 'exists');
        Request.Add('path', Path);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure CopyFileRequest(SourcePath: Text; DestinationPath: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Copying file...';
    begin
        Request.Add('operation', 'copy');
        Request.Add('source', SourcePath);
        Request.Add('destination', DestinationPath);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure DeleteFileRequest(Path: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Deleting file...';

    begin
        Request.Add('operation', 'delete');
        Request.Add('path', Path);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure WriteTextRequest(Path: Text; Content: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Writing text into file...';

    begin
        Request.Add('operation', 'writeText');
        Request.Add('path', Path);
        Request.Add('contents', Content);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure WriteLinesRequest(Path: Text; Content: JsonToken) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Writing lines into file...';

    begin
        Request.Add('operation', 'writeLines');
        Request.Add('path', Path);
        Request.Add('contents', Content.AsArray());

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure WriteBinaryRequest(Path: Text; var TempBlob: Codeunit "Temp Blob") Response: JsonObject
    var
        Base64: Codeunit "Base64 Convert";
        InStream: InStream;
        Bytes: Text;
        Request: JsonObject;
        Caption: Label 'Writing binary into file...';
    begin
        TempBlob.CreateInStream(InStream);
        Bytes := Base64.ToBase64(InStream);

        Request.Add('operation', 'writeBinary');
        Request.Add('path', Path);
        Request.Add('contents', Bytes);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure AppendTextRequest(Path: Text; Content: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Appending text into file...';

    begin
        Request.Add('operation', 'appendText');
        Request.Add('path', Path);
        Request.Add('contents', Content);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure AppendLinesRequest(Path: Text; Content: JsonToken) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Appending lines into file...';

    begin
        Request.Add('operation', 'appendLines');
        Request.Add('path', Path);
        Request.Add('contents', Content.AsArray());

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    procedure ReadTextRequest(Path: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Reading text from file...';

    begin
        Request.Add('operation', 'readText');
        Request.Add('path', Path);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure ReadLinesRequest(Path: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Reading lines from file...';

    begin
        Request.Add('operation', 'readLines');
        Request.Add('path', Path);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure ReadBinaryRequest(Path: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Reading binary from file...';

    begin
        Request.Add('operation', 'readBinary');
        Request.Add('path', Path);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure ExistsDirectoryRequest(Path: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Checking if directory exists...';

    begin
        Request.Add('operation', 'directory.exists');
        Request.Add('path', Path);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure CopyDirectoryRequest(SourcePath: Text; DestinationPath: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Copying directory...';

    begin
        Request.Add('operation', 'directory.copy');
        Request.Add('source', SourcePath);
        Request.Add('destination', DestinationPath);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure MoveDirectoryRequest(SourcePath: Text; DestinationPath: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Moving directory...';

    begin
        Request.Add('operation', 'directory.move');
        Request.Add('source', SourcePath);
        Request.Add('destination', DestinationPath);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure DeleteDirectoryRequest(Path: Text; Force: Boolean) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Deleting directory...';

    begin
        Request.Add('operation', 'directory.delete');
        Request.Add('path', Path);
        Request.Add('force', Force);


        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    internal procedure GetDirectoryContentRequest(Path: Text) Response: JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Getting directory content...';

    begin
        Request.Add('operation', 'directory.getContents');
        Request.Add('path', Path);

        SendGenericRequest('file', Request, Caption, true, 'success', 'errorText', true, Response);
    end;

    local procedure SendGenericRequest(Handler: Text; Request: JsonObject; WindowCaption: Text; AutoParseResponse: Boolean; ResponseSuccessElementName: Text; ResponseErrorReasonElementName: Text; ShowConnectionError: Boolean; var ResponseOut: JsonObject) ResponseReceived: Boolean
    var
        JToken: JsonToken;
        ResponseErr: Label 'Error when invoking %1:\\%2';
    begin
        Commit();
        ClearLastError();

        ResponseReceived := TrySendGenericRequest(Handler, Request, WindowCaption, ResponseOut);

        if (not ResponseReceived) and (ShowConnectionError) then begin
            Message(GetLastErrorText());
            exit;
        end;

        if ResponseReceived and AutoParseResponse then begin
            ResponseOut.Get(ResponseSuccessElementName, JToken);
            if not (JToken.AsValue().AsBoolean()) then begin
                ResponseOut.Get(ResponseErrorReasonElementName, JToken);
                Message(ResponseErr, Handler, JToken.AsValue().AsText());
            end;
        end
    end;

    [TryFunction]
    local procedure TrySendGenericRequest(Handler: Text; Request: JsonObject; Caption: Text; var ResponseOut: JsonObject)
    begin
        ResponseOut := SendRequestOutsidePOS(Handler, Request, Caption);
    end;

    local procedure SendRequestOutsidePOS(Handler: Text; Request: JsonObject; Caption: Text): JsonObject
    var
        HardwareConnector: Page "NPR Hardware Connector";
        Response: JsonObject;
        DidAutoClose: Boolean;
        ErrorMessage: Text;
        ExceptionCaught: Boolean;
        ClosedPageErr: Label 'The hardware connector page does not work if you manually close it. Please try again and keep it open.';
        SocketErr: Label 'Connection failure with hardware connector on the local machine.\Please verify that it is running and try again.\Error Message:\\%1';
    begin
        HardwareConnector.SetInput(Caption, Handler, Request);
        HardwareConnector.RunModal();
        HardwareConnector.GetOutput(ErrorMessage, ExceptionCaught, Response, DidAutoClose);

        if not DidAutoClose then begin
            Error(ClosedPageErr);
        end;

        if ExceptionCaught then begin
            Error(SocketErr, ErrorMessage);
        end;

        exit(Response);
    end;

}
