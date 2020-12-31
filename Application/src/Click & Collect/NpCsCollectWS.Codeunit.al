codeunit 6151199 "NPR NpCs Collect WS"
{
    var
        Text000: Label 'Import Collect in Store Sales Document';
        Text001: Label 'Collect %1 %2 not found';
        Text002: Label 'It is not allowed to change Processing Status from %1 to %2 on Collect %3 %4';

    procedure ImportSalesDocuments(var sales_documents: XMLport "NPR NpCs Sales Document")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        TempSalesHeader: Record "Sales Header" temporary;
        NcImportMgt: Codeunit "NPR Nc Import Mgt.";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        NulChr: Char;
        ErrorMessage: Text;
    begin
        sales_documents.Import;
        sales_documents.CopySourceTable(TempSalesHeader);
        if not TempSalesHeader.FindFirst then
            exit;

        InsertImportEntry('ImportSalesDocuments', ImportEntry);
        ImportEntry."Document Name" := Format(TempSalesHeader."Document Type") + ' ' + TempSalesHeader."No." + '.xml';
        ImportEntry."Document Source".CreateOutStream(OutStr);
        sales_documents.SetDestination(OutStr);
        sales_documents.Export;
        ImportEntry.Modify(true);
        Commit;

        NaviConnectSyncMgt.ProcessImportEntry(ImportEntry);
        Commit;
        if ImportEntry."Runtime Error" then begin
            ErrorMessage := NcImportMgt.GetErrorMessage(ImportEntry, false);
            ErrorMessage := DelChr(ErrorMessage, '=', Format(NulChr));
            Error(ErrorMessage);
        end;
    end;

    procedure GetCollectDocuments(var collect_documents: XMLport "NPR NpCs Collect Documents")
    begin
        collect_documents.Import;
        collect_documents.RefreshSourceTable();
    end;

    procedure GetCollectStores(var stores: XMLport "NPR NpCs Collect Store")
    begin
        stores.Import;
    end;

    procedure RunNextWorkflowStep(var collect_documents: XMLport "NPR NpCs Collect Documents")
    var
        NpCsDocument: Record "NPR NpCs Document";
        TempNpCsDocument: Record "NPR NpCs Document" temporary;
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        collect_documents.Import;
        collect_documents.RefreshSourceTable();
        collect_documents.GetSourceTable(TempNpCsDocument);
        if TempNpCsDocument.FindSet then
            repeat
                NpCsDocument.SetRange(Type, TempNpCsDocument.Type);
                NpCsDocument.SetRange("Document Type", TempNpCsDocument."Document Type");
                NpCsDocument.SetRange("Document No.", TempNpCsDocument."Document No.");
                NpCsDocument.SetRange("From Store Code", TempNpCsDocument."From Store Code");
                NpCsDocument.SetRange("Reference No.", TempNpCsDocument."Reference No.");
                NpCsDocument.FindFirst;
                NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
            until TempNpCsDocument.Next = 0;
    end;

    procedure GetLocalInventory(var local_inventory: XMLport "NPR NpCs Local Inventory")
    begin
        local_inventory.Import;
    end;

    procedure GetStoreInventory(var store_inventory: XMLport "NPR NpCs Store Inv.")
    begin
        store_inventory.Import;
    end;

    procedure UpdateProcessingStatus(var collect_documents: XMLport "NPR NpCs Collect Documents")
    var
        NpCsDocument: Record "NPR NpCs Document";
        TempNpCsDocument: Record "NPR NpCs Document" temporary;
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
    begin
        collect_documents.Import;
        collect_documents.GetSourceTable(TempNpCsDocument);
        if not TempNpCsDocument.FindSet then
            exit;

        repeat
            if not FindNpCsDocument(TempNpCsDocument, NpCsDocument) then
                Error(Text001, TempNpCsDocument."From Document Type", TempNpCsDocument."From Document No.");

            TestProcessingStatusChange(NpCsDocument, TempNpCsDocument);
        until TempNpCsDocument.Next = 0;

        TempNpCsDocument.FindSet;
        repeat
            FindNpCsDocument(TempNpCsDocument, NpCsDocument);
            case TempNpCsDocument."Processing Status" of
                TempNpCsDocument."Processing Status"::Pending:
                    begin
                        NpCsCollectMgt.UpdateProcessingStatus(NpCsDocument, TempNpCsDocument."Processing Status");
                    end;
                TempNpCsDocument."Processing Status"::Confirmed:
                    begin
                        NpCsCollectMgt.ConfirmProcessing(NpCsDocument);
                    end;
                TempNpCsDocument."Processing Status"::Rejected:
                    begin
                        NpCsCollectMgt.RejectProcessing(NpCsDocument);
                    end;
                TempNpCsDocument."Processing Status"::Expired:
                    begin
                        NpCsCollectMgt.ExpireProcessing(NpCsDocument, false);
                    end;
            end;
        until TempNpCsDocument.Next = 0;

        collect_documents.RefreshSourceTable();
    end;

    local procedure "--- Aux"()
    begin
    end;

    [TryFunction]
    local procedure FindNpCsDocument(TempNpCsDocument: Record "NPR NpCs Document" temporary; var NpCsDocument: Record "NPR NpCs Document")
    begin
        NpCsDocument.SetRange(Type, TempNpCsDocument.Type);
        case TempNpCsDocument.Type of
            TempNpCsDocument.Type::"Send to Store":
                begin
                    NpCsDocument.SetRange("Document Type", TempNpCsDocument."From Document Type");
                    NpCsDocument.SetRange("Document No.", TempNpCsDocument."From Document No.");
                end;
            TempNpCsDocument.Type::"Collect in Store":
                begin
                    NpCsDocument.SetRange("From Document Type", TempNpCsDocument."From Document Type");
                    NpCsDocument.SetRange("From Document No.", TempNpCsDocument."From Document No.");
                end;
        end;
        NpCsDocument.SetRange("From Store Code", TempNpCsDocument."From Store Code");
        NpCsDocument.FindFirst;
    end;

    local procedure TestProcessingStatusChange(NpCsDocumentFrom: Record "NPR NpCs Document"; NpCsDocumentTo: Record "NPR NpCs Document")
    begin
        if NpCsDocumentFrom."Processing Status" = NpCsDocumentTo."Processing Status" then
            exit;

        case NpCsDocumentTo."Processing Status" of
            NpCsDocumentTo."Processing Status"::" ":
                begin
                    if NpCsDocumentFrom."Processing Status" = NpCsDocumentFrom."Processing Status"::" " then
                        exit;
                end;
            NpCsDocumentTo."Processing Status"::Pending:
                begin
                    if NpCsDocumentFrom."Processing Status" in [NpCsDocumentFrom."Processing Status"::" ", NpCsDocumentFrom."Processing Status"::Pending] then
                        exit;
                end;
            NpCsDocumentTo."Processing Status"::Confirmed:
                begin
                    if NpCsDocumentFrom."Processing Status" in [NpCsDocumentFrom."Processing Status"::" ", NpCsDocumentFrom."Processing Status"::Pending] then
                        exit;
                end;
            NpCsDocumentTo."Processing Status"::Rejected:
                begin
                    if NpCsDocumentFrom."Processing Status" in [NpCsDocumentFrom."Processing Status"::" ", NpCsDocumentFrom."Processing Status"::Pending] then
                        exit;
                end;
            NpCsDocumentTo."Processing Status"::Expired:
                begin
                    if NpCsDocumentFrom."Processing Status" in
                      [NpCsDocumentFrom."Processing Status"::" ", NpCsDocumentFrom."Processing Status"::Pending, NpCsDocumentFrom."Processing Status"::Confirmed]
                    then
                        exit;
                end;
        end;

        Error(Text002, NpCsDocumentFrom."Processing Status", NpCsDocumentTo."Processing Status",
          NpCsDocumentTo."From Document Type", NpCsDocumentTo."From Document No.");
    end;

    local procedure InitSalesDocImportType(var NcImportType: Record "NPR Nc Import Type")
    var
        SalesDocCodeunitId: Integer;
        "Code": Code[20];
    begin
        SalesDocCodeunitId := CODEUNIT::"NPR NpCs Imp. Sales Doc.";

        Clear(NcImportType);
        NcImportType.SetRange("Import Codeunit ID", SalesDocCodeunitId);
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
        NcImportType.Description := CopyStr(Text000, 1, MaxStrLen(NcImportType.Description));
        NcImportType."Import Codeunit ID" := SalesDocCodeunitId;
        NcImportType."Lookup Codeunit ID" := CODEUNIT::"NPR NpCs Lookup Sales Document";
        NcImportType."Webservice Enabled" := true;
        NcImportType."Webservice Codeunit ID" := CurrCodeunitId();
        NcImportType.Insert(true);
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        NcImportType: Record "NPR Nc Import Type";
    begin
        InitSalesDocImportType(NcImportType);

        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := NcImportType.Code;
        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := ImportEntry."Import Type" + '-' + Format(ImportEntry.Date, 0, 9) + '.xml';
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Insert(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Collect WS");
    end;
}

