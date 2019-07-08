codeunit 6151199 "NpCs Collect Webservice"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Import Collect in Store Sales Document';

    [Scope('Personalization')]
    procedure ImportSalesDocuments(var sales_documents: XMLport "NpCs Sales Document")
    var
        ImportEntry: Record "Nc Import Entry";
        TempSalesHeader: Record "Sales Header" temporary;
        NcImportMgt: Codeunit "Nc Import Mgt.";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        NulChr: Char;
        ErrorMessage: Text;
    begin
        sales_documents.Import;
        sales_documents.CopySourceTable(TempSalesHeader);
        if not TempSalesHeader.FindFirst then
          exit;

        InsertImportEntry('ImportSalesDocuments',ImportEntry);
        ImportEntry."Document Name" := Format(TempSalesHeader."Document Type") + ' ' + TempSalesHeader."No." + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_documents.SetDestination(OutStr);
        sales_documents.Export;
        ImportEntry.Modify(true);
        Commit;

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
        Commit;
        if ImportEntry."Runtime Error" then begin
          ErrorMessage := NcImportMgt.GetErrorMessage(ImportEntry,false);
          ErrorMessage := DelChr(ErrorMessage,'=',Format(NulChr));
          Error(ErrorMessage);
        end;
    end;

    [Scope('Personalization')]
    procedure GetCollectDocuments(var collect_documents: XMLport "NpCs Collect Documents")
    begin
        collect_documents.Import;
    end;

    [Scope('Personalization')]
    procedure GetCollectStores(var stores: XMLport "NpCs Collect Store")
    begin
        stores.Import;
    end;

    [Scope('Personalization')]
    procedure RunNextWorkflowStep(var collect_documents: XMLport "NpCs Collect Documents")
    var
        NpCsDocument: Record "NpCs Document";
        TempNpCsDocument: Record "NpCs Document" temporary;
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
    begin
        collect_documents.Import;
        collect_documents.GetSourceTable(TempNpCsDocument);
        if TempNpCsDocument.FindSet then
          repeat
            NpCsDocument.SetRange(Type,TempNpCsDocument.Type);
            NpCsDocument.SetRange("Document Type",TempNpCsDocument."Document Type");
            NpCsDocument.SetRange("Document No.",TempNpCsDocument."Document No.");
            NpCsDocument.SetRange("From Store Code",TempNpCsDocument."From Store Code");
            NpCsDocument.SetRange("Reference No.",TempNpCsDocument."Reference No.");
            NpCsDocument.FindFirst;
            NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
          until TempNpCsDocument.Next = 0;
    end;

    [Scope('Personalization')]
    procedure GetLocalInventory(var local_inventory: XMLport "NpCs Local Inventory")
    begin
        local_inventory.Import;
    end;

    [Scope('Personalization')]
    procedure GetStoreInventory(var store_inventory: XMLport "NpCs Store Inventory")
    begin
        store_inventory.Import;
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure InitSalesDocImportType(var NcImportType: Record "Nc Import Type")
    var
        SalesDocCodeunitId: Integer;
        "Code": Code[20];
    begin
        SalesDocCodeunitId := CODEUNIT::"NpCs Import Sales Document";

        Clear(NcImportType);
        NcImportType.SetRange("Import Codeunit ID",SalesDocCodeunitId);
        if NcImportType.FindFirst then
          exit;

        if not NcImportType.WritePermission then
          NcImportType.FindFirst;

        Code := 'COLLECT_SALES_DOC';
        if NcImportType.Get(Code) then begin
          Code := 'COLLECT_SALES_DOC_1';
          while NcImportType.Get(Code) do
            Code := IncStr(Code);
        end;

        NcImportType.Init;
        NcImportType.Code := Code;
        NcImportType.Description := CopyStr(Text000,1,MaxStrLen(NcImportType.Description));
        NcImportType."Import Codeunit ID" := SalesDocCodeunitId;
        NcImportType."Lookup Codeunit ID" := CODEUNIT::"NpCs Lookup Sales Document";
        NcImportType."Webservice Enabled" := true;
        NcImportType."Webservice Codeunit ID" := CurrCodeunitId();
        NcImportType.Insert(true);
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text;var ImportEntry: Record "Nc Import Entry")
    var
        NcImportType: Record "Nc Import Type";
    begin
        InitSalesDocImportType(NcImportType);

        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := NcImportType.Code;
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := ImportEntry."Import Type" + '-' + Format(ImportEntry.Date,0,9) + '.xml';
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Insert(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpCs Collect Webservice");
    end;
}

