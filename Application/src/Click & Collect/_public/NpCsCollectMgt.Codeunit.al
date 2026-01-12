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

    internal procedure InitCollectInStoreService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
        Handled: Boolean;
    begin
        if not WebService.ReadPermission then
            exit;
        if not WebService.WritePermission then
            exit;

        OnBeforeCreateTenantWebservice(WebService."Object Type"::Codeunit, CollectInStoreWsCodeunitId(), 'collect_in_store_service', Handled);
        if not Handled then
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
        OnUpdateProcessingStatusOnBeforeModifyNpCsDocument(NpCsDocument);
        NpCsDocument.Modify(true);

        LogMessage := StrSubstNo(Text001, NpCsDocument."Processing Status");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
    end;

    procedure ConfirmProcessing(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
#if not BC17
        SpfyOrdReadyForPickup: Codeunit "NPR Spfy Ord Ready For Pickup";
#endif
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
#if not BC17
        SpfyOrdReadyForPickup.ScheduleOrderReadyForPickup(NpCsDocument);
#endif
    end;

    procedure ConfirmAndPrintOrder(var NpCsDocument: Record "NPR NpCs Document")
    begin
        ConfirmProcessing(NpCsDocument);
        PrintOrder(NpCsDocument);
    end;

    procedure RejectProcessing(var NpCsDocument: Record "NPR NpCs Document")
    var
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        UpdateProcessingStatus(NpCsDocument, NpCsDocument."Processing Status"::Rejected);
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        if SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.") then
            SalesHeader.Delete(true);
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

    internal procedure DeliverDocument(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        LogMessage: Text;
        Success: Boolean;
        PostingScheduled: Boolean;
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
                                    PostingScheduled := ScheduleDocumentPosting(NpCsDocument);
                            end;
                    end;
                end;
        end;
        Commit();
        if not PostingScheduled then
            NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    internal procedure ExpireDelivery(var NpCsDocument: Record "NPR NpCs Document"; SkipWorkflow: Boolean)
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        UpdateDeliveryStatus(NpCsDocument, NpCsDocument."Delivery Status"::Expired, 0, '');
        NpCsWorkflowMgt.SendNotificationToStore(NpCsDocument);
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit();

        if not SkipWorkflow then
            NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    //--- Posting ---

    local procedure ScheduleDocumentPosting(var NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        NpCsTaskProcessorSetup: Codeunit "NPR NpCs Task Processor Setup";
    begin
        if NpCsTaskProcessorSetup.ScheduleDocumentPosting(NpCsDocument) then
            exit(true);
        exit(not IsNullGuid(TaskScheduler.CreateTask(Codeunit::"NPR NpCs Post Document", 0, true, CompanyName, CurrentDateTime + 10000, NpCsDocument.RecordId)));

    end;

    //--- UI ---

    internal procedure NewCollectOrder()
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

    internal procedure RunDocumentCard(NpCsDocument: Record "NPR NpCs Document")
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

    internal procedure RunLog(NpCsDocument: Record "NPR NpCs Document"; WithAutoUpdate: Boolean)
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

    internal procedure CollectInStoreEnabled(): Boolean
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        if not NpCsStore.ReadPermission then
            exit(false);
        NpCsStore.SetRange("Local Store", false);

        exit(NpCsStore.FindFirst());
    end;

    internal procedure SalesHeader2NpCsDocument(SalesHeader: Record "Sales Header"; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        NpCsDocument.SetRange("Document Type", SalesHeader."Document Type");
        NpCsDocument.SetRange("Document No.", SalesHeader."No.");
        exit(NpCsDocument.FindFirst());
    end;

    internal procedure DrillDownSalesHeaderNpCsField(SalesHeader: Record "Sales Header")
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

    [IntegrationEvent(false, false)]
    procedure OnBeforeCreateTenantWebservice(ObjectType: Option; ObjectId: Integer; ServiceName: Text; var Handled: Boolean)
    begin
    end;

    [Obsolete('Event is not used and will be removed in a future version.', '2025-08-31')]
    [IntegrationEvent(false, false)]
    procedure OnUpdateProcessingStatusOnBeforeModifyNpCsDocument(var NpCsDocument: Record "NPR NpCs Document")
    begin
    end;

    #region Document Change Management
    [EventSubscriber(ObjectType::Page, Page::"Sales Quote", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesQuote(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesQuote(var Rec: Record "Sales Header"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote Subform", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertSalesQuoteLine(var Rec: Record "Sales Line"; BelowxRec: Boolean; var xRec: Record "Sales Line"; var AllowInsert: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote Subform", 'OnModifyRecordEvent', '', true, true)]
    local procedure OnModifySalesQuoteLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote Subform", 'OnDeleteRecordEvent', '', true, true)]
    local procedure OnDeleteSalesQuoteLine(var Rec: Record "Sales Line"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesOrder(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesOrder(var Rec: Record "Sales Header"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertSalesOrderLine(var Rec: Record "Sales Line"; BelowxRec: Boolean; var xRec: Record "Sales Line"; var AllowInsert: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnModifyRecordEvent', '', true, true)]
    local procedure OnModifySalesOrderLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnDeleteRecordEvent', '', true, true)]
    local procedure OnDeleteSalesOrderLine(var Rec: Record "Sales Line"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesInvoice(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesInvoice(var Rec: Record "Sales Header"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertSalesInvoiceLine(var Rec: Record "Sales Line"; BelowxRec: Boolean; var xRec: Record "Sales Line"; var AllowInsert: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnModifyRecordEvent', '', true, true)]
    local procedure OnModifySalesInvoiceLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice Subform", 'OnDeleteRecordEvent', '', true, true)]
    local procedure OnDeleteSalesInvoiceLine(var Rec: Record "Sales Line"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memo", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesCreditMemo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Credit Memo", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesCreditMemo(var Rec: Record "Sales Header"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertSalesCrMemoLine(var Rec: Record "Sales Line"; BelowxRec: Boolean; var xRec: Record "Sales Line"; var AllowInsert: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnModifyRecordEvent', '', true, true)]
    local procedure OnModifySalesCrMemoLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Cr. Memo Subform", 'OnDeleteRecordEvent', '', true, true)]
    local procedure OnDeleteSalesCrMemoLine(var Rec: Record "Sales Line"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Blanket Sales Order", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyBlanketSalesOrder(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Blanket Sales Order", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteBlanketSalesOrder(var Rec: Record "Sales Header"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Blanket Sales Order Subform", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertBlanketSalesOrderLine(var Rec: Record "Sales Line"; BelowxRec: Boolean; var xRec: Record "Sales Line"; var AllowInsert: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Blanket Sales Order Subform", 'OnModifyRecordEvent', '', true, true)]
    local procedure OnModifyBlanketSalesOrderLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Blanket Sales Order Subform", 'OnDeleteRecordEvent', '', true, true)]
    local procedure OnDeleteBlanketSalesOrderLine(var Rec: Record "Sales Line"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesReturnOrder(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesReturnOrder(var Rec: Record "Sales Header"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order Subform", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertSalesReturnOrderLine(var Rec: Record "Sales Line"; BelowxRec: Boolean; var xRec: Record "Sales Line"; var AllowInsert: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order Subform", 'OnModifyRecordEvent', '', true, true)]
    local procedure OnModifySalesReturnOrderLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Return Order Subform", 'OnDeleteRecordEvent', '', true, true)]
    local procedure OnDeleteSalesReturnOrderLine(var Rec: Record "Sales Line"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifySalesOrderPick(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteSalesOrderPick(var Rec: Record "Sales Header"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick Subform", 'OnInsertRecordEvent', '', true, true)]
    local procedure OnInsertSalesOrderPickLine(var Rec: Record "Sales Line"; BelowxRec: Boolean; var xRec: Record "Sales Line"; var AllowInsert: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick Subform", 'OnModifyRecordEvent', '', true, true)]
    local procedure OnModifySalesOrderPickLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Sales Order Pick Subform", 'OnDeleteRecordEvent', '', true, true)]
    local procedure OnDeleteSalesOrderPickLine(var Rec: Record "Sales Line"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;

        if not FindCollectInStoreDocument(NpCsDocument, SalesHeader) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Debit sale info", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyDebitSaleInfo(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; var AllowModify: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR Debit sale info", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteDebitSaleInfo(var Rec: Record "Sales Header"; var AllowDelete: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        if not FindCollectInStoreDocument(NpCsDocument, Rec) then
            exit;

        CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, Rec);
    end;

    local procedure FindCollectInStoreDocument(var NpCsDocument: Record "NPR NpCs Document"; SalesHeader: Record "Sales Header"): Boolean
    begin
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Document Type", SalesHeader."Document Type");
        NpCsDocument.SetRange("Document No.", SalesHeader."No.");
        exit(NpCsDocument.FindFirst());
    end;

    local procedure CheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument: Record "NPR NpCs Document"; SalesHeader: Record "Sales Header")
    var
        FeatureFlagManagement: Codeunit "NPR Feature Flags Management";
        Handled: Boolean;
        CannotChangeErr: Label 'You cannot change Sales %1 %2 when its related %3 has %4 %5, because it can cause data discrepancy.', Comment = '%1 Document Type field value - %2 - Document Number field value, %3 - NpCs Document table caption, %4 - Delivery Status field caption, %5 - Deliver Status field value';
    begin
        if not FeatureFlagManagement.IsEnabled('checkCollectDocumentDeliveryStatus') then
            exit;

        OnBeforeCheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument, SalesHeader, Handled);
        if Handled then
            exit;

        if NpCsDocument."Bill via" = NpCsDocument."Bill via"::POS then
            exit;

        if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Delivered then
            Error(CannotChangeErr, SalesHeader."Document Type", SalesHeader."No.", NpCsDocument.TableCaption(), NpCsDocument.FieldCaption("Delivery Status"), NpCsDocument."Delivery Status");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckDeliveryStatusOnChangeRelatedSalesDocument(NpCsDocument: Record "NPR NpCs Document"; SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;
    #endregion

    #region Helper procedures
    internal procedure IsDeliveredCollectInStoreDocument(var NpCsDocument: Record "NPR NpCs Document"; DeliveryDocumentType: Integer; DeliveryDocumentNo: Code[20]): Boolean
    begin
        NpCsDocument.SetCurrentKey("Delivery Document Type", "Delivery Document No.");
        NpCsDocument.SetRange("Delivery Document Type", DeliveryDocumentType);
        NpCsDocument.SetRange("Delivery Document No.", DeliveryDocumentNo);
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        exit(not NpCsDocument.IsEmpty());
    end;

    internal procedure FindDocumentsForDeliveredCollectInStoreDocument(POSEntryNo: Integer; var PostedSalesInvoices: List of [Code[20]]; var SalesOrders: List of [Code[20]])
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        POSEntrySalesDocLink2: Record "NPR POS Entry Sales Doc. Link";
    begin
        POSEntrySalesDocLink.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
        POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::ORDER);
        POSEntrySalesDocLink.SetRange("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status"::"Not To Be Posted");
        if POSEntrySalesDocLink.FindSet() then
            repeat
                POSEntrySalesDocLink2.SetRange("POS Entry No.", POSEntrySalesDocLink."POS Entry No.");
                POSEntrySalesDocLink2.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type");
                POSEntrySalesDocLink2.SetRange("POS Entry Reference Line No.", POSEntrySalesDocLink."POS Entry Reference Line No.");
                POSEntrySalesDocLink2.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
                POSEntrySalesDocLink2.SetRange("Post Sales Document Status", POSEntrySalesDocLink."Post Sales Document Status");
                if not POSEntrySalesDocLink2.FindSet() then begin
                    if SalesHeader.Get(SalesHeader."Document Type"::Order, POSEntrySalesDocLink."Sales Document No") then begin
                        if not SalesOrders.Contains(SalesHeader."No.") then
                            SalesOrders.Add(SalesHeader."No.")
                    end else begin
                        SalesInvoiceHeader.SetCurrentKey("Order No.");
                        SalesInvoiceHeader.SetRange("Order No.", POSEntrySalesDocLink."Sales Document No");
                        if SalesInvoiceHeader.FindSet() then
                            repeat
                                if not PostedSalesInvoices.Contains(SalesInvoiceHeader."No.") then
                                    PostedSalesInvoices.Add(SalesInvoiceHeader."No.");
                            until SalesInvoiceHeader.Next() = 0;
                    end;
                end else
                    repeat
                        if not PostedSalesInvoices.Contains(POSEntrySalesDocLink2."Sales Document No") then
                            PostedSalesInvoices.Add(POSEntrySalesDocLink2."Sales Document No");
                    until POSEntrySalesDocLink2.Next() = 0
            until POSEntrySalesDocLink.Next() = 0;
    end;
    #endregion
}
