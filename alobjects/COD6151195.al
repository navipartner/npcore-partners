codeunit 6151195 "NpCs Collect Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190627  CASE 344264 Moved Archivation functionality to separate codeunit and added Expiration to Status Update
    // NPR5.51/MHA /20190819  CASE 364557 It should be possible to create collect order from one local store to another local store and added posting functions
    // NPR5.53/MHA /20191129  CASE 378216 Archivation moved to asynchronous workflow procedure


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Processing Status updated to %1';
        Text002: Label 'Delivery Status updated to %1';
        Text004: Label 'Sales %1 %2 posted';
        Text005: Label 'Delivery printed: %1';
        Text006: Label 'Sales %1 %2 must be posted when %3 = %4';
        Text007: Label 'Sales %1 %2 posted to %3 %4';

    local procedure "--- Init"()
    begin
    end;

    procedure InitCollectInStoreService()
    var
        WebService: Record "Web Service";
        PrevRec: Text;
    begin
        if not WebService.ReadPermission then
          exit;

        if not WebService.WritePermission then
          exit;

        if not WebService.Get(WebService."Object Type"::Codeunit,'collect_in_store_service') then begin
          WebService.Init;
          WebService."Object Type" := WebService."Object Type"::Codeunit;
          WebService."Object ID" := CollectInStoreWsCodeunitId();
          WebService."Service Name" := 'collect_in_store_service';
          WebService.Published := true;
          WebService.Insert(true);
        end;

        PrevRec := Format(WebService);
        WebService."Object ID" := CollectInStoreWsCodeunitId();
        WebService.Published := true;
        if PrevRec <> Format(WebService) then
          WebService.Modify(true);
    end;

    procedure InitSendToStoreDocument(SalesHeader: Record "Sales Header";NpCsStore: Record "NpCs Store";NpCsWorkflow: Record "NpCs Workflow";var NpCsDocument: Record "NpCs Document")
    var
        Customer: Record Customer;
    begin
        NpCsDocument.SetRange(Type,NpCsDocument.Type::"Send to Store");
        NpCsDocument.SetRange("Document Type",SalesHeader."Document Type");
        NpCsDocument.SetRange("Document No.",SalesHeader."No.");
        if NpCsDocument.FindFirst then
          exit;

        NpCsDocument.Init;
        NpCsDocument."Entry No." := 0;
        NpCsDocument.Type := NpCsDocument.Type::"Send to Store";
        NpCsDocument."Document Type" := SalesHeader."Document Type";
        NpCsDocument.Validate("Document No.",SalesHeader."No.");
        if SalesHeader."External Document No." <> '' then
          NpCsDocument."Reference No." := SalesHeader."External Document No.";
        Customer.Get(SalesHeader."Sell-to Customer No.");
        NpCsDocument."Customer E-mail" := Customer."E-Mail";
        NpCsDocument."Customer Phone No." := Customer."Phone No.";
        NpCsDocument.Validate("To Store Code",NpCsStore.Code);
        NpCsDocument.Validate("Workflow Code",NpCsWorkflow.Code);
        NpCsDocument.Insert(true);
    end;

    local procedure "--- Processing"()
    begin
    end;

    procedure UpdateProcessingStatus(var NpCsDocument: Record "NpCs Document";NewStatus: Integer)
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        NpCsExpirationMgt: Codeunit "NpCs Expiration Mgt.";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        LogMessage: Text;
    begin
        if NpCsDocument."Processing Status" = NewStatus then
          exit;

        NpCsDocument.Validate("Processing Status",NewStatus);
        NpCsExpirationMgt.SetExpiresAt(NpCsDocument);
        NpCsDocument.Modify(true);

        LogMessage := StrSubstNo(Text001,NpCsDocument."Processing Status");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');
    end;

    procedure ConfirmProcessing(var NpCsDocument: Record "NpCs Document")
    var
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        NpCsExpirationMgt: Codeunit "NpCs Expiration Mgt.";
    begin
        UpdateProcessingStatus(NpCsDocument,NpCsDocument."Processing Status"::Confirmed);
        UpdateDeliveryStatus(NpCsDocument,NpCsDocument."Delivery Status"::Ready,0,'');
        //-NPR5.51 [364557]
        if NpCsDocument."Post on" = NpCsDocument."Post on"::Processing then
          PostDocument(NpCsDocument);
        //+NPR5.51 [364557]
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit;

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
        if NpCsDocument."Delivery expires at" > 0DT then
          NpCsExpirationMgt.ScheduleUpdateExpirationStatus(NpCsDocument,NpCsDocument."Delivery expires at");
    end;

    procedure RejectProcessing(var NpCsDocument: Record "NpCs Document")
    var
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
    begin
        if SalesHeader.Get(NpCsDocument."Document Type",NpCsDocument."Document No.") then
          SalesHeader.Delete(true);
        UpdateProcessingStatus(NpCsDocument,NpCsDocument."Processing Status"::Rejected);
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit;

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    procedure ExpireProcessing(var NpCsDocument: Record "NpCs Document";SkipWorkflow: Boolean)
    var
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
    begin
        UpdateProcessingStatus(NpCsDocument,NpCsDocument."Processing Status"::Expired);
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit;

        if not SkipWorkflow then
          NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    local procedure "--- Deliver"()
    begin
    end;

    procedure UpdateDeliveryStatus(var NpCsDocument: Record "NpCs Document";NewStatus: Integer;DeliveryDocumentType: Integer;DeliveryDocumentNo: Code[20])
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        NpCsExpirationMgt: Codeunit "NpCs Expiration Mgt.";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        LogMessage: Text;
    begin
        if NpCsDocument."Delivery Status" = NewStatus then
          exit;

        NpCsDocument.Validate("Delivery Status",NewStatus);
        //-NPR5.51 [344264]
        NpCsExpirationMgt.SetExpiresAt(NpCsDocument);
        //+NPR5.51 [344264]
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered,NpCsDocument."Delivery Status"::Expired] then
          NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Post Processing";
        NpCsDocument."Delivery Document Type" := DeliveryDocumentType;
        NpCsDocument."Delivery Document No." := DeliveryDocumentNo;
        NpCsDocument.Modify(true);

        LogMessage := StrSubstNo(Text002,NpCsDocument."Delivery Status");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');
    end;

    procedure DeliverDocument(var NpCsDocument: Record "NpCs Document")
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        LogMessage: Text;
        ErrorText: Text;
    begin
        case NpCsDocument."Bill via" of
          NpCsDocument."Bill via"::POS:
            begin
              if NpCsDocument."Delivery Print Template (POS)" <> '' then begin
                asserterror begin
                  PrintDelivery(NpCsDocument);
                  Commit;
                  Error('');
                end;
                ErrorText := GetLastErrorText;
                //-NPR5.51 [344264]
                LogMessage := StrSubstNo(Text005,NpCsDocument."Delivery Print Template (POS)");
                //+NPR5.51 [344264]
                NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,ErrorText <> '',ErrorText);
              end;
            end;
          NpCsDocument."Bill via"::"Sales Document":
            begin
              //-NPR5.51 [344264]
              if NpCsDocument."Delivery Print Template (S.)" <> '' then begin
                asserterror begin
                  PrintDelivery(NpCsDocument);
                  Commit;
                  Error('');
                end;
                ErrorText := GetLastErrorText;
                LogMessage := StrSubstNo(Text005,NpCsDocument."Delivery Print Template (S.)");
                NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,ErrorText <> '',ErrorText);
                Commit;
              end;
              //+NPR5.51 [344264]
              //-NPR5.51 [364557]
              case NpCsDocument."Document Type" of
                NpCsDocument."Document Type"::Order,NpCsDocument."Document Type"::Invoice:
                  begin
                    SalesHeader.Get(NpCsDocument."Document Type",NpCsDocument."Document No.");
                    if NpCsDocument."Delivery Document Type" = NpCsDocument."Delivery Document Type"::"POS Entry" then begin
                      SalesHeader."Sales Ticket No." := NpCsDocument."Delivery Document No.";
                      SalesHeader.Modify;
                      Commit;
                    end;
                    SalesHeader.Ship := true;
                    SalesHeader.Invoice := true;
                    asserterror begin
                      CODEUNIT.Run(CODEUNIT::"Sales-Post",SalesHeader);
                      Commit;
                      Error('');
                    end;
                    ErrorText := GetLastErrorText;

                    NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Post Processing";
                    LogMessage := StrSubstNo(Text004,NpCsDocument."Document Type",NpCsDocument."Document No.");
                    NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,ErrorText <> '',ErrorText);

                    if ErrorText = '' then begin
                      NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Invoice";
                      NpCsDocument."Document No." := SalesHeader."Last Posting No.";
                      NpCsDocument.Modify(true);
                    end;
                  end;
              end;
              //+NPR5.51 [364557]
            end;
        end;
        Commit;

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    procedure ExpireDelivery(var NpCsDocument: Record "NpCs Document";SkipWorkflow: Boolean)
    var
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
    begin
        UpdateDeliveryStatus(NpCsDocument,NpCsDocument."Delivery Status"::Expired,0,'');
        Commit;

        if not SkipWorkflow then
          NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    local procedure "--- Posting"()
    begin
    end;

    local procedure PostDocument(var NpCsDocument: Record "NpCs Document")
    var
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        LogMessage: Text;
    begin
        //-NPR5.51 [364557]
        if SkipPosting(NpCsDocument) then
          exit;

        SalesHeader.Get(NpCsDocument."Document Type",NpCsDocument."Document No.");

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        CODEUNIT.Run(CODEUNIT::"Sales-Post",SalesHeader);

        case SalesHeader."Document Type" of
          SalesHeader."Document Type"::Order,SalesHeader."Document Type"::Invoice:
            begin
              NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Invoice";
            end;
          SalesHeader."Document Type"::"Return Order",SalesHeader."Document Type"::"Credit Memo":
            begin
              NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Credit Memo";
            end;
        end;
        NpCsDocument."Document No." := SalesHeader."Last Posting No.";
        NpCsDocument.Modify(true);

        LogMessage := StrSubstNo(Text007,SalesHeader."Document Type",SalesHeader."No.",NpCsDocument."Document Type",NpCsDocument."Document No.");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');
        //+NPR5.51 [364557]
    end;

    local procedure SkipPosting(NpCsDocument: Record "NpCs Document"): Boolean
    begin
        //-NPR5.51 [364557]
        if not NpCsDocument."Store Stock" then
          exit(true);

        if NpCsDocument."Document Type" = NpCsDocument."Document Type"::Quote then
          exit(true);

        if NpCsDocument."Document Type" = NpCsDocument."Document Type"::"Blanket Order" then
          exit(true);

        if NpCsDocument."Document Type" = NpCsDocument."Document Type"::"Posted Invoice" then
          exit(true);

        if NpCsDocument."Document Type" = NpCsDocument."Document Type"::"Posted Credit Memo" then
          exit(true);

        exit(false);
        //+NPR5.51 [364557]
    end;

    local procedure "--- UI"()
    begin
    end;

    procedure NewCollectOrder()
    var
        NpCsDocument: Record "NpCs Document";
        NpCsStore: Record "NpCs Store";
        NpCsStoreLocal: Record "NpCs Store";
        NpCsWorkflow: Record "NpCs Workflow";
        SalesHeader: Record "Sales Header";
        NpCsStoreMgt: Codeunit "NpCs Store Mgt.";
    begin
        //-NPR5.51 [364557]
        NpCsStoreMgt.FindLocalStore(NpCsStoreLocal);
        SalesHeader.SetRange("Location Code",NpCsStore."Location Code");
        //+NPR5.51 [364557]
        if not SelectSalesOrder(SalesHeader) then
          exit;

        //-NPR5.51 [364557]
        NpCsStore.SetFilter(Code,'<>%1',NpCsStoreLocal.Code);
        //+NPR5.51 [364557]
        if not SelectStore(NpCsStore) then
          exit;

        if not SelectWorkflow(NpCsStore,NpCsWorkflow) then
          exit;

        InitSendToStoreDocument(SalesHeader,NpCsStore,NpCsWorkflow,NpCsDocument);
        NpCsDocument."From Store Code" := NpCsStoreLocal.Code;
        NpCsDocument."To Document Type" := NpCsDocument."To Document Type"::Order;
        NpCsDocument.Modify(true);
    end;

    local procedure SelectSalesOrder(var SalesHeader: Record "Sales Header") Selected: Boolean
    begin
        if not GuiAllowed then
          exit(false);

        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);
        Selected := PAGE.RunModal(0,SalesHeader) = ACTION::LookupOK;
        exit(Selected);
    end;

    local procedure SelectStore(var NpCsStore: Record "NpCs Store") Selected: Boolean
    begin
        if not GuiAllowed then
          exit(false);

        Selected := PAGE.RunModal(0,NpCsStore) = ACTION::LookupOK;
        exit(Selected);
    end;

    local procedure SelectWorkflow(NpCsStore: Record "NpCs Store";var NpCsWorkflow: Record "NpCs Workflow") Selected: Boolean
    var
        NpCsStoreWorkflowRelation: Record "NpCs Store Workflow Relation";
        "Code": Code[20];
    begin
        NpCsStoreWorkflowRelation.SetRange("Store Code",NpCsStore.Code);
        NpCsStoreWorkflowRelation.FindSet;
        repeat
          NpCsWorkflow.Get(NpCsStoreWorkflowRelation."Workflow Code");
          NpCsWorkflow.Mark(true);
        until NpCsStoreWorkflowRelation.Next = 0;
        NpCsWorkflow.MarkedOnly(true);

        NpCsWorkflow.FindLast;
        Code := NpCsWorkflow.Code;
        NpCsWorkflow.FindFirst;
        if Code = NpCsWorkflow.Code then
          exit(true);

        Selected := PAGE.RunModal(0,NpCsWorkflow) = ACTION::LookupOK;
        exit(Selected);
    end;

    procedure RunDocumentCard(NpCsDocument: Record "NpCs Document")
    var
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        POSEntry: Record "POS Entry";
        PageManagement: Codeunit "Page Management";
        RecRef: RecordRef;
        CardPageId: Integer;
    begin
        if NpCsDocument."Delivery Document No." <> '' then begin
          case NpCsDocument."Delivery Document Type" of
            NpCsDocument."Delivery Document Type"::"Sales Shipment":
              begin
                if SalesShipmentHeader.Get(NpCsDocument."Delivery Document No.") then begin
                  RecRef.GetTable(SalesShipmentHeader);
                  CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                  PAGE.Run(CardPageId,SalesShipmentHeader);
                  exit;
                end;
              end;
            NpCsDocument."Delivery Document Type"::"Sales Invoice":
              begin
                if SalesInvoiceHeader.Get(NpCsDocument."Delivery Document No.") then begin
                  RecRef.GetTable(SalesInvoiceHeader);
                  CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                  PAGE.Run(CardPageId,SalesInvoiceHeader);
                  exit;
                end;
              end;
            NpCsDocument."Delivery Document Type"::"Sales Return Receipt":
              begin
                if ReturnReceiptHeader.Get(NpCsDocument."Delivery Document No.") then begin
                  RecRef.GetTable(ReturnReceiptHeader);
                  CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                  PAGE.Run(CardPageId,ReturnReceiptHeader);
                  exit;
                end;
              end;
            NpCsDocument."Delivery Document Type"::"Sales Credit Memo":
              begin
                if SalesCrMemoHeader.Get(NpCsDocument."Delivery Document No.") then begin
                  RecRef.GetTable(SalesCrMemoHeader);
                  CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                  PAGE.Run(CardPageId,SalesCrMemoHeader);
                  exit;
                end;
              end;
            NpCsDocument."Delivery Document Type"::"POS Entry":
              begin
                POSEntry.SetRange("Document No.",NpCsDocument."Delivery Document No.");
                PAGE.Run(PAGE::"POS Entry List",POSEntry);
                exit;
              end;
          end;
        end;

        //-NPR5.51 [364557]
        case NpCsDocument."Document Type" of
          NpCsDocument."Document Type"::"Posted Invoice":
            begin
              SalesInvoiceHeader.Get(NpCsDocument."Document No.");
              RecRef.GetTable(SalesInvoiceHeader);
              CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
              PAGE.Run(CardPageId,SalesInvoiceHeader);
              exit;
            end;
          NpCsDocument."Document Type"::"Posted Credit Memo":
            begin
              SalesCrMemoHeader.Get(NpCsDocument."Document No.");
              RecRef.GetTable(SalesCrMemoHeader);
              CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
              PAGE.Run(CardPageId,SalesCrMemoHeader);
              exit;
            end;
        end;
        //+NPR5.51 [364557]

        SalesHeader.Get(NpCsDocument."Document Type",NpCsDocument."Document No.");
        RecRef.GetTable(SalesHeader);
        CardPageId := PageManagement.GetConditionalCardPageID(RecRef);
        PAGE.Run(CardPageId,SalesHeader);
    end;

    procedure RunLog(NpCsDocument: Record "NpCs Document";WithAutoUpdate: Boolean)
    var
        NpCsDocumentLogEntry: Record "NpCs Document Log Entry";
        NpCsDocumentLogEntries: Page "NpCs Document Log Entries";
    begin
        NpCsDocumentLogEntry.Ascending(false);
        NpCsDocumentLogEntry.SetRange("Document Entry No.",NpCsDocument."Entry No.");
        NpCsDocumentLogEntries.SetAutoUpdate(WithAutoUpdate);
        NpCsDocumentLogEntries.SetTableView(NpCsDocumentLogEntry);
        NpCsDocumentLogEntries.Run;
    end;

    procedure CollectInStoreEnabled(): Boolean
    var
        NpCsStore: Record "NpCs Store";
    begin
        if not NpCsStore.ReadPermission then
          exit(false);
        NpCsStore.SetRange("Local Store",false);

        exit(NpCsStore.FindFirst);
    end;

    procedure SalesHeader2NpCsDocument(SalesHeader: Record "Sales Header";var NpCsDocument: Record "NpCs Document"): Boolean
    begin
        NpCsDocument.SetRange("Document Type",SalesHeader."Document Type");
        NpCsDocument.SetRange("Document No.",SalesHeader."No.");
        exit(NpCsDocument.FindFirst);
    end;

    procedure DrillDownSalesHeaderNpCsField(SalesHeader: Record "Sales Header")
    var
        NpCsDocument: Record "NpCs Document";
        PageId: Integer;
    begin
        if SalesHeader2NpCsDocument(SalesHeader,NpCsDocument) then
          PageId := GetNpSsDocumentListPageId(NpCsDocument);

        PAGE.Run(PageId,NpCsDocument);
    end;

    local procedure "--- Print"()
    begin
    end;

    procedure PrintOrder(var NpCsDocument: Record "NpCs Document")
    var
        NpCsDocument2: Record "NpCs Document";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        //-NPR5.51 [364557]
        NpCsDocument2.Copy(NpCsDocument);
        NpCsDocument2.SetRecFilter;
        NpCsDocument2.TestField("Processing Print Template");
        RPTemplateMgt.PrintTemplate(NpCsDocument2."Processing Print Template",NpCsDocument2,0);
        //+NPR5.51 [364557]
    end;

    procedure PrintDelivery(var NpCsDocument: Record "NpCs Document")
    var
        NpCsDocument2: Record "NpCs Document";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        NpCsDocument2.Copy(NpCsDocument);
        NpCsDocument2.SetRecFilter;
        case NpCsDocument2."Bill via" of
          NpCsDocument2."Bill via"::POS:
            begin
              NpCsDocument2.TestField("Delivery Print Template (POS)");
              RPTemplateMgt.PrintTemplate(NpCsDocument2."Delivery Print Template (POS)",NpCsDocument2,0);
            end;
          NpCsDocument2."Bill via"::"Sales Document":
            begin
              NpCsDocument2.TestField("Delivery Print Template (S.)");
              RPTemplateMgt.PrintTemplate(NpCsDocument2."Delivery Print Template (S.)",NpCsDocument2,0);
            end;
        end;
    end;

    local procedure "--- Aux"()
    begin
    end;

    procedure CollectInStoreWsCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpCs Collect Webservice");
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpCs Collect Mgt.");
    end;

    procedure GetNpSsDocumentListPageId(NpCsDocument: Record "NpCs Document") PageId: Integer
    begin
        case NpCsDocument.Type of
            NpCsDocument.Type::"Send to Store":
              begin
                exit(PAGE::"NpCs Send to Store Orders");
              end;
            NpCsDocument.Type::"Collect in Store":
              begin
                exit(PAGE::"NpCs Collect Store Orders");
              end;
        end;
    end;
}

