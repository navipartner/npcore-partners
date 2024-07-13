#if not BC17
codeunit 6184805 "NPR Spfy C&C Order Handler"
{
    Access = Internal;
    TableNo = "NPR Spfy C&C Order";

    trigger OnRun()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::"Click And Collect");
        ProcessCCOrder(Rec);
    end;

    var
        ServiceNameTok: Label 'CCOrder', Locked = true, MaxLength = 240;

    local procedure ProcessCCOrder(var CCOrder: Record "NPR Spfy C&C Order")
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsStore: Record "NPR NpCs Store";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        SalesHeader: Record "Sales Header";
        TempOrderLines: Record "Sales Line" temporary;
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        AlreadyImportedErr: Label 'The incoming CC order %1 has already been imported.';
    begin
        CCOrder.LockTable(true);
        CCOrder.Find();
        if CCOrder.Status = CCOrder.Status::"In-Process" then
            exit;
        SetStatusInProcess(CCOrder);  //has a commit

        if AlreadyImported(CCOrder) then
            Error(AlreadyImportedErr, CCOrder."Order ID");

        FindCustomer(CCOrder);
        FindCollectStore(CCOrder);
        ParseOrderLines(CCOrder, TempOrderLines);
        NpCsWorkflow.Get(SpfyIntegrationMgt.GetCCWorkflowCode());

        InsertSalesHeader(CCOrder, SalesHeader, NpCsStore);
        InsertSalesLines(SalesHeader, TempOrderLines);
        NpCsCollectMgt.InitSendToStoreDocument(SalesHeader, NpCsStore, NpCsWorkflow, NpCsDocument);
        UpdateNotificationsAndRunWorkflow(SalesHeader, NpCsDocument);

        SetStatusFinished(CCOrder);  //has a commit
    end;

    local procedure AlreadyImported(CCOrder: Record "NPR Spfy C&C Order"): Boolean
    var
        TempShopifyAssignedID: Record "NPR Spfy Assigned ID" temporary;
    begin
        exit(FindRelatedDocs(CCOrder, true, TempShopifyAssignedID));
    end;

    procedure FindRelatedDocs(CCOrder: Record "NPR Spfy C&C Order"; FirstOnly: Boolean; var TempShopifyAssignedID: Record "NPR Spfy Assigned ID"): Boolean
    var
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        if not TempShopifyAssignedID.IsTemporary() then
            FunctionCallOnNonTempVarErr('FindRelatedDocs()');
        TempShopifyAssignedID.Reset();
        TempShopifyAssignedID.DeleteAll();

        CCOrder.TestField("Order ID");
        CCOrder.TestField("Shopify Store Code");

        SpfyAssignedIDMgt.FilterWhereUsed("NPR Spfy ID Type"::"Entry ID", CCOrder."Order ID", false, ShopifyAssignedID);
        ShopifyAssignedID.SetFilter("Table No.", '%1|%2', Database::"Sales Header", Database::"Sales Invoice Header");
        if not ShopifyAssignedID.IsEmpty() then begin
            if FirstOnly then
                exit(true);
            ShopifyAssignedID.FindSet();
            repeat
                TempShopifyAssignedID := ShopifyAssignedID;
                TempShopifyAssignedID.Insert();
            until ShopifyAssignedID.Next() = 0;
        end;
        exit(not TempShopifyAssignedID.IsEmpty());
    end;

    local procedure SetStatusInProcess(var CCOrder: Record "NPR Spfy C&C Order")
    begin
        if CCOrder."Last Error Message".HasValue() then
            Clear(CCOrder."Last Error Message");
        CCOrder.Status := CCOrder.Status::"In-Process";
        ModifyCCOrderWithoutDatalog(CCOrder);
        Commit();
    end;

    local procedure SetStatusFinished(var CCOrder: Record "NPR Spfy C&C Order")
    begin
        CCOrder.Status := CCOrder.Status::"Order Created";
        CCOrder."C&C Order Created at" := CurrentDateTime();
        ModifyCCOrderWithoutDatalog(CCOrder);
        Commit();
    end;

    local procedure FindCustomer(var CCOrder: Record "NPR Spfy C&C Order")
    var
        GLSetup: Record "General Ledger Setup";
        NpEcStore: Record "NPR NpEc Store";
        ShopifyStore: Record "NPR Spfy Store";
    begin
        GLSetup.Get();
        CCOrder.TestField("Shopify Store Code");
        ShopifyStore.Get(CCOrder."Shopify Store Code");
        NpEcStore.SetCurrentKey("Shopify Store Code");
        NpEcStore.SetRange("Shopify Store Code", ShopifyStore.Code);
        NpEcStore.SetRange("Shopify C&C Orders", true);
        NpEcStore.FindFirst();
        CCOrder."Np Ec Store Code" := NpEcStore.Code;
        if ShopifyStore."Currency Code" = GLSetup."LCY Code" then
            CCOrder."Currency Code" := ''
        else
            CCOrder."Currency Code" := ShopifyStore."Currency Code";
        if CCOrder."Customer No." <> '' then
            exit;
        NpEcStore.TestField("Spfy Customer No.");
        CCOrder."Customer No." := NpEcStore."Spfy Customer No.";
    end;

    local procedure FindCollectStore(var CCOrder: Record "NPR Spfy C&C Order")
    var
        NpCsStore: Record "NPR NpCs Store";
        SpfyStoreLocationLink: Record "NPR Spfy Store-Location Link";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        RecRef: RecordRef;
        Found: Boolean;
        CCStoreNotFoundErr: Label '%1 could not be found for Shopify ID %2', Comment = '%1 - NpCs Store table caption, %2 - Collect in Store Shopify ID';
    begin
        if CCOrder."Collect in Store Code" <> '' then
            exit;
        CCOrder.TestField("Collect in Store Shopify ID");
        SpfyAssignedIDMgt.FilterWhereUsedInTable(
            Database::"NPR Spfy Store-Location Link", "NPR Spfy ID Type"::"Entry ID", CCOrder."Collect in Store Shopify ID", ShopifyAssignedID);
        if ShopifyAssignedID.Find('-') then
            repeat
                if RecRef.Get(ShopifyAssignedID."BC Record ID") then begin
                    RecRef.SetTable(SpfyStoreLocationLink);
                    if SpfyStoreLocationLink."Location Code" <> '' then begin
                        NpCsStore.SetRange("Location Code", SpfyStoreLocationLink."Location Code");
                        Found := NpCsStore.FindFirst();
                    end;
                end;
            until (ShopifyAssignedID.Next() = 0) or Found;
        if not Found then
            Error(CCStoreNotFoundErr, NpCsStore.TableCaption, CCOrder."Collect in Store Shopify ID");
        CCOrder."Collect in Store Code" := NpCsStore.Code;
    end;

    local procedure InsertSalesHeader(var CCOrder: Record "NPR Spfy C&C Order"; var SalesHeader: Record "Sales Header"; var NpCsStore: Record "NPR NpCs Store")
    var
        NpEcStore: Record "NPR NpEc Store";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        CCOrder.TestField("Order ID");
        CCOrder.TestField("Shopify Store Code");
        CCOrder.TestField("Customer No.");
        CCOrder.TestField("Customer Name");
        CCOrder.TestField("Np Ec Store Code");
        NpEcStore.Get(CCOrder."Np Ec Store Code");
        CCOrder.TestField("Collect in Store Code");
        NpCsStore.Get(CCOrder."Collect in Store Code");
        NpCsStore.TestField("Location Code");

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", CCOrder."Order ID", false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", CCOrder."Shopify Store Code", false);

        SalesHeader.Validate("Sell-to Customer No.", CCOrder."Customer No.");
        SalesHeader."Sell-to Customer Name" := CopyStr(CCOrder."Customer Name", 1, MaxStrLen(SalesHeader."Sell-to Customer Name"));
        SalesHeader."Sell-to Customer Name 2" := CopyStr(CCOrder."Customer Name", StrLen(SalesHeader."Sell-to Customer Name") + 1, MaxStrLen(SalesHeader."Sell-to Customer Name 2"));
        SalesHeader."Bill-to Name" := SalesHeader."Sell-to Customer Name";
        SalesHeader."Bill-to Name 2" := SalesHeader."Sell-to Customer Name 2";
        SalesHeader."NPR Bill-to E-mail" := CCOrder."Customer E-Mail";
        SalesHeader."NPR Bill-to Phone No." := CCOrder."Customer Phone No.";
        SalesHeader."Ship-to Name" := SalesHeader."Sell-to Customer Name";
        SalesHeader."Ship-to Name 2" := SalesHeader."Sell-to Customer Name 2";

        SalesHeader."External Document No." := CopyStr(CCOrder."Order ID", 1, MaxStrLen(SalesHeader."External Document No."));
        SalesHeader."Prices Including VAT" := true;

        SalesHeader.Validate("Currency Code", CCOrder."Currency Code");
        SalesHeader.Validate("Posting Date", Today());
        SalesHeader.Validate("Document Date", SalesHeader."Posting Date");
        SalesHeader.Validate("Order Date", SalesHeader."Posting Date");
        SalesHeader.Validate("Location Code", NpCsStore."Location Code");

        if NpEcStore."Salesperson/Purchaser Code" <> '' then
            SalesHeader.Validate("Salesperson Code", NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        IF NpEcStore."Global Dimension 2 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");

        SalesHeader.Modify(true);
    end;

    local procedure ParseOrderLines(CCOrder: Record "NPR Spfy C&C Order"; var TempOrderLines: Record "Sales Line")
    var
        Currency: Record Currency;
        ItemVariant: Record "Item Variant";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        OrderLineJToken: JsonToken;
        OrderLinesJToken: JsonToken;
        ShopifySku: Text;
        NoOrderLinesErr: Label 'System could not find order lines to process. Please check if at least one item has been included into the order, and information about ordered items is in correct format (json array).';
        UnknownSkuErr: Label 'Unknown SKU: %1';
    begin
        if not TempOrderLines.IsTemporary() then
            FunctionCallOnNonTempVarErr('ParseOrderLines()');

        if not (OrderLinesJToken.ReadFrom(CCOrder.GetOrderLinesStream()) and OrderLinesJToken.IsArray()) then
            Error(NoOrderLinesErr);

        if CCOrder."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(CCOrder."Currency Code");

        clear(TempOrderLines);
        TempOrderLines.DeleteAll();
        foreach OrderLineJToken in OrderLinesJToken.AsArray() do begin
            TempOrderLines.init();
            TempOrderLines.Type := TempOrderLines.Type::Item;
            if not SpfyItemMgt.ParseItem(OrderLineJToken, 'ProductSKU', ItemVariant, ShopifySku) then
                Error(UnknownSkuErr, ShopifySku);
            TempOrderLines."No." := ItemVariant."Item No.";
            TempOrderLines."Variant Code" := ItemVariant.Code;
            TempOrderLines.Quantity := JsonHelper.GetJDecimal(OrderLineJToken, 'Qty', false);
            if TempOrderLines.Quantity <= 0 then
                TempOrderLines.Quantity := 1;
            TempOrderLines."Unit Price" := Round(JsonHelper.GetJDecimal(OrderLineJToken, 'UnitPrice', false) / 100, Currency."Unit-Amount Rounding Precision");
            TempOrderLines."Line No." += 1;
            TempOrderLines.Insert();
        end;

        if TempOrderLines.IsEmpty() then
            Error(NoOrderLinesErr);
    end;

    local procedure InsertSalesLines(SalesHeader: Record "Sales Header"; var TempOrderLines: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
    begin
        if not TempOrderLines.IsTemporary() then
            FunctionCallOnNonTempVarErr('InsertSalesLines()');

        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 0;
        TempOrderLines.FindSet();
        repeat
            SalesLine."Line No." += 10000;
            SalesLine.Init();
            SalesLine.Insert(true);

            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", TempOrderLines."No.");
            if TempOrderLines."Variant Code" <> '' then
                SalesLine.Validate("Variant Code", TempOrderLines."Variant Code");
            SalesLine.Validate(Quantity, TempOrderLines.Quantity);
            if TempOrderLines."Unit Price" > 0 then begin
                SalesLine."Unit Price" := TempOrderLines."Unit Price";
                SalesLine.Validate("Line Discount %", 0);
            end;
            SalesLine.Modify(true);
        until TempOrderLines.Next() = 0;
    end;

    procedure RegisterCCOrderListener()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, Page::"NPR API Spfy C&C Order WS", ServiceNameTok, true);
    end;

    procedure CCOrderListenerWebserviceExists(): Boolean
    var
        TenantWebService: Record "Tenant Web Service";
    begin
        exit(TenantWebService.Get(TenantWebService."Object Type"::Page, ServiceNameTok));
    end;

    procedure EnableWebhookRequestRetentionPolicy()
    var
        RetentionPolicySetup: Record "Retention Policy Setup";
    begin
        if not RetentionPolicySetup.WritePermission() then
            exit;
        if not RetentionPolicySetup.Get(Database::"NPR Spfy C&C Order") or RetentionPolicySetup.Enabled then
            exit;
        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Modify(true);
    end;

    local procedure FunctionCallOnNonTempVarErr(ProcedureName: Text)
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        SpfyIntegrationMgt.FunctionCallOnNonTempVarErr(StrSubstNo('[Codeunit::NPR Spfy C&C Order Handler(%1)].%2', CurrCodeunitID(), ProcedureName));
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Spfy C&C Order Handler");
    end;

    local procedure UpdateNotificationsAndRunWorkflow(SalesHeader: Record "Sales Header"; var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsDocument."From Store Code" := NpCsDocument."To Store Code";
        NpCsDocument."Customer E-mail" := SalesHeader."NPR Bill-to E-mail";
        NpCsDocument."Notify Customer via E-mail" := NpCsDocument."Customer E-mail" <> '';
        NpCsDocument."Customer Phone No." := SalesHeader."NPR Bill-to Phone No.";
        NpCsDocument."Notify Customer via Sms" := SalesHeader."NPR Bill-to Phone No." <> '';
        if not NpCsDocument."Notify Customer via Sms" then
            NpCsDocument."Notify Customer via E-mail" := true;
        NpCsDocument.Modify(true);

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    procedure ModifyCCOrderWithoutDatalog(var CCOrder: Record "NPR Spfy C&C Order")
    var
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        DataLogMgt.DisableDataLog(true);
        CCOrder.Modify();
        DataLogMgt.DisableDataLog(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpCs Document", 'OnAfterDeleteEvent', '', true, false)]
    local procedure DeleteRelatedDocuments(var Rec: Record "NPR NpCs Document"; RunTrigger: Boolean)
    var
        CCOrder: Record "NPR Spfy C&C Order";
        NpCsDocument: Record "NPR NpCs Document";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Click And Collect") then
            exit;
        if Rec."Delivery Status" = Rec."Delivery Status"::Delivered then
            Rec.FieldError("Delivery Status");

        NpCsDocument.SetRange("Reference No.", Rec."Reference No.");
        NpCsDocument.SetRange("Document Type", Rec."Document Type");
        NpCsDocument.SetRange("Document No.", Rec."Document No.");
        NpCsDocument.SetFilter(Type, '<>%1', Rec.Type);
        if not NpCsDocument.IsEmpty() then
            NpCsDocument.DeleteAll(true);

        if CCOrder.Get(Rec."Reference No.") then
            if CCOrder.Status <> CCOrder.Status::Deleted then begin
                CCOrder.Status := CCOrder.Status::Deleted;
                ModifyCCOrderWithoutDatalog(CCOrder);
            end;
    end;
}
#endif