codeunit 6014680 "NPR Endpoint Query WebService"
{
    // NPR5.25\BR \20160802 CASE 234602 Object Created


    trigger OnRun()
    begin
    end;

    var
        SETUP_MISSING: Label 'Setup is missing for %1';

    procedure Createendpointquery(var EndpointQueryWebImport: XMLport "NPR Endpoint Query Web Import")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
    begin
        SelectLatestVersion;
        EndpointQueryWebImport.Import();

        InsertImportEntry('Createendpointquery', ImportEntry);
        ImportEntry."Document ID" := EndpointQueryWebImport.GetMessageID();
        if (ImportEntry."Document ID" = '') then
            ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));

        ImportEntry."Document Name" := StrSubstNo('EndpointQuery-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Sequence No." := GetDocumentSequence(ImportEntry."Document ID");

        ImportEntry."Document Source".CreateOutStream(OutStr);
        EndpointQueryWebImport.SetDestination(OutStr);
        EndpointQueryWebImport.Export();
        Commit();

        ImportEntry.Modify(true);

        Commit();

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);

        ImportEntry.Get(ImportEntry."Entry No.");

        if (not ImportEntry.Imported) then
            EndpointQueryWebImport.SetEndpointQueryResult(StrSubstNo('FAILED with error %1', ImportEntry."Error Message"))
        else
            EndpointQueryWebImport.SetEndpointQueryResult('SUCCESS');

        Commit();
    end;

    local procedure "--"()
    begin
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    begin

        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR Endpoint Query WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            EndpointIntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR Endpoint Query WebService", WebserviceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo('%1-%2.xml', ImportEntry."Import Type", Format(ImportEntry.Date, 0, 9));
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

    local procedure InitSetup(): Text
    begin
    end;

    local procedure EndpointIntegrationSetup()
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        ImportType.SetFilter("Webservice Codeunit ID", '=%1', CODEUNIT::"NPR Endpoint Query WebService");
        if (not ImportType.IsEmpty()) then
            ImportType.DeleteAll();

        CreateImportType('ENDPQ-01', 'Endpoint Query', 'Createendpointquery');
    end;

    local procedure CreateImportType("Code": Code[20]; Description: Text[30]; FunctionName: Text[30])
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"NPR Endpoint Query WS Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"NPR Endpoint Query WebService";

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

