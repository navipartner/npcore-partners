codeunit 6151195 "NpCs Collect Mgt."
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Processing Status updated to %1';
        Text002: Label 'Delivery Status updated to %1';
        Text003: Label 'Document Archived';
        Text004: Label 'Sales %1 %2 posted';
        Text005: Label 'Delivery printed';

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

        if NpCsDocument."Archive on Delivery" then begin
          ArchiveCollectDocument(NpCsDocument);
          Commit;
        end;
        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    procedure ExpireProcessing(var NpCsDocument: Record "NpCs Document";SkipWorkflow: Boolean)
    var
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
    begin
        UpdateProcessingStatus(NpCsDocument,NpCsDocument."Processing Status"::Expired);
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit;

        if NpCsDocument."Archive on Delivery" then
          ArchiveCollectDocument(NpCsDocument);
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
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        LogMessage: Text;
    begin
        if NpCsDocument."Delivery Status" = NewStatus then
          exit;

        NpCsDocument.Validate("Delivery Status",NewStatus);
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
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        SalesHeader: Record "Sales Header";
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
                LogMessage := Text005;
                NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,ErrorText <> '',ErrorText);
              end;
            end;
          NpCsDocument."Bill via"::"Sales Document":
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
                NpCsDocument."Delivery Document Type" := NpCsDocument."Delivery Document Type"::"Sales Invoice";
                if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Return Order",SalesHeader."Document Type"::"Credit Memo"] then
                  NpCsDocument."Delivery Document Type" := NpCsDocument."Delivery Document Type"::"Sales Credit Memo";
                NpCsDocument."Delivery Document No." := SalesHeader."Last Posting No.";
                NpCsDocument.Modify(true);
              end;
              Commit;

              if NpCsDocument."Delivery Print Template (S.)" <> '' then begin
                asserterror begin
                  PrintDelivery(NpCsDocument);
                  Commit;
                  Error('');
                end;
                ErrorText := GetLastErrorText;
                LogMessage := Text005;
                NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,ErrorText <> '',ErrorText);
              end;
            end;
        end;
        Commit;

        if NpCsDocument."Archive on Delivery" then
          ArchiveCollectDocument(NpCsDocument);
        Commit;

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    procedure ExpireDelivery(var NpCsDocument: Record "NpCs Document";SkipWorkflow: Boolean)
    var
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
    begin
        UpdateDeliveryStatus(NpCsDocument,NpCsDocument."Delivery Status"::Expired,0,'');
        Commit;

        if NpCsDocument."Archive on Delivery" then
          ArchiveCollectDocument(NpCsDocument);
        Commit;

        if not SkipWorkflow then
          NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    local procedure "--- Archive"()
    begin
    end;

    procedure ArchiveCollectDocument(var NpCsDocument: Record "NpCs Document"): Boolean
    var
        SalesHeader: Record "Sales Header";
        NpCsArchDocument: Record "NpCs Arch. Document";
        NpCsArchDocumentLogEntry: Record "NpCs Arch. Document Log Entry";
        PrevNpCsDocument: Record "NpCs Document";
        NpCsDocumentLogEntry: Record "NpCs Document Log Entry";
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        ErrorText: Text;
    begin
        PrevNpCsDocument := NpCsDocument;

        asserterror begin
          if SalesHeader.Get(NpCsDocument."Document Type",NpCsDocument."Document No.") then
            SalesHeader.Delete(true);

          Commit;
          Error('');
        end;
        ErrorText := GetLastErrorText;

        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Post Processing";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,Text003,ErrorText <> '',ErrorText);
        Commit;
        if ErrorText <> '' then
          exit(false);

        InsertArchCollectDocument(NpCsDocument,NpCsArchDocument);

        NpCsDocumentLogEntry.SetRange("Document Entry No.",NpCsDocument."Entry No.");
        if NpCsDocumentLogEntry.FindSet then
          repeat
            InsertArchCollectDocumentLogEntry(NpCsDocumentLogEntry,NpCsArchDocument,NpCsArchDocumentLogEntry);
            NpCsDocumentLogEntry.Delete;
          until NpCsDocumentLogEntry.Next = 0;

        NpCsDocument.Delete(true);
        NpCsDocument := PrevNpCsDocument;
        exit(true);
    end;

    local procedure InsertArchCollectDocument(NpCsDocument: Record "NpCs Document";var NpCsArchDocument: Record "NpCs Arch. Document")
    begin
        NpCsArchDocument.Init;
        NpCsArchDocument."Entry No." := 0;
        NpCsArchDocument.Type := NpCsDocument.Type;
        NpCsArchDocument."Document Type" := NpCsDocument."Document Type";
        NpCsArchDocument."Document No." := NpCsDocument."Document No.";
        NpCsArchDocument."Reference No." := NpCsDocument."Reference No.";
        NpCsArchDocument."Workflow Code" := NpCsDocument."Workflow Code";
        NpCsArchDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step";
        NpCsArchDocument."From Document Type" := NpCsDocument."From Document Type";
        NpCsArchDocument."From Document No." := NpCsDocument."From Document No.";
        NpCsArchDocument."From Store Code" := NpCsDocument."From Store Code";
        if NpCsDocument."Callback Data".HasValue then
          NpCsDocument.CalcFields("Callback Data");
        NpCsArchDocument."Callback Data" := NpCsDocument."Callback Data";
        NpCsArchDocument."To Document Type" := NpCsDocument."To Document Type";
        NpCsArchDocument."To Document No." := NpCsDocument."To Document No.";
        NpCsArchDocument."To Store Code" := NpCsDocument."To Store Code";
        NpCsArchDocument."Processing Expiry Duration" := NpCsDocument."Processing Expiry Duration";
        NpCsArchDocument."Processing Status" := NpCsDocument."Processing Status";
        NpCsArchDocument."Processing updated at" := NpCsDocument."Processing updated at";
        NpCsArchDocument."Processing updated by" := NpCsDocument."Processing updated by";
        NpCsArchDocument."Processing expires at" := NpCsDocument."Processing expires at";
        NpCsArchDocument."Customer E-mail" := NpCsDocument."Customer E-mail";
        NpCsArchDocument."Customer Phone No." := NpCsDocument."Customer Phone No.";
        NpCsArchDocument."Send Notification from Store" := NpCsDocument."Send Notification from Store";
        NpCsArchDocument."Notify Customer via E-mail" := NpCsDocument."Notify Customer via E-mail";
        NpCsArchDocument."E-mail Template (Pending)" := NpCsDocument."E-mail Template (Pending)";
        NpCsArchDocument."E-mail Template (Confirmed)" := NpCsDocument."E-mail Template (Confirmed)";
        NpCsArchDocument."E-mail Template (Rejected)" := NpCsDocument."E-mail Template (Rejected)";
        NpCsArchDocument."E-mail Template (Expired)" := NpCsDocument."E-mail Template (Expired)";
        NpCsArchDocument."Notify Customer via Sms" := NpCsDocument."Notify Customer via Sms";
        NpCsArchDocument."Sms Template (Pending)" := NpCsDocument."Sms Template (Pending)";
        NpCsArchDocument."Sms Template (Confirmed)" := NpCsDocument."Sms Template (Confirmed)";
        NpCsArchDocument."Sms Template (Rejected)" := NpCsDocument."Sms Template (Rejected)";
        NpCsArchDocument."Sms Template (Expired)" := NpCsDocument."Sms Template (Expired)";
        NpCsArchDocument."Delivery Expiry Duration" := NpCsDocument."Delivery Expiry Days (Qty.)";
        NpCsArchDocument."Delivery Status" := NpCsDocument."Delivery Status";
        NpCsArchDocument."Delivery updated at" := NpCsDocument."Delivery updated at";
        NpCsArchDocument."Delivery updated by" := NpCsDocument."Delivery updated by";
        NpCsArchDocument."Delivery expires at" := NpCsDocument."Delivery expires at";
        NpCsArchDocument."Delivery Only (Non stock)" := NpCsDocument."Delivery Only (Non stock)";
        NpCsArchDocument."Prepaid Amount" := NpCsDocument."Prepaid Amount";
        NpCsArchDocument."Prepayment Account No." := NpCsDocument."Prepayment Account No.";
        NpCsArchDocument."Delivery Document Type" := NpCsDocument."Delivery Document Type";
        NpCsArchDocument."Delivery Document No." := NpCsDocument."Delivery Document No.";
        NpCsArchDocument."Archive on Delivery" := NpCsDocument."Archive on Delivery";
        NpCsArchDocument."Location Code" := NpCsDocument."Location Code";
        NpCsArchDocument.Insert(true);
    end;

    local procedure InsertArchCollectDocumentLogEntry(NpCsDocumentLogEntry: Record "NpCs Document Log Entry";NpCsArchDocument: Record "NpCs Arch. Document";var NpCsArchDocumentLogEntry: Record "NpCs Arch. Document Log Entry")
    begin
        NpCsArchDocumentLogEntry.Init;
        NpCsArchDocumentLogEntry."Entry No." := 0;
        NpCsArchDocumentLogEntry."Log Date" := NpCsDocumentLogEntry."Log Date";
        NpCsArchDocumentLogEntry."Workflow Type" := NpCsDocumentLogEntry."Workflow Type";
        NpCsArchDocumentLogEntry."Workflow Module" := NpCsDocumentLogEntry."Workflow Module";
        NpCsArchDocumentLogEntry."Log Message" := NpCsDocumentLogEntry."Log Message";
        if NpCsDocumentLogEntry."Error Message".HasValue then
          NpCsDocumentLogEntry.CalcFields("Error Message");
        NpCsArchDocumentLogEntry."Error Message" := NpCsDocumentLogEntry."Error Message";
        NpCsArchDocumentLogEntry."Error Entry" := NpCsDocumentLogEntry."Error Entry";
        NpCsArchDocumentLogEntry."User ID" := NpCsDocumentLogEntry."User ID";
        NpCsArchDocumentLogEntry."Store Code" := NpCsDocumentLogEntry."Store Code";
        NpCsArchDocumentLogEntry."Store Log Entry No." := NpCsDocumentLogEntry."Store Log Entry No.";
        NpCsArchDocumentLogEntry."Document Entry No." := NpCsArchDocument."Entry No.";
        NpCsArchDocumentLogEntry."Original Entry No." := NpCsDocumentLogEntry."Entry No.";
        NpCsArchDocumentLogEntry.Insert(true);
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
        if not SelectSalesOrder(SalesHeader) then
          exit;

        if not SelectStore(NpCsStore) then
          exit;

        if not SelectWorkflow(NpCsStore,NpCsWorkflow) then
          exit;

        InitSendToStoreDocument(SalesHeader,NpCsStore,NpCsWorkflow,NpCsDocument);
        NpCsStoreMgt.FindLocalStore(NpCsStoreLocal);
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

        NpCsStore.SetRange("Local Store",false);
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

