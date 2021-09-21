codeunit 6060048 "NPR Item Wksht. WebService"
{
    var
        SetupMissingErr: Label 'Setup is missing for %1', Comment = '%1 = Web service Function';

    procedure CreateItemWorksheetLine(var itemworksheetlines: XMLport "NPR Item Worksh. Line Web Imp.")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        DocumentNameLbl: Label 'ItemWorksheetLine-%1.xml', Locked = true;
        FailedLbl: Label 'FAILED with error %1', Locked = true;
    begin
        SelectLatestVersion();
        itemworksheetlines.Import();

        InsertImportEntry('CreateItemWorksheetLine', ImportEntry);
        ImportEntry."Document ID" := itemworksheetlines.GetMessageID();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := CopyStr(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')), 1, MaxStrLen(ImportEntry."Document ID"));

        ImportEntry."Document Name" := StrSubstNo(DocumentNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");
        ImportEntry."Document Source".CreateOutStream(OutStr);
        itemworksheetlines.SetDestination(OutStr);
        itemworksheetlines.Export();
        Commit();

        ImportEntry.Modify(true);

        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");

        if (not ImportEntry.Imported) then
            itemworksheetlines.SetItemWorksheetLineResult(StrSubstNo(FailedLbl, ImportEntry."Error Message"))
        else
            itemworksheetlines.SetItemWorksheetLineResult('SUCCESS');

        Commit();
    end;


    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        FileNameLbl: Label '%1-%2.xml', Locked = true;
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR Item Wksht. WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            TicketIntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR Item Wksht. WebService", WebserviceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(SetupMissingErr, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Import Type", Format(ImportEntry.Date, 0, 9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure GetDocumentSequence(DocumentID: Text[100]): Integer
    var
        ImportEntry: Record "NPR Nc Import Entry";
    begin
        if (DocumentID = '') then
            exit(1);

        ImportEntry.SetCurrentKey("Document ID");
        ImportEntry.SetFilter("Document ID", '=%1', DocumentID);
        if (not ImportEntry.FindLast()) then
            exit(1);

        exit(ImportEntry."Sequence No." + 1);
    end;


    local procedure TicketIntegrationSetup()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetFilter("Webservice Codeunit ID", '=%1', CODEUNIT::"NPR Item Wksht. WebService");
        if (not ImportType.IsEmpty()) then
            ImportType.DeleteAll();

        CreateImportType('ITEMWS-01', 'Item Worksheet Line', 'CreateItemWorksheetLine');
    end;

    local procedure CreateImportType("Code": Code[20]; Description: Text[30]; FunctionName: Text[30])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;
        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"NPR Item Wksht. WebService Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Item Wksht. WebService";
        ImportType.Insert();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[20]
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", CopyStr(WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));
        if ImportType.FindFirst() then
            exit(ImportType.Code);

        exit('');
    end;
}

