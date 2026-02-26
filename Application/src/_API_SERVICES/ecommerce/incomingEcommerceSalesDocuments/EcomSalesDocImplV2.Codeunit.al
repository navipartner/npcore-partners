#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248609 "NPR Ecom Sales Doc Impl V2"
{
    Access = Internal;

    var
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        IsShopifyDocument: Boolean;
        CustomerModeCreationErrorLbl: Label 'Customer Create is not allowed when Customer Update Mode is %1';

    procedure Process(var EcomSalesHeader: Record "NPR Ecom Sales Header") Success: Boolean
    var
        SalesHeader: Record "Sales Header";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        IncEcomSalesWebhook: Codeunit "NPR Inc Ecom Sales Webhooks";
    begin
        //lock table
        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::UpdLock;
        EcomSalesHeader.Get(EcomSalesHeader.RecordId);

        IsShopifyDocument := SpfyEcomSalesDocPrcssr.IsShopifyDocument(EcomSalesHeader);

        CheckIfDocumentCanBeProcessed(EcomSalesHeader);
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader.Modify();

        InsertSalesDocument(EcomSalesHeader, SalesHeader);

        Success := true;

        case EcomSalesHeader."Document Type" of
            EcomSalesHeader."Document Type"::Order:
                IncEcomSalesWebhook.OnSalesOrderCreated(SalesHeader.SystemId, SalesHeader."External Document No.", SalesHeader."NPR External Order No.", SalesHeader."NPR Inc Ecom Sale Id");
            EcomSalesHeader."Document Type"::"Return Order":
                IncEcomSalesWebhook.OnSalesReturnOrderCreated(SalesHeader.SystemId, SalesHeader."External Document No.", SalesHeader."NPR External Order No.", SalesHeader."NPR Inc Ecom Sale Id");
        end;

        PostEcomSalesDoc(EcomSalesHeader, SalesHeader);
        EcomSalesDocImplEvents.OnAfterProcess(EcomSalesHeader, Success);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure InsertSalesDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header") Success: Boolean
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        InsertSalesHeader(EcomSalesHeader, SalesHeader);
        InsertSalesLines(EcomSalesHeader, SalesHeader);
        TransferCapturedPayments(EcomSalesHeader, SalesHeader);
        InsertPaymentLines(EcomSalesHeader, SalesHeader);
        InsertCommentLines(EcomSalesHeader, SalesHeader);
        if EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::Order then
            UpdateExtCouponReservations(EcomSalesHeader, SalesHeader);

        if IsShopifyDocument then
            SpfyEcomSalesDocPrcssr.FinalizeSalesOrder(SalesHeader, EcomSalesHeader);
        //this event is here just for backwards compatiblity it should not be used.
        IncEcomSalesDocImplEvents.OnProcessBeforeRelease(IncEcomSalesHeader, SalesHeader);
        EcomSalesDocImplEvents.OnProcessBeforeRelease(EcomSalesHeader, SalesHeader);

        if (IncEcomSalesDocSetup."Release Sale Ord After Prc" and (SalesHeader."Document Type" = SalesHeader."Document Type"::Order)) or
           (IncEcomSalesDocSetup."Release Sale Ret Ord After Prc" and (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order"))
        then
            if not IsShopifyDocument then
                ReleaseSalesDoc.PerformManualRelease(SalesHeader)
            else
                if SpfyEcomSalesDocPrcssr.CheckIfShouldReleaseOrder(EcomSalesHeader) then
                    ReleaseSalesDoc.PerformManualRelease(SalesHeader);

        Success := true;

        EcomSalesDocImplEvents.OnAfterInsertSalesDocument(EcomSalesHeader, SalesHeader, Success)
    end;

    local procedure InsertSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header");
    var
        Customer: Record Customer;
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        LocationCode: Code[10];
        RecordRef: RecordRef;
        PaymentMethodCodeUpdated: Boolean;
    begin
        if not IsShopifyDocument then
            InsertCustomer(EcomSalesHeader, Customer)
        else
            Customer.Get(EcomSalesHeader."Sell-to Customer No.");

        SalesHeader.Init();
        case EcomSalesHeader."Document Type" of
            EcomSalesHeader."Document Type"::Order:
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
            EcomSalesHeader."Document Type"::"Return Order":
                SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        end;

        SalesHeader."No." := '';


        SalesHeader."NPR External Order No." := EcomSalesHeader."External No.";
        SalesHeader."External Document No." := EcomSalesHeader."External Document No.";
        if SalesHeader."External Document No." = '' then
            SalesHeader."External Document No." := SalesHeader."NPR External Order No.";

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            SalesHeader."Your Reference" := EcomSalesHeader."Your Reference";
        EcomSalesDocImplEvents.OnAfterPopulateGeneralSalesHeaderInformation(EcomSalesHeader, SalesHeader);
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        PopulateSalesHeaderSellToNameFromEcomSalesHeader(EcomSalesHeader, SalesHeader);
        SalesHeader."Sell-to Address" := EcomSalesHeader."Sell-to Address";
        SalesHeader."Sell-to Address 2" := EcomSalesHeader."Sell-to Address 2";
        SalesHeader."Sell-to Post Code" := EcomSalesHeader."Sell-to Post Code";
        SalesHeader."Sell-to County" := EcomSalesHeader."Sell-to County";
        SalesHeader."Sell-to City" := EcomSalesHeader."Sell-to City";
        SalesHeader."Sell-to Country/Region Code" := EcomSalesHeader."Sell-to Country Code";
        SalesHeader."Sell-to Contact" := EcomSalesHeader."Sell-to Contact";

        SalesHeader."Sell-to Phone No." := EcomSalesHeader."Sell-to Phone No.";

        RecordRef.GetTable(SalesHeader);

        //"OIOUBL-Sell-to Contact Phone No."
        SetFieldText(RecordRef, 13635, EcomSalesHeader."Sell-to Phone No.");
        //"OIOUBL-Sell-to Contact E-Mail"
        SetFieldText(RecordRef, 13637, EcomSalesHeader."Sell-to Email");
        //"OIOUBL-GLN"
        SetFieldText(RecordRef, 13630, EcomSalesHeader."Sell-to EAN");
        RecordRef.SetTable(SalesHeader);

        SalesHeader."NPR Bill-to E-mail" := EcomSalesHeader."Sell-to Invoice Email";
        SalesHeader."NPR Bill-to Phone No." := EcomSalesHeader."Sell-to Invoice Phone No.";
        SalesHeader."Bill-to Name" := SalesHeader."Sell-to Customer Name";
        SalesHeader."Bill-to Name 2" := SalesHeader."Sell-to Customer Name 2";
        SalesHeader."Bill-to Address" := SalesHeader."Sell-to Address";
        SalesHeader."Bill-to Address 2" := SalesHeader."Sell-to Address 2";
        SalesHeader."Bill-to Post Code" := SalesHeader."Sell-to Post Code";
        SalesHeader."Bill-to City" := SalesHeader."Sell-to City";
        SalesHeader."Bill-to Contact" := SalesHeader."Sell-to Contact";
        SalesHeader."Bill-to Contact No." := SalesHeader."Sell-to Contact No.";
        SalesHeader."Bill-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";
        SalesHeader."Bill-to County" := SalesHeader."Sell-to County";
        SalesHeader."NPR Bill-to E-mail" := EcomSalesHeader."Sell-to Email";
        SalesHeader."Ship-to Name" := SalesHeader."Sell-to Customer Name";
        SalesHeader."Ship-to Name 2" := SalesHeader."Sell-to Customer Name 2";
        SalesHeader."Ship-to Address" := SalesHeader."Sell-to Address";
        SalesHeader."Ship-to Address 2" := SalesHeader."Sell-to Address 2";
        SalesHeader."Ship-to Post Code" := SalesHeader."Sell-to Post Code";
        SalesHeader."Ship-to City" := SalesHeader."Sell-to City";
        SalesHeader."Ship-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";
        SalesHeader."Ship-to Contact" := SalesHeader."Sell-to Contact";
        SalesHeader."Ship-to County" := SalesHeader."Sell-to County";


        SalesHeader."Prices Including VAT" := not EcomSalesHeader."Price Excl. VAT";

        if IncomingSalesHeaderHasShipmentInformation(EcomSalesHeader) then begin
            PopulateSalesHeaderShipToNameFromEcomSalesHeader(EcomSalesHeader, SalesHeader);
            SalesHeader."Ship-to Address" := EcomSalesHeader."Ship-to Address";
            SalesHeader."Ship-to Address 2" := EcomSalesHeader."Ship-to Address 2";
            SalesHeader."Ship-to Post Code" := EcomSalesHeader."Ship-to Post Code";
            SalesHeader."Ship-to County" := EcomSalesHeader."Ship-to County";
            SalesHeader."Ship-to City" := EcomSalesHeader."Ship-to City";
            SalesHeader."Ship-to Country/Region Code" := EcomSalesHeader."Ship-to Country Code";
            SalesHeader."Ship-to Contact" := EcomSalesHeader."Ship-to Contact";
        end else begin
            SalesHeader."Ship-to Name" := SalesHeader."Sell-to Customer Name";
            SalesHeader."Ship-to Name 2" := SalesHeader."Sell-to Customer Name 2";
            SalesHeader."Ship-to Address" := EcomSalesHeader."Sell-to Address";
            SalesHeader."Ship-to Address 2" := EcomSalesHeader."Sell-to Address 2";
            SalesHeader."Ship-to Post Code" := EcomSalesHeader."Sell-to Post Code";
            SalesHeader."Ship-to County" := EcomSalesHeader."Sell-to County";
            SalesHeader."Ship-to City" := EcomSalesHeader."Sell-to City";
            SalesHeader."Ship-to Country/Region Code" := EcomSalesHeader."Sell-to Country Code";
            SalesHeader."Ship-to Contact" := EcomSalesHeader."Sell-to Contact";
        end;

        SalesHeader.Validate("Salesperson Code", Customer."Salesperson Code");

        LocationCode := EcomSalesDocUtils.GetSalesLocationCode(EcomSalesHeader);
        if LocationCode <> '' then
            SalesHeader.Validate("Location Code", LocationCode);

        if EcomSalesHeader."Shipment Method Code" <> '' then begin
            ShipmentMapping.SetRange("External Shipment Method Code", EcomSalesHeader."Shipment Method Code");
            ShipmentMapping.FindFirst();

            SalesHeader.Validate("Shipment Method Code", ShipmentMapping."Shipment Method Code");
            SalesHeader.Validate("Shipping Agent Code", ShipmentMapping."Shipping Agent Code");
            SalesHeader.Validate("Shipping Agent Service Code", ShipmentMapping."Shipping Agent Service Code");
            SalesHeader."NPR Delivery Location" := EcomSalesHeader."Shipment Service";
        end;

        if IsShopifyDocument then
            SpfyEcomSalesDocPrcssr.RefreshShopifySalesHeaderShipmentAndLocationFields(SalesHeader, EcomSalesHeader, ShipmentMapping);
        if SalesHeader."Payment Method Code" = '' then begin
            Clear(PaymentMethodCodeUpdated);

            EcomSalesPmtLine.Reset();
            EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
            EcomSalesPmtLine.SetRange("Payment Method Type", EcomSalesPmtLine."Payment Method Type"::"Payment Method");
            EcomSalesPmtLine.SetLoadFields("External Payment Method Code", "External Payment Type");
            if EcomSalesPmtLine.FindSet() then
                repeat
                    PaymentMapping.Reset();
                    PaymentMapping.SetRange("External Payment Method Code", EcomSalesPmtLine."External Payment Method Code");
                    PaymentMapping.SetRange("External Payment Type", EcomSalesPmtLine."External Payment Type");
                    if not PaymentMapping.FindFirst() then begin
                        PaymentMapping.SetRange("External Payment Type");
                        PaymentMapping.FindFirst();
                    end;
                    if (PaymentMapping."Payment Method Code" <> '') then begin
                        SalesHeader.Validate("Payment Method Code", PaymentMapping."Payment Method Code");
                        PaymentMethodCodeUpdated := true;
                    end;
                until (EcomSalesPmtLine.Next() = 0) or PaymentMethodCodeUpdated;

        end;
        if IsShopifyDocument then
            SpfyEcomSalesDocPrcssr.RefreshShopifySalesHeaderPostingDate(SalesHeader, EcomSalesHeader);

        SalesHeader.Validate("Currency Code", EcomSalesHeader."Currency Code");
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            if SalesHeader."Currency Code" <> '' then begin
                if EcomSalesHeader."Currency Exchange Rate" > 0 then
                    SalesHeader.Validate("Currency Factor", EcomSalesHeader."Currency Exchange Rate");
            end;

        if IsShopifyDocument then
            SpfyEcomSalesDocPrcssr.AssignShopifyIDAndRefreshShopifySalesHeaderDimensions(SalesHeader, EcomSalesHeader);

        SalesHeader."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        EcomSalesDocImplEvents.OnInsertSalesHeaderBeforeFinalizeSalesHeader(EcomSalesHeader, SalesHeader);
        SalesHeader.Modify(true);

        EcomSalesHeader."Created Doc No." := SalesHeader."No.";
        EcomSalesHeader.Modify(true);

        EcomSalesDocImplEvents.OnAfterInsertSalesHeader(EcomSalesHeader, SalesHeader);
    end;

    local procedure InsertCustomer(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Customer: Record Customer) Success: Boolean
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        UpdateContFromCust: Codeunit "CustCont-Update";
        NewCustomer: Boolean;
        CustomerUpdateHandled: Boolean;
        ConfigTemplateCode: Code[10];
        CustomerTemplateCode: Code[20];
        VATBusPostingGroupCode: Code[20];
    begin
        if not IncEcomSalesDocSetup.Get() then
            Clear(IncEcomSalesDocSetup);

        if GetContactCustomer(EcomSalesHeader."Sell-to Customer No.", Customer) then
            exit;

        NewCustomer := not GetCustomer(EcomSalesHeader, Customer);

        EcomSalesDocImplEvents.OnAfterDecideNewCustomer(EcomSalesHeader, Customer, NewCustomer);

        EcomSalesDocUtils.GetCustomerTemplateAndConfigCode(EcomSalesHeader, CustomerTemplateCode, ConfigTemplateCode);

        if NewCustomer then begin
            if not (IncEcomSalesDocSetup."Customer Update Mode" in [IncEcomSalesDocSetup."Customer Update Mode"::"Create and Update", IncEcomSalesDocSetup."Customer Update Mode"::Create]) then
                Error(CustomerModeCreationErrorLbl, IncEcomSalesDocSetup."Customer Update Mode");


            InitCustomer(EcomSalesHeader, Customer);

            Customer."NPR External Customer No." := EcomSalesHeader."Sell-to Customer No.";
            Customer.Insert(true);

            Customer."Post Code" := EcomSalesHeader."Sell-to Post Code";
            Customer."Country/Region Code" := EcomSalesHeader."Sell-to Country Code";

            UpdateCustomerFromTemplates(Customer, CustomerTemplateCode, ConfigTemplateCode);
        end;

        EcomSalesDocImplEvents.OnBeforeHandleCustomerUpdateMode(EcomSalesHeader, CustomerTemplateCode, VATBusPostingGroupCode, IncEcomSalesDocSetup, Customer, NewCustomer, CustomerUpdateHandled);

        if not CustomerUpdateHandled then
            case IncEcomSalesDocSetup."Customer Update Mode" of
                IncEcomSalesDocSetup."Customer Update Mode"::Create:
                    if not NewCustomer then
                        exit;
                IncEcomSalesDocSetup."Customer Update Mode"::None:
                    exit;
            end;

        Customer."Post Code" := EcomSalesHeader."Sell-to Post Code";
        Customer."Country/Region Code" := EcomSalesHeader."Sell-to Country Code";


        PopulateCustomerNameFromEcomSalesHeader(EcomSalesHeader, Customer);
        Customer.Address := EcomSalesHeader."Sell-to Address";
        Customer."Address 2" := EcomSalesHeader."Sell-to Address 2";
        Customer."Post Code" := EcomSalesHeader."Sell-to Post Code";
        Customer.County := EcomSalesHeader."Sell-to County";
        Customer.City := EcomSalesHeader."Sell-to City";
        Customer."Country/Region Code" := EcomSalesHeader."Sell-to Country Code";
        Customer.Contact := EcomSalesHeader."Sell-to Contact";
        Customer."E-Mail" := EcomSalesHeader."Sell-to Email";
        Customer."Phone No." := EcomSalesHeader."Sell-to Phone No.";
        Customer.GLN := EcomSalesHeader."Sell-to EAN";
        if Customer.GLN <> '' then begin
            if Customer.Contact = '' then
                Customer.Contact := 'X';
        end;

        Customer."VAT Registration No." := EcomSalesHeader."Sell-to VAT Registration No.";
        Customer."Prices Including VAT" := not EcomSalesHeader."Price Excl. VAT";

        EcomSalesDocImplEvents.OnInsertCustomerBeforeFinalizeCustomer(EcomSalesHeader, NewCustomer, Customer);
        Customer.Modify(true);

        UpdateContFromCust.OnModify(Customer);

        Success := true;
    end;

    local procedure InitCustomer(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Customer: Record Customer)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        Customer.Init();
        Customer."No." := '';
        case IncEcomSalesDocSetup."Customer Mapping" of
            IncEcomSalesDocSetup."Customer Mapping"::"Customer No.":
                Customer."No." := EcomSalesHeader."Sell-to Customer No.";
            IncEcomSalesDocSetup."Customer Mapping"::"Phone No. to Customer No.":
                Customer."No." := EcomSalesHeader."Sell-to Phone No.";
        end;

        EcomSalesDocImplEvents.OnAfterInitCustomer(EcomSalesHeader, Customer);
    end;

    local procedure GetContactCustomer(ContactNo: Code[20]; var Customer: Record Customer) Found: Boolean
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if not Contact.Get(ContactNo) then
            exit;

        ContactBusinessRelation.SetRange("Contact No.", Contact."Company No.");
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetFilter("No.", '<>%1', '');
        ContactBusinessRelation.SetLoadFields("No.");
        if not ContactBusinessRelation.FindFirst() then
            exit;

        Found := Customer.Get(ContactBusinessRelation."No.");
    end;

    local procedure GetCustomer(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Customer: Record Customer) Found: Boolean
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        Clear(Customer);

        case IncEcomSalesDocSetup."Customer Mapping" of
            IncEcomSalesDocSetup."Customer Mapping"::"E-mail":
                begin
                    Customer.SetRange("E-Mail", EcomSalesHeader."Sell-to Email");
                    Found := Customer.FindFirst() and (Customer."E-Mail" <> '');
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"Phone No.":
                begin
                    Customer.SetRange("Phone No.", EcomSalesHeader."Sell-to Phone No.");
                    Found := Customer.FindFirst() and (Customer."Phone No." <> '');
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"E-mail AND Phone No.":
                begin
                    Customer.SetRange("E-Mail", EcomSalesHeader."Sell-to Email");
                    Customer.SetRange("Phone No.", EcomSalesHeader."Sell-to Phone No.");
                    Found := Customer.FindFirst() and (Customer."E-Mail" <> '') and (Customer."Phone No." <> '');
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"E-mail OR Phone No.":
                begin
                    Customer.SetRange("E-Mail", EcomSalesHeader."Sell-to Email");
                    Found := Customer.FindFirst() and (Customer."E-Mail" <> '');
                    if Found then
                        exit;

                    Customer.SetRange("E-Mail");
                    Customer.SetRange("Phone No.", EcomSalesHeader."Sell-to Phone No.");
                    Found := Customer.FindFirst() and (Customer."Phone No." <> '');
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"Customer No.":
                begin
                    if EcomSalesHeader."Sell-to Customer No." = '' then
                        exit;
                    Found := Customer.Get(EcomSalesHeader."Sell-to Customer No.");
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"Phone No. to Customer No.":
                begin
                    if EcomSalesHeader."Sell-to Phone No." = '' then
                        exit;
                    Found := Customer.Get(EcomSalesHeader."Sell-to Phone No.");
                end;
        end;
    end;

    local procedure SetFieldText(var RecRef: RecordRef; FieldNo: Integer; Value: Text)
    var
        "Field": Record "Field";
        FieldObsolete: Record "Field";
        RecRefObsolete: RecordRef;
        FieldRef: FieldRef;
        FieldRefObsolete: FieldRef;
    begin
        if not Field.Get(RecRef.Number, FieldNo) then
            exit;

        RecRefObsolete.GetTable(Field);
        if FieldObsolete.Get(RecRefObsolete.Number, 25) then begin
            FieldRefObsolete := RecRefObsolete.Field(25);
            if Format(FieldRefObsolete.Value, 0, 2) <> '0' then
                exit;
        end;
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value := Value;
    end;

    local procedure IncomingSalesHeaderHasShipmentInformation(EcomSalesHeader: Record "NPR Ecom Sales Header") HasShipmentInformation: Boolean
    var
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
    begin
        HasShipmentInformation := (EcomSalesHeader."Ship-to Address" <> '') or
                                  (EcomSalesHeader."Ship-to Address 2" <> '') or
                                  (EcomSalesHeader."Ship-to City" <> '') or
                                  (EcomSalesHeader."Ship-to Contact" <> '') or
                                  (EcomSalesHeader."Ship-to Country Code" <> '') or
                                  (EcomSalesHeader."Ship-to County" <> '') or
                                  (EcomSalesHeader."Ship-to Name" <> '') or
                                  (EcomSalesHeader."Ship-to Post Code" <> '');

        EcomSalesDocImplEvents.OnAfterIncomingSalesHeaderHasShipmentInformation(EcomSalesHeader, HasShipmentInformation);
    end;


    local procedure InsertSalesLines(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SaleLine: Record "Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if not EcomSalesLine.FindSet() then
            exit;

        repeat
            Clear(SaleLine);
            case EcomSalesLine.Type of
                EcomSalesLine.Type::Item:
                    InsertSalesLineItem(EcomSalesHeader, SalesHeader, EcomSalesLine, SaleLine);
                EcomSalesLine.Type::Comment:
                    InsertSalesLineComment(EcomSalesHeader, SalesHeader, EcomSalesLine, SaleLine);
                EcomSalesLine.Type::"Shipment Fee":
                    InsertSalesLineShipmentFee(EcomSalesHeader, SalesHeader, EcomSalesLine, SaleLine);
                EcomSalesLine.Type::Voucher:
                    InsertSalesLineVoucher(EcomSalesHeader, SalesHeader, EcomSalesLine, SaleLine);
            end;
            if IsShopifyDocument then
                SpfyEcomSalesDocPrcssr.AssignShopifyIdToSalesLine(SaleLine, EcomSalesLine);
        until EcomSalesLine.Next() = 0;
    end;

    local procedure InsertSalesLineItem(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line")
    var
        ItemVariant: Record "Item Variant";
        EcomSalesDocCrtImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ItemDoesntExistErrorLbl: Label 'Item %1 in %2 does not exist.', Comment = '%1 - external no., %2 - inc sales line record id';
    begin
        if (EcomSalesLine.Type <> EcomSalesLine.Type::Item) then
            exit;

        if not EcomSalesDocUtils.GetItemNoAndVariantNoFromEcomSalesLine(EcomSalesLine, ItemNo, VariantCode) then
            Error(ItemDoesntExistErrorLbl, EcomSalesLine."No.", Format(EcomSalesLine.RecordId));

        if not ItemVariant.Get(ItemNo, VariantCode) then
            Clear(ItemVariant);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := EcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        PopulateSalesLineDescriptionFromEcomSalesLine(EcomSalesLine, SalesLine);

        SalesLine."Variant Code" := VariantCode;
        if (VariantCode <> '') and (SalesLine."Description 2" = '') then
            SalesLine."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(SalesLine."Description 2"));

        if SalesHeader."Location Code" <> '' then
            SalesLine.Validate("Location Code", SalesHeader."Location Code");
        SalesLine.Validate(Quantity, EcomSalesLine.Quantity);

        if EcomSalesHeader."Document Type" = EcomSalesHeader."Document Type"::Order then
            if EcomSalesLine."Requested Delivery Date" <> 0D then
                SalesLine.Validate("Requested Delivery Date", EcomSalesLine."Requested Delivery Date");

        if EcomSalesLine."Unit of Measure Code" <> '' then
            SalesLine.Validate("Unit of Measure Code", EcomSalesLine."Unit of Measure Code");

        if EcomSalesLine."Unit Price" > 0 then
            SalesLine.Validate("Unit Price", EcomSalesLine."Unit Price")
        else
            SalesLine."Unit Price" := EcomSalesLine."Unit Price";
        SalesLine.Validate("VAT Prod. Posting Group");
        SalesLine.Validate("VAT %", EcomSalesLine."VAT %");

        if SalesLine."Unit Price" <> 0 then
            SalesLine.Validate("Line Amount", EcomSalesLine."Line Amount");

        SalesLine."NPR Inc Ecom Sales Line Id" := EcomSalesLine.SystemId;
        EcomSalesDocCrtImplEvents.OnInsertSalesLineItemBeforeFinalizeSalesLine(EcomSalesHeader, SalesHeader, EcomSalesLine, SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineComment(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line")
    var
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        if EcomSalesLine.Type <> EcomSalesLine.Type::Comment then
            exit;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := EcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::" ");
        PopulateSalesLineDescriptionFromEcomSalesLine(EcomSalesLine, SalesLine);
        SalesLine."NPR Inc Ecom Sales Line Id" := EcomSalesLine.SystemId;
        EcomSalesDocImplEvents.OnInsertSalesLineCommentBeforeFinalizeSalesLine(EcomSalesHeader, SalesHeader, EcomSalesLine, SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineShipmentFee(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomEcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line")
    var
        SalesCommentLine: Record "Sales Comment Line";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        if EcomEcomSalesLine.Type <> EcomEcomSalesLine.Type::"Shipment Fee" then
            exit;

        if (EcomEcomSalesLine.Quantity = 0) and (EcomEcomSalesLine."Line Amount" = 0) then begin
            InsertSalesLineShipmentFeeAsComment(EcomSalesHeader, SalesHeader, EcomEcomSalesLine, SalesCommentLine);
            exit;
        end;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := EcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);

        ShipmentMapping.SetRange("External Shipment Method Code", EcomEcomSalesLine."No.");
        ShipmentMapping.SetLoadFields("Shipment Fee Type", "Shipment Fee No.", Description);
        ShipmentMapping.FindFirst();

        case ShipmentMapping."Shipment Fee Type" of
            ShipmentMapping."Shipment Fee Type"::"G/L Account":
                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
            ShipmentMapping."Shipment Fee Type"::Item:
                SalesLine.Validate(Type, SalesLine.Type::Item);
            ShipmentMapping."Shipment Fee Type"::Resource:
                SalesLine.Validate(Type, SalesLine.Type::Resource);
            ShipmentMapping."Shipment Fee Type"::"Fixed Asset":
                SalesLine.Validate(Type, SalesLine.Type::"Fixed Asset");
            ShipmentMapping."Shipment Fee Type"::"Charge (Item)":
                SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
            else
                EcomSalesDocImplEvents.OnInsertSalesLineShipmentFeeSelectShippingFee(EcomSalesHeader, SalesHeader, EcomEcomSalesLine, SalesLine, ShipmentMapping);
        end;

        SalesLine.Validate("No.", ShipmentMapping."Shipment Fee No.");
        if EcomEcomSalesLine.Quantity <> 0 then
            SalesLine.Validate(Quantity, EcomEcomSalesLine.Quantity);

        SalesLine.Validate("VAT %", EcomEcomSalesLine."VAT %");

        SalesLine.Validate("Unit Price", EcomEcomSalesLine."Unit Price");
        PopulateSalesLineDescriptionFromEcomSalesLine(EcomEcomSalesLine, SalesLine);

        if ShipmentMapping.Description <> '' then
            Salesline.Description := ShipmentMapping.Description;

        SalesLine."NPR Inc Ecom Sales Line Id" := EcomEcomSalesLine.SystemId;
        EcomSalesDocImplEvents.OnInsertSalesLineShipmentFeeBeforeFinalizeLine(EcomSalesHeader, SalesHeader, EcomEcomSalesLine, SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line")
    var
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        RvArchVoucher: Record "NPR NpRv Arch. Voucher";
        VoucherDoesntExistErrMsg: Label 'Voucher %1 doesn''t exist';
    begin
        if EcomSalesLine.Type <> EcomSalesLine.Type::Voucher then
            exit;

        if (EcomSalesLine."No." = '') then
            exit;

        if not NpRvVoucher.Get(EcomSalesLine."No.") then
            if not RvArchVoucher.Get(EcomSalesLine."No.") then
                Error(VoucherDoesntExistErrMsg, EcomSalesLine."No.");

        NpRvSalesLine.SetCurrentKey("Document No.", "NPR Inc Ecom Sales Line Id");
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("NPR Inc Ecom Sales Line Id", EcomSalesLine.SystemId);
        NpRvSalesLine.FindFirst();
        NpRvVoucherType.Get(NpRvSalesLine."Voucher Type");

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := EcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", NpRvVoucherType."Account No.");
        SalesLine.Description := CopyStr((StrSubstNo('%1 %2', EcomSalesLine."Barcode No.", NpRvVoucherType.Description)), 1, MaxStrLen(SalesLine.Description));
        SalesLine.Validate(Quantity, EcomSalesLine.Quantity);
        SalesLine.Validate("VAT %", EcomSalesLine."VAT %");
        SalesLine.Validate("Unit Price", EcomSalesLine."Unit Price");
        if SalesLine."Unit Price" <> 0 then
            SalesLine.Validate("Line Amount", EcomSalesLine."Line Amount");
        SalesLine."NPR Inc Ecom Sales Line Id" := EcomSalesLine.SystemId;

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Document Type" := SalesLine."Document Type";
        NpRvSalesLine."Document No." := SalesLine."Document No.";
        NpRvSalesLine."Document Line No." := SalesLine."Line No.";
        NpRvSalesLine.Modify(true);

        EcomSalesDocImplEvents.OnInsertSalesLineVoucherBeforeFinalizeLine(EcomSalesHeader, SalesHeader, EcomSalesLine, SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure PopulateSalesLineDescriptionFromEcomSalesLine(EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line")
    begin
        if EcomSalesLine.Description = '' then
            exit;

        SalesLine.Description := CopyStr(EcomSalesLine.Description, 1, MaxStrLen(SalesLine.Description));
        if StrLen(EcomSalesLine.Description) > MaxStrLen(SalesLine.Description) then
            SalesLine."Description 2" := CopyStr(EcomSalesLine.Description, MaxStrLen(SalesLine.Description) + 1, MaxStrLen(SalesLine."Description 2"));
    end;

    local procedure PopulateSalesHeaderSellToNameFromEcomSalesHeader(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
        if EcomSalesHeader."Sell-to Name" = '' then
            exit;

        SalesHeader."Sell-to Customer Name" := CopyStr(EcomSalesHeader."Sell-to Name", 1, MaxStrLen(SalesHeader."Sell-to Customer Name"));
        if StrLen(EcomSalesHeader."Sell-to Name") > MaxStrLen(SalesHeader."Sell-to Customer Name") then
            SalesHeader."Sell-to Customer Name 2" := CopyStr(EcomSalesHeader."Sell-to Name", MaxStrLen(SalesHeader."Sell-to Customer Name") + 1, MaxStrLen(SalesHeader."Sell-to Customer Name 2"));
    end;

    local procedure PopulateSalesHeaderShipToNameFromEcomSalesHeader(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
        if EcomSalesHeader."Ship-to Name" = '' then
            exit;

        SalesHeader."Ship-to Name" := CopyStr(EcomSalesHeader."Ship-to Name", 1, MaxStrLen(SalesHeader."Ship-to Name"));
        if StrLen(EcomSalesHeader."Ship-to Name") > MaxStrLen(SalesHeader."Ship-to Name") then
            SalesHeader."Ship-to Name 2" := CopyStr(EcomSalesHeader."Ship-to Name", MaxStrLen(SalesHeader."Ship-to Name") + 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
    end;

    local procedure PopulateCustomerNameFromEcomSalesHeader(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Customer: Record Customer)
    begin
        if EcomSalesHeader."Sell-to Name" = '' then
            exit;

        Customer."Name" := CopyStr(EcomSalesHeader."Sell-to Name", 1, MaxStrLen(Customer."Name"));
        if StrLen(EcomSalesHeader."Sell-to Name") > MaxStrLen(Customer."Name") then
            Customer."Name 2" := CopyStr(EcomSalesHeader."Sell-to Name", MaxStrLen(Customer."Name") + 1, MaxStrLen(Customer."Name 2"));
    end;

    local procedure InsertSalesLineShipmentFeeAsComment(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesCommentLine: Record "Sales Comment Line")
    var
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        SalesCommentLine.Init();
        SalesCommentLine."Document Type" := SalesHeader."Document Type";
        SalesCommentLine."No." := SalesHeader."No.";
        SalesCommentLine."Document Line No." := 0;
        SalesCommentLine."Line No." := EcomSalesDocUtils.GetInternalSalesDocumentCommentLastLineNo(SalesHeader);
        SalesCommentLine.Date := Today();
        SalesCommentLine.Comment := CopyStr(EcomSalesLine.Description, 1, MaxStrLen(SalesCommentLine.Comment));
        EcomSalesDocImplEvents.OnInsertSalesLineShipmentFeeAsCommentBeforeFinalizeComment(EcomSalesHeader, SalesHeader, EcomSalesLine, SalesCommentLine);
        SalesCommentLine.Insert(true);
    end;

    local procedure InsertPaymentLines(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        EcomSalesPmtLine.Reset();
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if not EcomSalesPmtLine.FindSet() then
            exit;

        repeat
            Clear(PaymentLine);
            case EcomSalesPmtLine."Payment Method Type" of
                EcomSalesPmtLine."Payment Method Type"::"Payment Method":
                    InsertPaymentLinePaymentMethod(EcomSalesHeader, SalesHeader, EcomSalesPmtLine, PaymentLine);
                EcomSalesPmtLine."Payment Method Type"::Voucher:
                    InsertPaymentLineVoucher(EcomSalesHeader, SalesHeader, EcomSalesPmtLine, PaymentLine);
                else
                    EcomSalesPmtLine.FieldError("Payment Method Type");
            end;
        until EcomSalesPmtLine.Next() = 0;
    end;

    local procedure TransferCapturedPayments(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.Reset();
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesPmtLine.SetFilter("Captured Amount", '<>0');
        if not EcomSalesPmtLine.FindSet() then
            exit;

        repeat
            TransferCapturedPaymentLines(EcomSalesPmtLine, SalesHeader);
            if EcomSalesPmtLine."Payment Method Type" = EcomSalesPmtLine."Payment Method Type"::Voucher then
                TransferCapturedVoucherSalesLines(EcomSalesPmtLine, SalesHeader);
        until EcomSalesPmtLine.Next() = 0;
    end;

    local procedure InsertCommentLines(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        RecordLinkManagement: Codeunit "Record Link Management";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        RecordLinkManagement.CopyLinks(EcomSalesHeader, SalesHeader);
        //this event is here just for backwards compatability it should not be used
        IncEcomSalesDocImplEvents.OnAfterInsertCommentLines(IncEcomSalesHeader, SalesHeader);
        EcomSalesDocImplEvents.OnAfterInsertCommentLines(EcomSalesHeader, SalesHeader);
    end;

    local procedure InsertPaymentLinePaymentMethod(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        EcomSalesDocCrtImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        LoyaltyDiscountMngt: Codeunit "NPR NP Loyalty Discount Mgt";
        CardPaymentInstrumentTypeLbl: Label 'Card';
    begin
        if EcomSalesPmtLine."Payment Method Type" <> EcomSalesPmtLine."Payment Method Type"::"Payment Method" then
            exit;

        if EcomSalesPmtLine.Amount = 0 then
            exit;


        if EcomSalesPmtLine.Amount <= EcomSalesPmtLine."Captured Amount" then
            exit; // Payment already captured

        PaymentMapping.Reset();
        PaymentMapping.SetRange("External Payment Method Code", EcomSalesPmtLine."External Payment Method Code");
        PaymentMapping.SetRange("External Payment Type", EcomSalesPmtLine."External Payment Type");
        PaymentMapping.SetLoadFields("Allow Adjust Payment Amount", "Payment Gateway Code", "Payment Method Code", "Captured Externally");
        if not PaymentMapping.FindFirst() then begin
            PaymentMapping.SetRange("External Payment Type");
            PaymentMapping.FindFirst();
        end;

        PaymentMapping.TestField("Payment Method Code");
        PaymentMethod.Get(PaymentMapping."Payment Method Code");

        PaymentLine."Document Table No." := DATABASE::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := EcomSalesDocUtils.GetInternalSalesDocumentPaymentLastLineNo(SalesHeader) + 10000;
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + SalesHeader."NPR External Order No.", 1, MaxStrLen(PaymentLine.Description));
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine."Account Type" := PaymentMethod."Bal. Account Type";
        PaymentLine."Account No." := PaymentMethod."Bal. Account No.";
        PaymentLine."No." := CopyStr(EcomSalesPmtLine."Payment Reference", 1, MaxStrLen(PaymentLine."No."));
        PaymentLine."Transaction ID" := EcomSalesPmtLine."Payment Reference";
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"Payment Method";
        PaymentLine."Source No." := PaymentMethod.Code;
        PaymentLine.Amount := EcomSalesPmtLine.Amount - EcomSalesPmtLine."Captured Amount";
        PaymentLine."Requested Amount" := PaymentLine.Amount;
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := PaymentMapping."Payment Gateway Code";
        PaymentLine."Payment Gateway Shopper Ref." := EcomSalesPmtLine."PAR Token";
        PaymentLine."Payment Token" := EcomSalesPmtLine."PSP Token";
        PaymentLine."Expiry Date Text" := EcomSalesPmtLine."Card Expiry Date";
        PaymentLine.Brand := EcomSalesPmtLine."Card Brand";
        PaymentLine."Payment Instrument Type" := CopyStr(CardPaymentInstrumentTypeLbl, 1, MaxStrLen(PaymentLine."Payment Instrument Type"));
        PaymentLine."Masked PAN" := EcomSalesPmtLine."Masked Card Number";
#pragma warning disable AA0139
        if Strlen(PaymentLine."Masked PAN") >= 4 then
            PaymentLine."Card Summary" := CopyStr(PaymentLine."Masked PAN", Strlen(PaymentLine."Masked PAN") - 3)
        else
            PaymentLine."Card Summary" := PaymentLine."Masked PAN";
#pragma warning restore AA0139
        PaymentLine."Card Alias Token" := EcomSalesPmtLine."Card Alias Token";
        PaymentLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
        PaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        if PaymentMapping."Captured Externally" then
            PaymentLine."Date Captured" := GetDate(SalesHeader."Order Date", SalesHeader."Posting Date");

        if EcomSalesPmtLine."Points Payment" then
            PaymentLine."Points Payment" := true;

        if IsShopifyDocument then
            SpfyEcomSalesDocPrcssr.RefreshShopifyPaymentLinePaymentMethodFields(PaymentLine, EcomSalesHeader, EcomSalesPmtLine);

        EcomSalesDocCrtImplEvents.OnInsertPaymentLinePaymentMethodBeforeFinalizeLine(EcomSalesHeader, SalesHeader, EcomSalesPmtLine, PaymentLine);
        PaymentLine.Insert(true);

        if EcomSalesPmtLine."Points Payment" then
            LoyaltyDiscountMngt.CreateDiscountSalesLine(PaymentLine, SalesHeader);
    end;

    local procedure TransferCapturedPaymentLines(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        NewPaymentLine: Record "NPR Magento Payment Line";
        LoyaltyDiscountMngt: Codeunit "NPR NP Loyalty Discount Mgt";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"NPR Ecom Sales Header");
        PaymentLine.SetRange("Document No.", EcomSalesPmtLine."External Document No.");
        PaymentLine.SetRange("Document Type", EcomSalesPmtLine."Document Type");
        PaymentLine.SetRange("NPR Inc Ecom Sales Pmt Line Id", EcomSalesPmtLine.SystemId);
        if not PaymentLine.FindSet() then
            exit;

        repeat
            NewPaymentLine.Init();
            NewPaymentLine := PaymentLine;
            NewPaymentLine."Document Table No." := Database::"Sales Header";
            NewPaymentLine."Document Type" := SalesHeader."Document Type";
            NewPaymentLine."Document No." := SalesHeader."No.";
            NewPaymentLine.SystemId := PaymentLine.SystemId;
            If IsShopifyDocument then
                SpfyAssignedIDMgt.CopyAssignedShopifyID(PaymentLine.RecordId(), NewPaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID");
            PaymentLine.Delete();
            NewPaymentLine.Insert(false, true);
            if EcomSalesPmtLine."Points Payment" then
                LoyaltyDiscountMngt.CreateDiscountSalesLine(NewPaymentLine, SalesHeader);
        until PaymentLine.Next() = 0;
    end;

    local procedure TransferCapturedVoucherSalesLines(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; SalesHeader: Record "Sales Header")
    var
        VoucherSalesLine: Record "NPR NpRv Sales Line";
    begin
        VoucherSalesLine.Reset();
        VoucherSalesLine.SetRange("NPR Inc Ecom Sales Pmt Line Id", EcomSalesPmtLine.SystemId);
        if VoucherSalesLine.FindSet() then
            repeat
                VoucherSalesLine."Document Type" := SalesHeader."Document Type";
                VoucherSalesLine."Document No." := SalesHeader."No.";
                VoucherSalesLine.Modify(true);
            until VoucherSalesLine.Next() = 0;
    end;

    local procedure UpdateExtCouponReservations(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
    begin
        NpDcExtCouponReservation.Reset();
        NpDcExtCouponReservation.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpDcExtCouponReservation.SetRange("Document No.", '');
        if NpDcExtCouponReservation.IsEmpty then
            exit;

        NpDcExtCouponReservation.ModifyAll("Document Type", SalesHeader."Document Type");
        NpDcExtCouponReservation.ModifyAll("Document No.", SalesHeader."No.");

        EcomSalesDocImplEvents.OnAfterUpdateExtCouponReservations(EcomSalesHeader, SalesHeader);
    end;

    local procedure GetDate(Date1: Date; Date2: Date): Date
    begin
        if Date1 <> 0D then
            exit(Date1);
        if Date2 <> 0D then
            exit(Date2);
        exit(WorkDate());
    end;

    local procedure UpdateSaleDocumentPostingStatusFromSalesHeader(SalesHeader: Record "Sales Header")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SaleLine: Record "Sales Line";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
    begin
        if not EcomSalesHeader.GetBySystemId(SalesHeader."NPR Inc Ecom Sale Id") then
            exit;

        if EcomSalesHeader."API Version Date" <> GetApiVersion() then
            exit;

        SaleLine.Reset();
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.SetRange("Document No.", SalesHeader."No.");
        if SaleLine.IsEmpty then begin
            if EcomSalesHeader."Posting Status" <> EcomSalesHeader."Posting Status"::Invoiced then begin
                EcomSalesHeader."Posting Status" := EcomSalesHeader."Posting Status"::Invoiced;
                EcomSalesDocImplEvents.OnUpdateSalesDocumentPostingStatusFromSalesHeaderBeforeFinalizeUpdate(SalesHeader, EcomSalesHeader);
                EcomSalesHeader.Modify();
            end;
        end else begin
            if EcomSalesHeader."Posting Status" <> EcomSalesHeader."Posting Status"::"Partially Invoiced" then begin
                EcomSalesHeader."Posting Status" := EcomSalesHeader."Posting Status"::"Partially Invoiced";
                EcomSalesDocImplEvents.OnUpdateSalesDocumentPostingStatusFromSalesHeaderBeforeFinalizeUpdate(SalesHeader, EcomSalesHeader);
                EcomSalesHeader.Modify();
            end;
        end;

        SendWebhookPostedStatus(SalesHeader, EcomSalesHeader);
        EcomSalesDocImplEvents.OnAfterUpdateSalesDocumentPostingStatusFromSalesHeader(SalesHeader, EcomSalesHeader);

    end;

    local procedure UpdateSalesDocumentLinePostingInformationSalesInvoice(SalesInvLine: Record "Sales Invoice Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocCrtImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
    begin
        if not EcomSalesLine.GetBySystemId(SalesInvLine."NPR Inc Ecom Sales Line Id") then
            exit;

        EcomSalesHeader.SetLoadFields("Price Excl. VAT", "API Version Date");
        if not EcomSalesHeader.Get(EcomSalesLine."Document Entry No.") then
            exit;

        if (EcomSalesHeader."API Version Date" <> GetApiVersion()) then
            exit;

        EcomSalesLine."Invoiced Qty." += SalesInvLine.Quantity;
        if EcomSalesHeader."Price Excl. VAT" then
            EcomSalesLine."Invoiced Amount" += SalesInvLine.Amount
        else
            EcomSalesLine."Invoiced Amount" += SalesInvLine."Amount Including VAT";
        EcomSalesDocCrtImplEvents.OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesInvoice(SalesInvLine, EcomSalesHeader, EcomSalesLine);
        EcomSalesLine.Modify();
    end;

    local procedure UpdateSalesDocumentLinePostingInformationSalesCreditMemo(SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
    begin
        if not EcomSalesLine.GetBySystemId(SalesCrMemoLine."NPR Inc Ecom Sales Line Id") then
            exit;

        EcomSalesHeader.SetLoadFields("Price Excl. VAT", "API Version Date");
        if not EcomSalesHeader.Get(EcomSalesLine."Document Entry No.") then
            exit;

        if (EcomSalesHeader."API Version Date" <> GetApiVersion()) then
            exit;

        EcomSalesLine."Invoiced Qty." += SalesCrMemoLine.Quantity;
        if EcomSalesHeader."Price Excl. VAT" then
            EcomSalesLine."Invoiced Amount" += SalesCrMemoLine.Amount
        else
            EcomSalesLine."Invoiced Amount" += SalesCrMemoLine."Amount Including VAT";
        EcomSalesDocImplEvents.OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesCreditMemo(SalesCrMemoLine, EcomSalesHeader, EcomSalesLine);
        EcomSalesLine.Modify();
    end;

    local procedure CancelPointsPaymentLines(IncEcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        if IncEcomSalesHeader."Document Type" = IncEcomSalesHeader."Document Type"::Order then
            if not SalesHeader.Get(SalesHeader."Document Type"::Order, IncEcomSalesHeader."Created Doc No.") then
                exit;

        if IncEcomSalesHeader."Document Type" = IncEcomSalesHeader."Document Type"::"Return Order" then
            if not SalesHeader.Get(SalesHeader."Document Type"::"Return Order", IncEcomSalesHeader."Created Doc No.") then
                exit;

        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        if PaymentLine.FindSet() then
            repeat
                CancelPointsPaymentLine(PaymentLine);
            until PaymentLine.Next() = 0;
    end;

    local procedure CancelPointsPaymentLine(PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        MagentpPmtMngt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        if PaymentLine."Payment Gateway Code" = '' then
            exit;

        if not PaymentGateway.Get(PaymentLine."Payment Gateway Code") then
            exit;

        if PaymentGateway."Integration Type" <> PaymentGateway."Integration Type"::NPLoyalty_Discount then
            exit;

        MagentpPmtMngt.CancelPaymentLine(PaymentLine);
    end;

    local procedure InsertPaymentLineVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; PaymentLine: Record "NPR Magento Payment Line")
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMngt: Codeunit "NPR NpRv Voucher Mgt.";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        AvailableAmount: Decimal;
        AvailableAmountLCY: Decimal;
        PaymentAmountLCY: Decimal;
        AmountValidated: Boolean;
        Precalculated: Boolean;
        VoucherPaymentAmountError: Label 'Voucher payment amount %1 %2 exceeds available voucher amount %3.', Comment = '%1 - Payment amount, %2 - Payment currency code, %3 - Voucher available amount in payment currency';
    begin
        if EcomSalesPmtLine."Payment Method Type" <> EcomSalesPmtLine."Payment Method Type"::Voucher then
            exit;

        if EcomSalesPmtLine.Amount = 0 then
            exit;


        if EcomSalesPmtLine."Captured Amount" >= EcomSalesPmtLine.Amount then
            exit; // Payment already captured

        EcomVirtualItemMgt.FindVoucher(EcomSalesPmtLine, NpRvVoucher);

        NpRvSalesLine.Reset();
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
        NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange("Document Line No.", 0);
        if not NpRvSalesLine.FindFirst() then begin
            NpRvSalesLine.Init();
            NpRvSalesLine.Id := CreateGuid();
            NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
            NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
            NpRvSalesLine."Document Type" := SalesHeader."Document Type";
            NpRvSalesLine."Document No." := SalesHeader."No.";
            NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
            NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
            NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
            NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
            NpRvSalesLine.Description := NpRvVoucher.Description;
            NpRvSalesLine.Insert(true);
        end;

        PaymentLine.Init();
        PaymentLine."Document Table No." := DATABASE::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := EcomSalesDocUtils.GetInternalSalesDocumentPaymentLastLineNo(SalesHeader) + 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::Voucher;
        PaymentLine.Description := NpRvVoucher.Description;
        PaymentLine."Account No." := NpRvVoucher."Account No.";
        PaymentLine."No." := NpRvVoucher."Reference No.";
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"NPR NpRv Voucher";
        PaymentLine."Source No." := NpRvVoucher."No.";
        PaymentLine.Amount := EcomSalesPmtLine.Amount - EcomSalesPmtLine."Captured Amount";
        PaymentLine."NPR Inc Ecom Sales Pmt Line Id" := EcomSalesPmtLine.SystemId;
        PaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        if IsShopifyDocument then
            SpfyEcomSalesDocPrcssr.RefreshShopifyPaymentLineVoucherFields(PaymentLine, EcomSalesHeader, EcomSalesPmtLine, EcomSalesPmtLine.Amount);
        PaymentLine.Insert();

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Type" := SalesHeader."Document Type";
        NpRvSalesLine."Document No." := SalesHeader."No.";
        NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
        NpRvSalesLine.Amount := PaymentLine.Amount;
        NpRvSalesLine."Reservation Line Id" := PaymentLine.SystemId;
        if IsShopifyDocument then
            SpfyEcomSalesDocPrcssr.RefreshShopifyPaymentLineVoucherSalesLineFields(NpRvSalesLine);
        NpRvSalesLine.Modify(true);

        PaymentAmountLCY := NpRvSalesDocMgt.ConvertTransactionCurrencyAmtToLCY(PaymentLine.Amount, SalesHeader."Currency Code", SalesHeader."Currency Factor", SalesHeader."Posting Date", Precalculated);
        AmountValidated := NpRvVoucherMngt.ValidateAmount(NpRvVoucher, PaymentLine.SystemId, PaymentAmountLCY, AvailableAmountLCY);
        if not AmountValidated and not Precalculated then
            AmountValidated := Abs(AvailableAmountLCY - PaymentAmountLCY) <= NpRvVoucherMngt.AllowedCurrencyConversionRoundingDifference(); //Allow small rounding difference when the LCY voucher payment amount is calculated from the transaction FCY amount
        if not AmountValidated then begin
            AvailableAmount := NpRvSalesDocMgt.ConvertLCYAmtToTransactionCurrency(AvailableAmountLCY, SalesHeader."Currency Code", SalesHeader."Currency Factor");
            Error(VoucherPaymentAmountError, PaymentLine.Amount, NpRvSalesDocMgt.AdjustCurrencyCode(SalesHeader."Currency Code"), AvailableAmount);
        end;

        EcomSalesDocImplEvents.OnAfterInsertPaymentLineVoucher(EcomSalesHeader, SalesHeader, EcomSalesPmtLine, PaymentLine, NpRvSalesLine);
    end;

    internal procedure UpdateSalesDocumentPaymentLinePostingInformation(PaymentLine: Record "NPR Magento Payment Line")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
    begin
        if not EcomSalesPmtLine.GetBySystemId(PaymentLine."NPR Inc Ecom Sales Pmt Line Id") then
            exit;

        EcomSalesPmtLine."Invoiced Amount" += PaymentLine.Amount;
        EcomSalesDocImplEvents.OnUpdateSalesDocumentPaymentLinePostingInformationBeforeFinalizeRecord(PaymentLine, EcomSalesPmtLine);
        EcomSalesPmtLine.Modify();
    end;

    internal procedure UpdateSalesDocumentPaymentLineCaptureInformation(PaymentLine: Record "NPR Magento Payment Line")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
    begin
        if not EcomSalesPmtLine.GetBySystemId(PaymentLine."NPR Inc Ecom Sales Pmt Line Id") then
            exit;

        EcomSalesPmtLine."Captured Amount" += PaymentLine.Amount;
        EcomSalesDocImplEvents.OnUpdateSalesDocumentPaymentLineCaptureInformationBeforeFinalizeRecord(PaymentLine, EcomSalesPmtLine);
        EcomSalesPmtLine.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesLine', '', true, false)]
    local procedure OnAfterPostSalesLine(var SalesInvLine: Record "Sales Invoice Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        UpdateSalesDocumentLinePostingInformationSalesInvoice(SalesInvLine);
        UpdateSalesDocumentLinePostingInformationSalesCreditMemo(SalesCrMemoLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePosting', '', true, false)]
    local procedure OnAfterFinalizePosting(var SalesHeader: Record "Sales Header")
    begin
        UpdateSaleDocumentPostingStatusFromSalesHeader(SalesHeader)
    end;

    local procedure SendWebhookPostedStatus(SalesHeader: Record "Sales Header"; EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        IncEcomSalesWebhook: Codeunit "NPR Inc Ecom Sales Webhooks";
        PostedStatusText: Text[50];
    begin
        // Only handle actual posting statuses, exclude pending
        if not (EcomSalesHeader."Posting Status" in [
            EcomSalesHeader."Posting Status"::"Partially Invoiced",
            EcomSalesHeader."Posting Status"::Invoiced]) then
            exit;

        // Determine posted status text
        if EcomSalesHeader."Posting Status" = EcomSalesHeader."Posting Status"::Invoiced then
            PostedStatusText := 'fullyInvoiced'
        else
            PostedStatusText := 'partiallyInvoiced';

        // Call appropriate webhook based on document type
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                IncEcomSalesWebhook.OnSalesOrderPosted(
                    SalesHeader.SystemId,
                    SalesHeader."External Document No.",
                    SalesHeader."NPR External Order No.",
                    SalesHeader."NPR Inc Ecom Sale Id",
                    PostedStatusText);
            SalesHeader."Document Type"::"Return Order":
                IncEcomSalesWebhook.OnSalesReturnOrderPosted(
                    SalesHeader.SystemId,
                    SalesHeader."External Document No.",
                    SalesHeader."NPR External Order No.",
                    SalesHeader."NPR Inc Ecom Sale Id",
                    PostedStatusText);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteSalesHeader(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        SalesInvoice: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        IncEcomSalesWebhook: Codeunit "NPR Inc Ecom Sales Webhooks";
        IsPosted: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;

        if IsNullGuid(Rec."NPR Inc Ecom Sale Id") then
            exit;

        if not EcomSalesHeader.GetBySystemId(Rec."NPR Inc Ecom Sale Id") then
            exit;

        if EcomSalesHeader."API Version Date" <> GetApiVersion() then
            exit;

        // Check if the document was already posted to avoid triggering cancellation during posting
        case Rec."Document Type" of
            Rec."Document Type"::Order:
                begin
                    SalesInvoice.SetRange("NPR Inc Ecom Sale Id", Rec."NPR Inc Ecom Sale Id");
                    SalesInvoice.SetRange("Order No.", Rec."No.");
                    IsPosted := not SalesInvoice.IsEmpty();
                end;
            Rec."Document Type"::"Return Order":
                begin
                    SalesCrMemoHeader.SetRange("NPR Inc Ecom Sale Id", Rec."NPR Inc Ecom Sale Id");
                    SalesCrMemoHeader.SetRange("Return Order No.", Rec."No.");
                    IsPosted := not SalesCrMemoHeader.IsEmpty();
                end;
        end;

        if IsPosted then
            exit;

        CancelPointsPaymentLines(EcomSalesHeader);

        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Canceled;
        EcomSalesHeader.Modify(true);

        // Call appropriate webhook based on document type
        case Rec."Document Type" of
            Rec."Document Type"::Order:
                IncEcomSalesWebhook.OnSalesOrderCancelled(Rec.SystemId, Rec."External Document No.", Rec."NPR External Order No.", Rec."NPR Inc Ecom Sale Id");
            Rec."Document Type"::"Return Order":
                IncEcomSalesWebhook.OnSalesReturnOrderCancelled(Rec.SystemId, Rec."External Document No.", Rec."NPR External Order No.", Rec."NPR Inc Ecom Sale Id");
        end;
    end;

    local procedure UpdateCustomerFromTemplates(var Customer: Record Customer; CustomerTemplateCode: Code[20]; ConfigTemplateCode: Code[10])
    var
        CustomerTemplate: Record "Customer Templ.";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin
        if CustomerTemplateCode <> '' then begin
            if CustomerTemplate.Get(CustomerTemplateCode) then begin
                Customer.CopyFromNewCustomerTemplate(CustomerTemplate);
                Customer.Modify(true);
            end;
        end else if ConfigTemplateCode <> '' then begin
            if ConfigTemplateHeader.Get(ConfigTemplateCode) then begin
                RecRef.GetTable(Customer);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                RecRef.SetTable(Customer);
                Customer.Modify(true);
            end;
        end;
    end;

    local procedure CheckIfDocumentCanBeProcessed(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        Handled: Boolean;
        UnprocessedVirtualItemsErrorLbl: Label 'There is unprocessed virtual item on %1. Type: %2, no.: %3', Comment = '%1 - recordid, %2 - virtual item type, $3 - virtual item no.';
        CreatedDocumentErrorLbl: Label 'Sales document %1 has already been created from ecom document %2.', Comment = '%1 - sales document record id, %2 - ecom document record id';
    begin
        EcomSalesDocImplEvents.OnBeforeCheckIfDocumentCanBeProcessed(EcomSalesHeader, Handled);
        if Handled then
            exit;

        if EcomSalesHeader."Creation Status" = EcomSalesHeader."Creation Status"::Created then
            EcomSalesHeader.FieldError("Creation Status");

        SalesHeader.Reset();
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        if not SalesHeader.IsEmpty then
            Error(CreatedDocumentErrorLbl, SalesHeader.RecordId, EcomSalesHeader.RecordId);

        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        if not SalesInvoiceHeader.IsEmpty then
            Error(CreatedDocumentErrorLbl, SalesInvoiceHeader.RecordId, EcomSalesHeader.RecordId);

        SalesCrMemoHeader.Reset();
        SalesCrMemoHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        if not SalesCrMemoHeader.IsEmpty then
            Error(CreatedDocumentErrorLbl, SalesCrMemoHeader.RecordId, EcomSalesHeader.RecordId);

        if IsShopifyDocument then
            SpfyEcomSalesDocPrcssr.IsSalesDocumentCreated(EcomSalesHeader);

        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetFilter(Type, '%1', EcomSalesLine.Type::Voucher);
        if EcomSalesLine.IsEmpty then
            exit;

        EcomSalesLine.SetFilter("Virtual Item Process Status", '%1|%2', EcomSalesLine."Virtual Item Process Status"::Error, EcomSalesLine."Virtual Item Process Status"::" ");
        if EcomSalesLine.FindFirst() then
            Error(UnprocessedVirtualItemsErrorLbl, EcomSalesLine.RecordId, EcomSalesLine.Type, EcomSalesLine."No.");

        EcomSalesDocImplEvents.OnAfterCheckIfDocumentCanBeProcessed(EcomSalesHeader);
    end;

    internal procedure PostEcomSalesDoc(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header") Success: Boolean;
    var
        EcomSalesDocPost: Codeunit "NPR Ecom Sales Doc Post";
        EcomSalesDocImplEvents: Codeunit "NPR EcomSalesDocImplEvents";
        Handled: Boolean;
    begin
        EcomSalesDocImplEvents.OnBeforePostEcomSalesDoc(EcomSalesHeader, SalesHeader, Handled);
        if Handled then
            exit;

        if not EcomSalesHeader."Virtual Items Exist" then
            exit;

        if EcomSalesHeader."Creation Status" <> EcomSalesHeader."Creation Status"::Created then
            exit;

        Commit();
        Clear(EcomSalesDocPost);
        Success := EcomSalesDocPost.Run(EcomSalesHeader);
    end;

    internal procedure GetApiVersion(): Date
    begin
        exit(20251019D);
    end;
}
#endif
