codeunit 6151199 "NpCs Collect Webservice"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.53/MHA /20191129  CASE 378216 Added functions UpdateProcessingStatus(), FindNpCsDocument(), TestProcessingStatusChange()


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Import Collect in Store Sales Document';
        Text001: Label 'Collect %1 %2 not found';
        Text002: Label 'It is not allowed to change Processing Status from %1 to %2 on Collect %3 %4';

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
        //-NPR5.53 [378216]
        collect_documents.RefreshSourceTable();
        //+NPR5.53 [378216]
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
        //-NPR5.53 [378216]
        collect_documents.RefreshSourceTable();
        //+NPR5.53 [378216]
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

    [Scope('Personalization')]
    procedure UpdateProcessingStatus(var collect_documents: XMLport "NpCs Collect Documents")
    var
        NpCsDocument: Record "NpCs Document";
        TempNpCsDocument: Record "NpCs Document" temporary;
        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
    begin
        //-NPR5.53 [378216]
        collect_documents.Import;
        collect_documents.GetSourceTable(TempNpCsDocument);
        if not TempNpCsDocument.FindSet then
            exit;

        repeat
          if not FindNpCsDocument(TempNpCsDocument,NpCsDocument) then
            Error(Text001,TempNpCsDocument."From Document Type",TempNpCsDocument."From Document No.");

          TestProcessingStatusChange(NpCsDocument,TempNpCsDocument);
        until TempNpCsDocument.Next = 0;

        TempNpCsDocument.FindSet;
        repeat
          FindNpCsDocument(TempNpCsDocument,NpCsDocument);
          case TempNpCsDocument."Processing Status" of
            TempNpCsDocument."Processing Status"::Pending:
              begin
                NpCsCollectMgt.UpdateProcessingStatus(NpCsDocument,TempNpCsDocument."Processing Status");
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
                NpCsCollectMgt.ExpireProcessing(NpCsDocument,false);
              end;
          end;
        until TempNpCsDocument.Next = 0;

        collect_documents.RefreshSourceTable();
        //+NPR5.53 [378216]
    end;

    local procedure "--- Aux"()
    begin
    end;

    [TryFunction]
    local procedure FindNpCsDocument(TempNpCsDocument: Record "NpCs Document" temporary;var NpCsDocument: Record "NpCs Document")
    begin
        //-NPR5.53 [378216]
        NpCsDocument.SetRange(Type,TempNpCsDocument.Type);
        case TempNpCsDocument.Type of
          TempNpCsDocument.Type::"Send to Store":
            begin
              NpCsDocument.SetRange("Document Type",TempNpCsDocument."From Document Type");
              NpCsDocument.SetRange("Document No.",TempNpCsDocument."From Document No.");
            end;
          TempNpCsDocument.Type::"Collect in Store":
            begin
              NpCsDocument.SetRange("From Document Type",TempNpCsDocument."From Document Type");
              NpCsDocument.SetRange("From Document No.",TempNpCsDocument."From Document No.");
            end;
        end;
        NpCsDocument.SetRange("From Store Code",TempNpCsDocument."From Store Code");
        NpCsDocument.FindFirst;
        //+NPR5.53 [378216]
    end;

    local procedure TestProcessingStatusChange(NpCsDocumentFrom: Record "NpCs Document";NpCsDocumentTo: Record "NpCs Document")
    begin
        //-NPR5.53 [378216]
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
              if NpCsDocumentFrom."Processing Status" in [NpCsDocumentFrom."Processing Status"::" ",NpCsDocumentFrom."Processing Status"::Pending] then
                exit;
            end;
          NpCsDocumentTo."Processing Status"::Confirmed:
            begin
              if NpCsDocumentFrom."Processing Status" in [NpCsDocumentFrom."Processing Status"::" ",NpCsDocumentFrom."Processing Status"::Pending] then
                exit;
            end;
          NpCsDocumentTo."Processing Status"::Rejected:
            begin
              if NpCsDocumentFrom."Processing Status" in [NpCsDocumentFrom."Processing Status"::" ",NpCsDocumentFrom."Processing Status"::Pending] then
                exit;
            end;
          NpCsDocumentTo."Processing Status"::Expired:
            begin
              if NpCsDocumentFrom."Processing Status" in
                [NpCsDocumentFrom."Processing Status"::" ",NpCsDocumentFrom."Processing Status"::Pending,NpCsDocumentFrom."Processing Status"::Confirmed]
              then
                exit;
            end;
        end;

        Error(Text002,NpCsDocumentFrom."Processing Status",NpCsDocumentTo."Processing Status",
          NpCsDocumentTo."From Document Type",NpCsDocumentTo."From Document No.");
        //+NPR5.53 [378216]
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

