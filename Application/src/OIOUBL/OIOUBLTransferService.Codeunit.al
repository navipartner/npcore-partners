codeunit 6060015 "NPR OIOUBL Transfer Service"
{
    Access = Internal;
    TableNo = "Record Export Buffer";

    trigger OnRun()
    var
        OIOUBLManagement: Codeunit "NPR OIOUBL Document Management";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        FileUpdateLbl: Label 'OIOUBL filecontent update';
        FileCreatedLbl: Label 'OIOUBL file %1 created.';
        FileUploadLbl: Label 'OIOUBL file uploaded to NaviPartner';
        FileDownloadLbl: Label 'OIOUBL file downloaded in browser';
    begin
        RecRef.Get(Rec.RecordID);
        if RecRef.Number in [Database::"Sales Invoice Header", Database::"Sales Cr.Memo Header", Database::"Service Invoice Header", Database::"Service Cr.Memo Header"] then
            Rec.ClientFileName := OIOUBLManagement.GetDefaultFilename(RecRef);
#IF BC17 or BC18 or BC19
        GetContentFromFile(Rec, TempBlob);
#ELSE
        Rec.GetFileContent(TempBlob);
#ENDIF
        if not OIOUBLManagement.UpdateOIOUBLContent(TempBlob, RecRef) then
            AddToActivityLog(Rec, 1, FileUpdateLbl, GetLastErrorText());

        if IsNPTransferAllowed() then begin
            if UploadAzureFileStorage(TempBlob, Rec.ClientFileName) then
                AddToActivityLog(Rec, 0, FileCreatedLbl, FileUploadLbl)
            else
                AddToActivityLog(Rec, 1, FileCreatedLbl, GetLastErrorText());
        end else begin
            FileManagement.BLOBExport(TempBlob, Rec.ClientFileName, true);
            AddToActivityLog(Rec, 0, FileCreatedLbl, FileDownloadLbl);
        end;
    end;

    local procedure AddToActivityLog(RecordExportBuffer: Record "Record Export Buffer"; Status: Option Success,Failed; Activity: Text; Comment: Text)
    var
        ActivityLog: Record "Activity Log";
        ActivityContentText: Label 'OIOUBL', Locked = true;
    begin
        Activity := StrSubstNo(Activity, RecordExportBuffer.ClientFileName);
        ActivityLog.LogActivity(RecordExportBuffer.RecordID, Status, ActivityContentText, Activity, Comment);
        if Status = Status::Failed then begin
            Commit();
            Error(Comment);
        end
    end;

#IF BC17 or BC18 or BC19
    local procedure GetContentFromFile(RecordExportBuffer: Record "Record Export Buffer"; var TempBlob: Codeunit "Temp Blob")
    var
        OStream: OutStream;
        IStream: InStream;
        FileHandle: File;
    begin
        TempBlob.CreateOutStream(OStream);
        FileHandle.Open(RecordExportBuffer.ServerFilePath);
        FileHandle.CreateInStream(IStream);
        CopyStream(OStream, IStream);
    end;
#ENDIF

    local procedure IsNPTransferAllowed(): Boolean
    var
        OIOUBLSetup: Record "NPR OIOUBL Setup";
        NPREnvironmentInformation: Record "NPR Environment Information";
        Company: Record Company;
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        OIOUBLSetup.SetRange(Enabled, true);
        if OIOUBLSetup.IsEmpty then
            exit(false);

        if NPREnvironmentInformation.Get() then
            exit(NPREnvironmentInformation."Environment Type" = "NPR Environment Type"::PROD);

        if not EnvironmentInformation.IsSaaS() then
            exit(true);

        if not EnvironmentInformation.IsProduction() then
            exit(false);

        if CompanyName().ToUpper().Contains('CRONUS') then
            exit(false);

        if Company.Get(CompanyName()) then
            if Company."Evaluation Company" then
                exit(false);

        exit(true);

    end;

    [TryFunction]
    local procedure UploadAzureFileStorage(var TempBlob: Codeunit "Temp Blob"; FileName: Text)
    var
        Content: HttpContent;
        ContentLength: Integer;
    begin
        ContentLength := GetContent(TempBlob, Content);
        CreateAzureFile(FileName, ContentLength);
        UploadAzureFile(FileName, Content, ContentLength);
    end;

    local procedure GetContent(var TempBlob: Codeunit "Temp Blob"; var Content: HttpContent) ContentLength: Integer
    var
        Headers: HttpHeaders;
        InStr: InStream;
        FileContent: Text;
        Values: array[10] of Text;

    begin
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        Content.WriteFrom(InStr);
        Content.ReadAs(FileContent);
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Length') then
            if Headers.GetValues('Content-Length', Values) then
                Evaluate(ContentLength, Values[1]);
        if ContentLength = 0 then
            ContentLength := StrLen(FileContent);
        exit(ContentLength);
    end;

    local procedure GetBaseUrl(): Text
    begin
        exit('https://npedi.file.core.windows.net/edi/');
    end;


    [NonDebuggable]
    local procedure CreateAzureFile(Filename: Text; ContentLength: Integer)
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        URL: Text;
        ErrorResponse: Text;
        ErrorMessageLbl: Label 'Create file in Azure File Storage failed\Error Code: %1\Error Message: %2', Comment = '%1 - errorcode, %2 - errormessage';
    begin
        Content.GetHeaders(Headers);
        Headers.Add('x-ms-type', 'file');
        Headers.Add('x-ms-content-length', Format(ContentLength));
        URL := GetBaseUrl() + Filename + '?' + GetSASToken();

        Client.Put(URL, Content, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(ErrorResponse);
            ErrorResponse := StrSubstNo(ErrorMessageLbl, ResponseMessage.HttpStatusCode, ErrorResponse);
            Error(ErrorResponse);
        end;
    end;

    [NonDebuggable]
    local procedure UploadAzureFile(Filename: Text; Content: HttpContent; ContentLength: Integer)
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        URL: Text;
        ErrorResponse: Text;
        XMSRangeLbl: Label 'bytes=0-%1', Locked = true;
        ErrorMessageLbl: Label 'Upload to Azure File Storage failed\Error Code: %1\Error Message: %2', Comment = '%1 - errorcode, %2 - errormessage';
    begin
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        if Headers.Contains('Content-Length') then
            Headers.Remove('Content-Length');
        Headers.Add('Content-Length', Format(ContentLength, 0, 9));
        Headers.Add('x-ms-write', 'update');
        Headers.Add('x-ms-range', StrSubstNo(XMSRangeLbl, ContentLength - 1));
        URL := GetBaseUrl() + Filename + '?comp=range&' + GetSASToken();

        Client.Put(URL, Content, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(ErrorResponse);
            ErrorResponse := StrSubstNo(ErrorMessageLbl, ResponseMessage.HttpStatusCode, ErrorResponse);
            Error(ErrorResponse);
        end;
    end;

    local procedure GetSASToken(): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        SASTokenLbl: Label 'NpOIOUBLSASToken', Locked = true;
    begin
        exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret(SASTokenLbl));
    end;


#IF BC17 or BC18 or BC19 or BC20
    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnCheckElectronicSendingEnabled', '', false, false)]
    local procedure OnCheckElectronicSendingEnabled(var ExchServiceEnabled: Boolean)
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        if ExchServiceEnabled then
            exit;
        ElectronicDocumentFormat.SetRange("Delivery Codeunit ID", Codeunit::"NPR OIOUBL Transfer Service");
        ExchServiceEnabled := not ElectronicDocumentFormat.IsEmpty;
    end;
#ELSE
    [EventSubscriber(ObjectType::Table, Database::"Document Sending Profile", 'OnCheckElectronicSendingEnabled', '', false, false)]
    local procedure OnCheckElectronicSendingEnabled(var ExchServiceEnabled: Boolean; sender: Record "Document Sending Profile")
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
    begin
        if ExchServiceEnabled then
            exit;
        if sender."Electronic Document" <> "Doc. Sending Profile Elec.Doc."::"Through Document Exchange Service" then
            exit;
        ElectronicDocumentFormat.SetRange(Code, sender."Electronic Format");
        ElectronicDocumentFormat.SetRange("Delivery Codeunit ID", Codeunit::"NPR OIOUBL Transfer Service");
        ExchServiceEnabled := not ElectronicDocumentFormat.IsEmpty;
    end;
#ENDIF

}
