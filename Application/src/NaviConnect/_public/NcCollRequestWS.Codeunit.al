﻿codeunit 6151532 "NPR Nc Coll.  Request WS"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.';
    ObsoleteTag = 'BC 20 - Task Queue deprecating starting from 28/06/2022';

    var
        ImportTypeMissingErr: Label 'Setup is missing for %1. Unknown value for %2 in %3', Comment = '%1="NPR Nc Import Entry"."Webservice Function";%2="NPR Nc Import Entry".TableCaption();%3="NPR Nc Import Entry".FieldCaption"Import Type"';

    [Obsolete('Task Queue module is about to be removed from NpCore so NC Collector is also going to be removed.', 'BC 20 - Task Queue deprecating starting from 28/06/2022')]
    procedure Createcollectorrequest(var CollectorRequestWebImport: XMLport "NPR Collector Req. Web Imp.")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'CollectorRequest-%1.xml', Locked = true;
        FailedLbl: Label 'FAILED with error %1';
    begin
        SelectLatestVersion();
        CollectorRequestWebImport.Import();

        InsertImportEntry('Createcollectorrequest', ImportEntry);
        ImportEntry."Document ID" := CollectorRequestWebImport.GetMessageID();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        CollectorRequestWebImport.SetDestination(OutStr);
        CollectorRequestWebImport.Export();
        Commit();

        ImportEntry.Modify(true);

        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");

        if (not ImportEntry.Imported) then
            CollectorRequestWebImport.SetCollectorRequestResult(StrSubstNo(FailedLbl, ImportEntry."Error Message"))
        else
            CollectorRequestWebImport.SetCollectorRequestResult('SUCCESS');

        Commit();
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        FileNameLbl: Label '%1-%2.xml', Locked = true;
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR Nc Coll.  Request WS", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            CollectorIntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR Nc Coll.  Request WS", WebserviceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(ImportTypeMissingErr, WebserviceFunction, ImportEntry.TableCaption(), ImportEntry.FieldCaption("Import Type"));
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

    local procedure CollectorIntegrationSetup()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetFilter("Webservice Codeunit ID", '=%1', CODEUNIT::"NPR Nc Coll.  Request WS");
        if (not ImportType.IsEmpty()) then
            ImportType.DeleteAll();

        CreateImportType('NCCR-01', 'Collector Request', 'Createcollectorrequest');
    end;

    local procedure CreateImportType("Code": Code[20]; Description: Text[30]; FunctionName: Text[30])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"NPR Nc Coll. Req. WS Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Nc Coll.  Request WS";

        ImportType.Insert();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[20]
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', CopyStr(WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));

        if ImportType.FindFirst() then
            exit(ImportType.Code);

        exit('');
    end;
}

