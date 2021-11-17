codeunit 6151195 "NPR NpCs Collect Mgt."
{
    TableNo = "NPR NpCs Document";

    trigger OnRun()
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        NpCsDocument := Rec;
        PrintDelivery(NpCsDocument);
        Rec := NpCsDocument;
    end;

    var
        Text001: Label 'Processing Status updated to %1';
        Text002: Label 'Delivery Status updated to %1';
        Text005: Label 'Delivery printed: %1';

    //--- Init ---

    procedure InitCollectInStoreService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, CollectInStoreWsCodeunitId(), 'collect_in_store_service', true);
    end;

    procedure InitSendToStoreDocument(SalesHeader: Record "Sales Header"; NpCsStore: Record "NPR NpCs Store"; NpCsWorkflow: Record "NPR NpCs Workflow"; var NpCsDocument: Record "NPR NpCs Document")
    var
        Customer: Record Customer;
    begin
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Send to Store");
        NpCsDocument.SetRange("Document Type", SalesHeader."Document Type");
        NpCsDocument.SetRange("Document No.", SalesHeader."No.");
        if NpCsDocument.FindFirst() then
            exit;

        NpCsDocument.Init();
        NpCsDocument."Entry No." := 0;
        NpCsDocument.Type := NpCsDocument.Type::"Send to Store";
        NpCsDocument."Document Type" := SalesHeader."Document Type";
        NpCsDocument.Validate("Document No.", SalesHeader."No.");
        if SalesHeader."External Document No." <> '' then
            NpCsDocument."Reference No." := SalesHeader."External Document No.";
        Customer.Get(SalesHeader."Sell-to Customer No.");
        NpCsDocument."Customer E-mail" := Customer."E-Mail";
        NpCsDocument."Customer Phone No." := Customer."Phone No.";
        NpCsDocument.Validate("To Store Code", NpCsStore.Code);
        NpCsDocument.Validate("Workflow Code", NpCsWorkflow.Code);
        NpCsDocument.Insert(true);
    end;

    //--- Processing ---

    procedure UpdateProcessingStatus(var NpCsDocument: Record "NPR NpCs Document"; NewStatus: Integer)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        LogMessage: Text;
    begin
        if NpCsDocument."Processing Status" = NewStatus then
            exit;

        NpCsDocument.Validate("Processing Status", NewStatus);
        NpCsExpirationMgt.SetExpiresAt(NpCsDocument);
        NpCsDocument.Modify(true);

        LogMessage := StrSubstNo(Text001, NpCsDocument."Processing Status");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
    end;

    procedure ConfirmProcessing(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
    begin
        UpdateProcessingStatus(NpCsDocument, NpCsDocument."Processing Status"::Confirmed);
        UpdateDeliveryStatus(NpCsDocument, NpCsDocument."Delivery Status"::Ready, 0, '');
        if NpCsDocument."Post on" = NpCsDocument."Post on"::Processing then begin
            Commit();
            ScheduleDocumentPosting(NpCsDocument);
        end;
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit();

        NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
        if NpCsDocument."Delivery expires at" > 0DT then
            NpCsExpirationMgt.ScheduleUpdateExpirationStatus(NpCsDocument, NpCsDocument."Delivery expires at");
    end;

    procedure RejectProcessing(var NpCsDocument: Record "NPR NpCs Document")
    var
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        if SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.") then
            SalesHeader.Delete(true);
        UpdateProcessingStatus(NpCsDocument, NpCsDocument."Processing Status"::Rejected);
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit();

        NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    procedure ExpireProcessing(var NpCsDocument: Record "NPR NpCs Document"; SkipWorkflow: Boolean)
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        UpdateProcessingStatus(NpCsDocument, NpCsDocument."Processing Status"::Expired);
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        NpCsWorkflowMgt.SendNotificationToStore(NpCsDocument);
        Commit();

        if not SkipWorkflow then
            NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    //--- Deliver ---

    procedure UpdateDeliveryStatus(var NpCsDocument: Record "NPR NpCs Document"; NewStatus: Integer; DeliveryDocumentType: Integer; DeliveryDocumentNo: Code[20])
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        LogMessage: Text;
    begin
        if NpCsDocument."Delivery Status" = NewStatus then
            exit;

        NpCsDocument.Validate("Delivery Status", NewStatus);
        NpCsExpirationMgt.SetExpiresAt(NpCsDocument);
        if NpCsDocument."Delivery Status" in [NpCsDocument."Delivery Status"::Delivered, NpCsDocument."Delivery Status"::Expired] then
            NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Post Processing";
        NpCsDocument."Delivery Document Type" := DeliveryDocumentType;
        NpCsDocument."Delivery Document No." := DeliveryDocumentNo;
        NpCsDocument.Modify(true);

        LogMessage := StrSubstNo(Text002, NpCsDocument."Delivery Status");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
    end;

    procedure DeliverDocument(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        LogMessage: Text;
        Success: Boolean;
    begin
        case NpCsDocument."Bill via" of
            NpCsDocument."Bill via"::POS:
                begin
                    if NpCsDocument."Delivery Print Template (POS)" <> '' then begin
                        ClearLastError();
                        Success := Codeunit.Run(Codeunit::"NPR NpCs Collect Mgt.", NpCsDocument);
                        LogMessage := StrSubstNo(Text005, NpCsDocument."Delivery Print Template (POS)");
                        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, not Success, GetLastErrorText);
                    end;
                end;
            NpCsDocument."Bill via"::"Sales Document":
                begin
                    if NpCsDocument."Delivery Print Template (S.)" <> '' then begin
                        ClearLastError();
                        Success := Codeunit.Run(Codeunit::"NPR NpCs Collect Mgt.", NpCsDocument);
                        LogMessage := StrSubstNo(Text005, NpCsDocument."Delivery Print Template (S.)");
                        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, not Success, GetLastErrorText);
                        Commit();
                    end;
                    case NpCsDocument."Document Type" of
                        NpCsDocument."Document Type"::Order, NpCsDocument."Document Type"::Invoice:
                            begin
                                SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.");
                                if NpCsDocument."Delivery Document Type" = NpCsDocument."Delivery Document Type"::"POS Entry" then begin
                                    SalesHeader."NPR Sales Ticket No." := NpCsDocument."Delivery Document No.";
                                    SalesHeader.Modify();
                                    Commit();
                                end;
                                if NpCsDocument."Post on" = NpCsDocument."Post on"::Delivery then
                                    ScheduleDocumentPosting(NpCsDocument);
                            end;
                    end;
                end;
        end;
        Commit();

        NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    procedure ExpireDelivery(var NpCsDocument: Record "NPR NpCs Document"; SkipWorkflow: Boolean)
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        UpdateDeliveryStatus(NpCsDocument, NpCsDocument."Delivery Status"::Expired, 0, '');
        NpCsWorkflowMgt.SendNotificationToStore(NpCsDocument);
        Commit();

        if not SkipWorkflow then
            NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    //--- Posting ---

    local procedure ScheduleDocumentPosting(var NpCsDocument: Record "NPR NpCs Document")
    begin
        TaskScheduler.CreateTask(Codeunit::"NPR NpCs Post Document", 0, true, CompanyName, CurrentDateTime + 10000, NpCsDocument.RecordId);
    end;

    //--- UI ---

    procedure NewCollectOrder()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsStore: Record "NPR NpCs Store";
        NpCsStoreLocal: Record "NPR NpCs Store";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        SalesHeader: Record "Sales Header";
        NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
    begin
        NpCsStoreMgt.FindLocalStore(NpCsStoreLocal);
        SalesHeader.SetRange("Location Code", NpCsStore."Location Code");
        if not SelectSalesOrder(SalesHeader) then
            exit;

        NpCsStore.SetFilter(Code, '<>%1', NpCsStoreLocal.Code);
        if not SelectStore(NpCsStore) then
            exit;

        if not SelectWorkflow(NpCsStore, NpCsWorkflow) then
            exit;

        InitSendToStoreDocument(SalesHeader, NpCsStore, NpCsWorkflow, NpCsDocument);
        NpCsDocument."From Store Code" := NpCsStoreLocal.Code;
        NpCsDocument."To Document Type" := NpCsDocument."To Document Type"::Order;
        NpCsDocument.Modify(true);
    end;

    local procedure SelectSalesOrder(var SalesHeader: Record "Sales Header") Selected: Boolean
    begin
        if not GuiAllowed then
            exit(false);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        Selected := PAGE.RunModal(0, SalesHeader) = ACTION::LookupOK;
        exit(Selected);
    end;

    local procedure SelectStore(var NpCsStore: Record "NPR NpCs Store") Selected: Boolean
    begin
        if not GuiAllowed then
            exit(false);

        Selected := PAGE.RunModal(0, NpCsStore) = ACTION::LookupOK;
        exit(Selected);
    end;

    local procedure SelectWorkflow(NpCsStore: Record "NPR NpCs Store"; var NpCsWorkflow: Record "NPR NpCs Workflow") Selected: Boolean
    var
        NpCsStoreWorkflowRelation: Record "NPR NpCs Store Workflow Rel.";
        "Code": Code[20];
    begin
        NpCsStoreWorkflowRelation.SetRange("Store Code", NpCsStore.Code);
        NpCsStoreWorkflowRelation.FindSet();
        repeat
            NpCsWorkflow.Get(NpCsStoreWorkflowRelation."Workflow Code");
            NpCsWorkflow.Mark(true);
        until NpCsStoreWorkflowRelation.Next() = 0;
        NpCsWorkflow.MarkedOnly(true);

        NpCsWorkflow.FindLast();
        Code := NpCsWorkflow.Code;
        NpCsWorkflow.FindFirst();
        if Code = NpCsWorkflow.Code then
            exit(true);

        Selected := PAGE.RunModal(0, NpCsWorkflow) = ACTION::LookupOK;
        exit(Selected);
    end;

    procedure RunDocumentCard(NpCsDocument: Record "NPR NpCs Document")
    var
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        POSEntry: Record "NPR POS Entry";
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
                            PAGE.Run(CardPageId, SalesShipmentHeader);
                            exit;
                        end;
                    end;
                NpCsDocument."Delivery Document Type"::"Sales Invoice":
                    begin
                        if SalesInvoiceHeader.Get(NpCsDocument."Delivery Document No.") then begin
                            RecRef.GetTable(SalesInvoiceHeader);
                            CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                            PAGE.Run(CardPageId, SalesInvoiceHeader);
                            exit;
                        end;
                    end;
                NpCsDocument."Delivery Document Type"::"Sales Return Receipt":
                    begin
                        if ReturnReceiptHeader.Get(NpCsDocument."Delivery Document No.") then begin
                            RecRef.GetTable(ReturnReceiptHeader);
                            CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                            PAGE.Run(CardPageId, ReturnReceiptHeader);
                            exit;
                        end;
                    end;
                NpCsDocument."Delivery Document Type"::"Sales Credit Memo":
                    begin
                        if SalesCrMemoHeader.Get(NpCsDocument."Delivery Document No.") then begin
                            RecRef.GetTable(SalesCrMemoHeader);
                            CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                            PAGE.Run(CardPageId, SalesCrMemoHeader);
                            exit;
                        end;
                    end;
                NpCsDocument."Delivery Document Type"::"POS Entry":
                    begin
                        POSEntry.SetRange("Document No.", NpCsDocument."Delivery Document No.");
                        PAGE.Run(PAGE::"NPR POS Entry List", POSEntry);
                        exit;
                    end;
            end;
        end;

        case NpCsDocument."Document Type" of
            NpCsDocument."Document Type"::"Posted Invoice":
                begin
                    SalesInvoiceHeader.Get(NpCsDocument."Document No.");
                    RecRef.GetTable(SalesInvoiceHeader);
                    CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                    PAGE.Run(CardPageId, SalesInvoiceHeader);
                    exit;
                end;
            NpCsDocument."Document Type"::"Posted Credit Memo":
                begin
                    SalesCrMemoHeader.Get(NpCsDocument."Document No.");
                    RecRef.GetTable(SalesCrMemoHeader);
                    CardPageId := PageManagement.GetDefaultCardPageID(RecRef.Number);
                    PAGE.Run(CardPageId, SalesCrMemoHeader);
                    exit;
                end;
        end;

        SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.");
        RecRef.GetTable(SalesHeader);
        CardPageId := PageManagement.GetConditionalCardPageID(RecRef);
        PAGE.Run(CardPageId, SalesHeader);
    end;

    procedure RunLog(NpCsDocument: Record "NPR NpCs Document"; WithAutoUpdate: Boolean)
    var
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
        NpCsDocumentLogEntries: Page "NPR NpCs Document Log Entries";
    begin
        NpCsDocumentLogEntry.Ascending(false);
        NpCsDocumentLogEntry.SetRange("Document Entry No.", NpCsDocument."Entry No.");
        //NpCsDocumentLogEntries.SetAutoUpdate(WithAutoUpdate);
        NpCsDocumentLogEntries.SetTableView(NpCsDocumentLogEntry);
        NpCsDocumentLogEntries.Run();
    end;

    procedure CollectInStoreEnabled(): Boolean
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        if not NpCsStore.ReadPermission then
            exit(false);
        NpCsStore.SetRange("Local Store", false);

        exit(NpCsStore.FindFirst());
    end;

    procedure SalesHeader2NpCsDocument(SalesHeader: Record "Sales Header"; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        NpCsDocument.SetRange("Document Type", SalesHeader."Document Type");
        NpCsDocument.SetRange("Document No.", SalesHeader."No.");
        exit(NpCsDocument.FindFirst());
    end;

    procedure DrillDownSalesHeaderNpCsField(SalesHeader: Record "Sales Header")
    var
        NpCsDocument: Record "NPR NpCs Document";
        PageId: Integer;
    begin
        if SalesHeader2NpCsDocument(SalesHeader, NpCsDocument) then
            PageId := GetNpSsDocumentListPageId(NpCsDocument);

        PAGE.Run(PageId, NpCsDocument);
    end;

    //--- Print ---

    procedure PrintOrder(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsDocument2: Record "NPR NpCs Document";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        NpCsDocument2.Copy(NpCsDocument);
        NpCsDocument2.SetRecFilter();
        NpCsDocument2.TestField("Processing Print Template");
        RPTemplateMgt.PrintTemplate(NpCsDocument2."Processing Print Template", NpCsDocument2, 0);
    end;

    procedure PrintDelivery(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsDocument2: Record "NPR NpCs Document";
        RPTemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        NpCsDocument2.Copy(NpCsDocument);
        NpCsDocument2.SetRecFilter();
        case NpCsDocument2."Bill via" of
            NpCsDocument2."Bill via"::POS:
                begin
                    NpCsDocument2.TestField("Delivery Print Template (POS)");
                    RPTemplateMgt.PrintTemplate(NpCsDocument2."Delivery Print Template (POS)", NpCsDocument2, 0);
                end;
            NpCsDocument2."Bill via"::"Sales Document":
                begin
                    NpCsDocument2.TestField("Delivery Print Template (S.)");
                    RPTemplateMgt.PrintTemplate(NpCsDocument2."Delivery Print Template (S.)", NpCsDocument2, 0);
                end;
        end;
    end;

    //--- Aux ---

    procedure CollectInStoreWsCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Collect WS");
    end;

    procedure GetNpSsDocumentListPageId(NpCsDocument: Record "NPR NpCs Document") PageId: Integer
    begin
        case NpCsDocument.Type of
            NpCsDocument.Type::"Send to Store":
                begin
                    exit(PAGE::"NPR NpCs Send to Store Orders");
                end;
            NpCsDocument.Type::"Collect in Store":
                begin
                    exit(PAGE::"NPR NpCs Coll. Store Orders");
                end;
        end;
    end;
}