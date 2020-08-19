codeunit 6060048 "Item Wksht. WebService"
{
    // NPR5.22/BR/20160324  CASE 182391 Object Created
    // NPR5.23/BR/20160530  CASE 237658 Continued development on prototype, not documented in the code.
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento reference updated according to NC2.00


    trigger OnRun()
    begin
    end;

    var
        TicketIdentifierType: Option INTERNAL_TICKET_NO,EXTERNAL_TICKET_NO,PRINTED_TICKET_NO;
        SETUP_MISSING: Label 'Setup is missing for %1';
        FileMan: Codeunit "File Management";

        procedure CreateItemWorksheetLine(var ItemWorksheetLineImport: XMLport "Item Worksheet Line Web Import")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MasterDataSourceId: Code[10];
    begin
        SelectLatestVersion;
        ItemWorksheetLineImport.Import;

        InsertImportEntry ('CreateItemWorksheetLine',ImportEntry);
        ImportEntry."Document ID" := ItemWorksheetLineImport.GetMessageID();
        if (ImportEntry."Document ID" = '') then
          ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        //ImportEntry."Document Name" := STRSUBSTNO ('ItemWorksheetLine-%1-%2.xml', ImportEntry."Document ID", ItemWorksheetLineImport.GetSummary());
        ImportEntry."Document Name" := StrSubstNo ('ItemWorksheetLine-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Sequence No." := GetDocumentSequence (ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ItemWorksheetLineImport.SetDestination(OutStr);
        ItemWorksheetLineImport.Export;
        Commit ();

        ImportEntry.Modify(true);

        Commit ();

        //IF (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) THEN BEGIN
        NaviConnectSyncMgt.ProcessImportEntry (ImportEntry);

        ImportEntry.Get (ImportEntry."Entry No.");

        if (not ImportEntry.Imported) then
          //ERROR (ImportEntry."Error Message");
          ItemWorksheetLineImport.SetItemWorksheetLineResult ( StrSubstNo('FAILED with error %1',ImportEntry."Error Message") )
        else
          ItemWorksheetLineImport.SetItemWorksheetLineResult ( 'SUCCESS');

        Commit ();
    end;

    local procedure "--"()
    begin
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text;var ImportEntry: Record "Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "Nc Setup Mgt.";
    begin

        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"Item Wksht. WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
          TicketIntegrationSetup ();
          ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"Item Wksht. WebService", WebserviceFunction);
          if (ImportEntry."Import Type" = '') then
            Error (SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo('%1-%2.xml', ImportEntry."Import Type", Format(ImportEntry.Date,0,9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure GetDocumentSequence(DocumentID: Text[100]) SequenceNo: Integer
    var
        ImportEntry: Record "Nc Import Entry";
    begin

        if (DocumentID = '') then
          exit (1);

        ImportEntry.SetCurrentKey ("Document ID");
        ImportEntry.SetFilter ("Document ID", '=%1', DocumentID);
        if (not ImportEntry.FindLast ()) then
          exit (1);

        exit (ImportEntry."Sequence No."+1);
    end;

    local procedure InitSetup(): Text
    begin
    end;

    local procedure TicketIntegrationSetup()
    var
        ImportType: Record "Nc Import Type";
    begin

        ImportType.SetFilter ("Webservice Codeunit ID", '=%1', CODEUNIT::"Item Wksht. WebService");
        if (not ImportType.IsEmpty ()) then
          ImportType.DeleteAll ();

        CreateImportType ('ITEMWS-01', 'Item Worksheet Line', 'CreateItemWorksheetLine');
    end;

    local procedure CreateImportType("Code": Code[20];Description: Text[30];FunctionName: Text[30])
    var
        ImportType: Record "Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" :=  CODEUNIT::"Item Wksht. WebService Mgr";
        ImportType."Webservice Codeunit ID" :=  CODEUNIT::"Item Wksht. WebService";

        ImportType.Insert ();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer;WebserviceFunction: Text): Code[10]
    var
        ImportType: Record "Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID",WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function",'%1',CopyStr(WebserviceFunction,1,MaxStrLen(ImportType."Webservice Function")));

        if ImportType.FindFirst then
          exit(ImportType.Code);

        exit('');
    end;
}

