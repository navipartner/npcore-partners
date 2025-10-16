#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248588 "NPR Inc Ecom Sales Doc Impl V2"
{
    Access = Internal;

    var
        CustomerModeCreationErrorLbl: Label 'Customer Create is not allowed when Customer Update Mode is %1';

    procedure Process(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") Success: Boolean
    var
        SalesHeader: Record "Sales Header";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        IncEcomSalesWebhook: Codeunit "NPR Inc Ecom Sales Webhooks";
    begin
        if IncEcomSalesHeader."Creation Status" = IncEcomSalesHeader."Creation Status"::Created then
            exit;

        IncEcomSalesHeader."Creation Status" := IncEcomSalesHeader."Creation Status"::Created;
        IncEcomSalesHeader.Modify();

        InsertSalesDocument(IncEcomSalesHeader, SalesHeader);
        Commit();

        Success := true;

        case IncEcomSalesHeader."Document Type" of
            IncEcomSalesHeader."Document Type"::Order:
                IncEcomSalesWebhook.OnSalesOrderCreated(SalesHeader.SystemId, SalesHeader."External Document No.", SalesHeader."NPR External Order No.", SalesHeader."NPR Inc Ecom Sale Id");
            IncEcomSalesHeader."Document Type"::"Return Order":
                IncEcomSalesWebhook.OnSalesReturnOrderCreated(SalesHeader.SystemId, SalesHeader."External Document No.", SalesHeader."NPR External Order No.", SalesHeader."NPR Inc Ecom Sale Id");
        end;

        IncEcomSalesDocImplEvents.OnAfterProcess(IncEcomSalesHeader, Success);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure InsertSalesDocument(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header") Success: Boolean
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        InsertSalesHeader(IncEcomSalesHeader, SalesHeader);
        InsertSalesLines(IncEcomSalesHeader, SalesHeader);
        InsertPaymentLines(IncEcomSalesHeader, SalesHeader);
        InsertCommentLines(IncEcomSalesHeader, SalesHeader);
        if IncEcomSalesHeader."Document Type" = IncEcomSalesHeader."Document Type"::Order then
            UpdateExtCouponReservations(IncEcomSalesHeader, SalesHeader);

        IncEcomSalesDocImplEvents.OnProcessBeforeRelease(IncEcomSalesHeader, SalesHeader);

        if (IncEcomSalesDocSetup."Release Sale Ord After Prc" and (SalesHeader."Document Type" = SalesHeader."Document Type"::Order)) or
           (IncEcomSalesDocSetup."Release Sale Ret Ord After Prc" and (SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order"))
        then
            ReleaseSalesDoc.PerformManualRelease(SalesHeader);

        Success := true;

        IncEcomSalesDocImplEvents.OnAfterInsertSalesDocument(IncEcomSalesHeader, SalesHeader, Success)
    end;

    local procedure InsertSalesHeader(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header");
    var
        Customer: Record Customer;
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
        LocationCode: Code[10];
        RecordRef: RecordRef;
        PaymentMethodCodeUpdated: Boolean;
    begin
        InsertCustomer(IncEcomSalesHeader, Customer);

        SalesHeader.Init();
        case IncEcomSalesHeader."Document Type" of
            IncEcomSalesHeader."Document Type"::Order:
                SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
            IncEcomSalesHeader."Document Type"::"Return Order":
                SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        end;

        SalesHeader."No." := '';


        SalesHeader."NPR External Order No." := IncEcomSalesHeader."External No.";
        SalesHeader."External Document No." := IncEcomSalesHeader."External Document No.";
        if SalesHeader."External Document No." = '' then
            SalesHeader."External Document No." := SalesHeader."NPR External Order No.";

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            SalesHeader."Your Reference" := IncEcomSalesHeader."Your Reference";
        IncEcomSalesDocImplEvents.OnAfterPopulateGeneralSalesHeaderInformation(IncEcomSalesHeader, SalesHeader);
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        PopulateSalesHeaderSellToNameFromEcomSalesHeader(IncEcomSalesHeader, SalesHeader);
        SalesHeader."Sell-to Address" := IncEcomSalesHeader."Sell-to Address";
        SalesHeader."Sell-to Address 2" := IncEcomSalesHeader."Sell-to Address 2";
        SalesHeader."Sell-to Post Code" := IncEcomSalesHeader."Sell-to Post Code";
        SalesHeader."Sell-to County" := IncEcomSalesHeader."Sell-to County";
        SalesHeader."Sell-to City" := IncEcomSalesHeader."Sell-to City";
        SalesHeader."Sell-to Country/Region Code" := IncEcomSalesHeader."Sell-to Country Code";
        SalesHeader."Sell-to Contact" := IncEcomSalesHeader."Sell-to Contact";

        SalesHeader."Sell-to Phone No." := IncEcomSalesHeader."Sell-to Phone No.";

        RecordRef.GetTable(SalesHeader);

        //"OIOUBL-Sell-to Contact Phone No."
        SetFieldText(RecordRef, 13635, IncEcomSalesHeader."Sell-to Phone No.");
        //"OIOUBL-Sell-to Contact E-Mail"
        SetFieldText(RecordRef, 13637, IncEcomSalesHeader."Sell-to Email");
        //"OIOUBL-GLN"
        SetFieldText(RecordRef, 13630, IncEcomSalesHeader."Sell-to EAN");
        RecordRef.SetTable(SalesHeader);

        SalesHeader."NPR Bill-to E-mail" := IncEcomSalesHeader."Sell-to Invoice Email";

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
        SalesHeader."NPR Bill-to E-mail" := IncEcomSalesHeader."Sell-to Email";
        SalesHeader."Ship-to Name" := SalesHeader."Sell-to Customer Name";
        SalesHeader."Ship-to Name 2" := SalesHeader."Sell-to Customer Name 2";
        SalesHeader."Ship-to Address" := SalesHeader."Sell-to Address";
        SalesHeader."Ship-to Address 2" := SalesHeader."Sell-to Address 2";
        SalesHeader."Ship-to Post Code" := SalesHeader."Sell-to Post Code";
        SalesHeader."Ship-to City" := SalesHeader."Sell-to City";
        SalesHeader."Ship-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";
        SalesHeader."Ship-to Contact" := SalesHeader."Sell-to Contact";
        SalesHeader."Ship-to County" := SalesHeader."Sell-to County";


        SalesHeader."Prices Including VAT" := not IncEcomSalesHeader."Price Excl. VAT";

        if IncomingSalesHeaderHasShipmentInformation(IncEcomSalesHeader) then begin
            PopulateSalesHeaderShipToNameFromEcomSalesHeader(IncEcomSalesHeader, SalesHeader);
            SalesHeader."Ship-to Address" := IncEcomSalesHeader."Ship-to Address";
            SalesHeader."Ship-to Address 2" := IncEcomSalesHeader."Ship-to Address 2";
            SalesHeader."Ship-to Post Code" := IncEcomSalesHeader."Ship-to Post Code";
            SalesHeader."Ship-to County" := IncEcomSalesHeader."Ship-to County";
            SalesHeader."Ship-to City" := IncEcomSalesHeader."Ship-to City";
            SalesHeader."Ship-to Country/Region Code" := IncEcomSalesHeader."Ship-to Country Code";
            SalesHeader."Ship-to Contact" := IncEcomSalesHeader."Ship-to Contact";
        end else begin
            SalesHeader."Ship-to Name" := SalesHeader."Sell-to Customer Name";
            SalesHeader."Ship-to Name 2" := SalesHeader."Sell-to Customer Name 2";
            SalesHeader."Ship-to Address" := IncEcomSalesHeader."Sell-to Address";
            SalesHeader."Ship-to Address 2" := IncEcomSalesHeader."Sell-to Address 2";
            SalesHeader."Ship-to Post Code" := IncEcomSalesHeader."Sell-to Post Code";
            SalesHeader."Ship-to County" := IncEcomSalesHeader."Sell-to County";
            SalesHeader."Ship-to City" := IncEcomSalesHeader."Sell-to City";
            SalesHeader."Ship-to Country/Region Code" := IncEcomSalesHeader."Sell-to Country Code";
            SalesHeader."Ship-to Contact" := IncEcomSalesHeader."Sell-to Contact";
        end;

        SalesHeader.Validate("Salesperson Code", Customer."Salesperson Code");

        LocationCode := IncEcomSalesDocUtils.GetSalesLocationCode(IncEcomSalesHeader);
        if LocationCode <> '' then
            SalesHeader.Validate("Location Code", LocationCode);

        if IncEcomSalesHeader."Shipment Method Code" <> '' then begin
            ShipmentMapping.SetRange("External Shipment Method Code", IncEcomSalesHeader."Shipment Method Code");
            ShipmentMapping.FindFirst();

            SalesHeader.Validate("Shipment Method Code", ShipmentMapping."Shipment Method Code");
            SalesHeader.Validate("Shipping Agent Code", ShipmentMapping."Shipping Agent Code");
            SalesHeader.Validate("Shipping Agent Service Code", ShipmentMapping."Shipping Agent Service Code");
            SalesHeader."NPR Delivery Location" := IncEcomSalesHeader."Shipment Service";
        end;

        if SalesHeader."Payment Method Code" = '' then begin
            Clear(PaymentMethodCodeUpdated);

            IncEcomSalesPmtLine.Reset();
            IncEcomSalesPmtLine.SetRange("External Document No.", IncEcomSalesHeader."External No.");
            IncEcomSalesPmtLine.SetRange("Document Type", IncEcomSalesHeader."Document Type");
            IncEcomSalesPmtLine.SetRange("Payment Method Type", IncEcomSalesPmtLine."Payment Method Type"::"Payment Method");
            IncEcomSalesPmtLine.SetLoadFields("External Payment Method Code", "External Paymment Type");
            if IncEcomSalesPmtLine.FindSet() then
                repeat
                    PaymentMapping.Reset();
                    PaymentMapping.SetRange("External Payment Method Code", IncEcomSalesPmtLine."External Payment Method Code");
                    PaymentMapping.SetRange("External Payment Type", IncEcomSalesPmtLine."External Paymment Type");
                    if not PaymentMapping.FindFirst() then begin
                        PaymentMapping.SetRange("External Payment Type");
                        PaymentMapping.FindFirst();
                    end;
                    if (PaymentMapping."Payment Method Code" <> '') then begin
                        SalesHeader.Validate("Payment Method Code", PaymentMapping."Payment Method Code");
                        PaymentMethodCodeUpdated := true;
                    end;
                until (IncEcomSalesPmtLine.Next() = 0) or PaymentMethodCodeUpdated;

        end;

        SalesHeader.Validate("Currency Code", IncEcomSalesHeader."Currency Code");
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            if SalesHeader."Currency Code" <> '' then begin
                if IncEcomSalesHeader."Currency Exchange Rate" > 0 then
                    SalesHeader.Validate("Currency Factor", IncEcomSalesHeader."Currency Exchange Rate");
            end;
        SalesHeader."NPR Inc Ecom Sale Id" := IncEcomSalesHeader.SystemId;
        IncEcomSalesDocImplEvents.OnInsertSalesHeaderBeforeFinalizeSalesHeader(IncEcomSalesHeader, SalesHeader);
        SalesHeader.Modify(true);

        IncEcomSalesHeader."Created Doc No." := SalesHeader."No.";
        IncEcomSalesHeader.Modify(true);

        IncEcomSalesDocImplEvents.OnAfterInsertSalesHeader(IncEcomSalesHeader, SalesHeader);
    end;

    local procedure InsertCustomer(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var Customer: Record Customer) Success: Boolean
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        UpdateContFromCust: Codeunit "CustCont-Update";
        NewCustomer: Boolean;
        CustomerUpdateHandled: Boolean;
        ConfigTemplateCode: Code[10];
        CustomerTemplateCode: Code[20];
        VATBusPostingGroupCode: Code[20];
    begin
        if not IncEcomSalesDocSetup.Get() then
            Clear(IncEcomSalesDocSetup);

        if GetContactCustomer(IncEcomSalesHeader."Sell-to Customer No.", Customer) then
            exit;

        NewCustomer := not GetCustomer(IncEcomSalesHeader, Customer);

        IncEcomSalesDocImplEvents.OnAfterDecideNewCustomer(IncEcomSalesHeader, Customer, NewCustomer);

        IncEcomSalesDocUtils.GetCustomerTemplateAndConfigCode(IncEcomSalesHeader, CustomerTemplateCode, ConfigTemplateCode);

        if NewCustomer then begin
            if not (IncEcomSalesDocSetup."Customer Update Mode" in [IncEcomSalesDocSetup."Customer Update Mode"::"Create and Update", IncEcomSalesDocSetup."Customer Update Mode"::Create]) then
                Error(CustomerModeCreationErrorLbl, IncEcomSalesDocSetup."Customer Update Mode");


            InitCustomer(IncEcomSalesHeader, Customer);

            Customer."NPR External Customer No." := IncEcomSalesHeader."Sell-to Customer No.";
            Customer.Insert(true);

            Customer."Post Code" := IncEcomSalesHeader."Sell-to Post Code";
            Customer."Country/Region Code" := IncEcomSalesHeader."Sell-to Country Code";

            UpdateCustomerFromTemplates(Customer, CustomerTemplateCode, ConfigTemplateCode);
        end;

        IncEcomSalesDocImplEvents.OnBeforeHandleCustomerUpdateMode(IncEcomSalesHeader, CustomerTemplateCode, VATBusPostingGroupCode, IncEcomSalesDocSetup, Customer, NewCustomer, CustomerUpdateHandled);

        if not CustomerUpdateHandled then
            case IncEcomSalesDocSetup."Customer Update Mode" of
                IncEcomSalesDocSetup."Customer Update Mode"::Create:
                    if not NewCustomer then
                        exit;
                IncEcomSalesDocSetup."Customer Update Mode"::None:
                    exit;
            end;

        Customer."Post Code" := IncEcomSalesHeader."Sell-to Post Code";
        Customer."Country/Region Code" := IncEcomSalesHeader."Sell-to Country Code";

        if (not NewCustomer) and (IncEcomSalesDocSetup."Customer Update Mode" in [IncEcomSalesDocSetup."Customer Update Mode"::"Create and Update", IncEcomSalesDocSetup."Customer Update Mode"::Update]) then
            UpdateCustomerFromTemplates(Customer, CustomerTemplateCode, ConfigTemplateCode);

        PopulateCustomerNameFromEcomSalesHeader(IncEcomSalesHeader, Customer);
        Customer.Address := IncEcomSalesHeader."Sell-to Address";
        Customer."Address 2" := IncEcomSalesHeader."Sell-to Address 2";
        Customer."Post Code" := IncEcomSalesHeader."Sell-to Post Code";
        Customer.County := IncEcomSalesHeader."Sell-to County";
        Customer.City := IncEcomSalesHeader."Sell-to City";
        Customer."Country/Region Code" := IncEcomSalesHeader."Sell-to Country Code";
        Customer.Contact := IncEcomSalesHeader."Sell-to Contact";
        Customer."E-Mail" := IncEcomSalesHeader."Sell-to Email";
        Customer."Phone No." := IncEcomSalesHeader."Sell-to Phone No.";
        Customer.GLN := IncEcomSalesHeader."Sell-to EAN";
        if Customer.GLN <> '' then begin
            if Customer.Contact = '' then
                Customer.Contact := 'X';
        end;

        Customer."VAT Registration No." := IncEcomSalesHeader."Sell-to VAT Registration No.";
        Customer."Prices Including VAT" := not IncEcomSalesHeader."Price Excl. VAT";

        IncEcomSalesDocImplEvents.OnInsertCustomerBeforeFinalizeCustomer(IncEcomSalesHeader, NewCustomer, Customer);
        Customer.Modify(true);

        UpdateContFromCust.OnModify(Customer);

        Success := true;
    end;

    local procedure InitCustomer(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var Customer: Record Customer)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        Customer.Init();
        Customer."No." := '';
        case IncEcomSalesDocSetup."Customer Mapping" of
            IncEcomSalesDocSetup."Customer Mapping"::"Customer No.":
                Customer."No." := IncEcomSalesHeader."Sell-to Customer No.";
            IncEcomSalesDocSetup."Customer Mapping"::"Phone No. to Customer No.":
                Customer."No." := IncEcomSalesHeader."Sell-to Phone No.";
        end;

        IncEcomSalesDocImplEvents.OnAfterInitCustomer(IncEcomSalesHeader, Customer);
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

    local procedure GetCustomer(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var Customer: Record Customer) Found: Boolean
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        Clear(Customer);

        case IncEcomSalesDocSetup."Customer Mapping" of
            IncEcomSalesDocSetup."Customer Mapping"::"E-mail":
                begin
                    Customer.SetRange("E-Mail", IncEcomSalesHeader."Sell-to Email");
                    Found := Customer.FindFirst() and (Customer."E-Mail" <> '');
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"Phone No.":
                begin
                    Customer.SetRange("Phone No.", IncEcomSalesHeader."Sell-to Phone No.");
                    Found := Customer.FindFirst() and (Customer."Phone No." <> '');
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"E-mail AND Phone No.":
                begin
                    Customer.SetRange("E-Mail", IncEcomSalesHeader."Sell-to Email");
                    Customer.SetRange("Phone No.", IncEcomSalesHeader."Sell-to Phone No.");
                    Found := Customer.FindFirst() and (Customer."E-Mail" <> '') and (Customer."Phone No." <> '');
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"E-mail OR Phone No.":
                begin
                    Customer.SetRange("E-Mail", IncEcomSalesHeader."Sell-to Email");
                    Found := Customer.FindFirst() and (Customer."E-Mail" <> '');
                    if Found then
                        exit;

                    Customer.SetRange("E-Mail");
                    Customer.SetRange("Phone No.", IncEcomSalesHeader."Sell-to Phone No.");
                    Found := Customer.FindFirst() and (Customer."Phone No." <> '');
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"Customer No.":
                begin
                    if IncEcomSalesHeader."Sell-to Customer No." = '' then
                        exit;
                    Found := Customer.Get(IncEcomSalesHeader."Sell-to Customer No.");
                end;
            IncEcomSalesDocSetup."Customer Mapping"::"Phone No. to Customer No.":
                begin
                    if IncEcomSalesHeader."Sell-to Phone No." = '' then
                        exit;
                    Found := Customer.Get(IncEcomSalesHeader."Sell-to Phone No.");
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

    local procedure IncomingSalesHeaderHasShipmentInformation(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header") HasShipmentInformation: Boolean
    var
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        HasShipmentInformation := (IncomingSalesHeader."Ship-to Address" <> '') or
                                  (IncomingSalesHeader."Ship-to Address 2" <> '') or
                                  (IncomingSalesHeader."Ship-to City" <> '') or
                                  (IncomingSalesHeader."Ship-to Contact" <> '') or
                                  (IncomingSalesHeader."Ship-to Country Code" <> '') or
                                  (IncomingSalesHeader."Ship-to County" <> '') or
                                  (IncomingSalesHeader."Ship-to Name" <> '') or
                                  (IncomingSalesHeader."Ship-to Post Code" <> '');

        IncEcomSalesDocImplEvents.OnAfterIncomingSalesHeaderHasShipmentInformation(IncomingSalesHeader, HasShipmentInformation);
    end;


    local procedure InsertSalesLines(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
        SaleLine: Record "Sales Line";
    begin
        IncEcomSalesLine.Reset();
        IncEcomSalesLine.SetRange("External Document No.", IncomingSalesHeader."External No.");
        IncEcomSalesLine.SetRange("Document Type", IncomingSalesHeader."Document Type");
        if not IncEcomSalesLine.FindSet() then
            exit;

        repeat
            Clear(SaleLine);
            case IncEcomSalesLine.Type of
                IncEcomSalesLine.Type::Item:
                    InsertSalesLineItem(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SaleLine);
                IncEcomSalesLine.Type::Comment:
                    InsertSalesLineComment(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SaleLine);
                IncEcomSalesLine.Type::"Shipment Fee":
                    InsertSalesLineShipmentFee(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SaleLine);
            end;
        until IncEcomSalesLine.Next() = 0;

    end;

    local procedure InsertSalesLineItem(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLine: Record "Sales Line")
    var
        ItemVariant: Record "Item Variant";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ItemDoesntExistErrorLbl: Label 'Item %1 in %2 does not exist.', Comment = '%1 - external no., %2 - inc sales line record id';
    begin
        if IncEcomSalesLine.Type <> IncEcomSalesLine.Type::Item then
            exit;

        if not IncEcomSalesDocUtils.GetItemNoAndVariantNoFromEcomSalesLine(IncEcomSalesLine, ItemNo, VariantCode) then
            Error(ItemDoesntExistErrorLbl, IncEcomSalesLine."No.", Format(IncEcomSalesLine.RecordId));

        if not ItemVariant.Get(ItemNo, VariantCode) then
            Clear(ItemVariant);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := IncEcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        PopulateSalesLineDescriptionFromEcomSalesLine(IncEcomSalesLine, SalesLine);

        SalesLine."Variant Code" := VariantCode;
        if (VariantCode <> '') and (SalesLine."Description 2" = '') then
            SalesLine."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(SalesLine."Description 2"));

        if SalesHeader."Location Code" <> '' then
            SalesLine.Validate("Location Code", SalesHeader."Location Code");
        SalesLine.Validate(Quantity, IncEcomSalesLine.Quantity);

        if IncomingSalesHeader."Document Type" = IncomingSalesHeader."Document Type"::Order then
            if IncEcomSalesLine."Requested Delivery Date" <> 0D then
                SalesLine.Validate("Requested Delivery Date", IncEcomSalesLine."Requested Delivery Date");

        if IncEcomSalesLine."Unit of Measure Code" <> '' then
            SalesLine.Validate("Unit of Measure Code", IncEcomSalesLine."Unit of Measure Code");

        if IncEcomSalesLine."Unit Price" > 0 then
            SalesLine.Validate("Unit Price", IncEcomSalesLine."Unit Price")
        else
            SalesLine."Unit Price" := IncEcomSalesLine."Unit Price";
        SalesLine.Validate("VAT Prod. Posting Group");
        SalesLine.Validate("VAT %", IncEcomSalesLine."VAT %");

        if SalesLine."Unit Price" <> 0 then
            SalesLine.Validate("Line Amount", IncEcomSalesLine."Line Amount");

        SalesLine."NPR Inc Ecom Sales Line Id" := IncEcomSalesLine.SystemId;
        IncEcomSalesDocImplEvents.OnInsertSalesLineItemBeforeFinalizeSalesLine(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineComment(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLine: Record "Sales Line")
    var
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
    begin
        if IncEcomSalesLine.Type <> IncEcomSalesLine.Type::Comment then
            exit;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := IncEcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::" ");
        PopulateSalesLineDescriptionFromEcomSalesLine(IncEcomSalesLine, SalesLine);
        SalesLine."NPR Inc Ecom Sales Line Id" := IncEcomSalesLine.SystemId;
        IncEcomSalesDocImplEvents.OnInsertSalesLineCommenteforeFinalizeSalesLine(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineShipmentFee(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLine: Record "Sales Line")
    var
        SalesCommentLine: Record "Sales Comment Line";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
    begin
        if IncEcomSalesLine.Type <> IncEcomSalesLine.Type::"Shipment Fee" then
            exit;

        if (IncEcomSalesLine.Quantity = 0) and (IncEcomSalesLine."Line Amount" = 0) then begin
            InsertSalesLineShipmentFeeAsComment(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SalesCommentLine);
            exit;
        end;

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := IncEcomSalesDocUtils.GetInternalSalesDocumentLastLineNo(SalesHeader) + 10000;
        SalesLine.Insert(true);

        ShipmentMapping.SetRange("External Shipment Method Code", IncEcomSalesLine."No.");
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
                IncEcomSalesDocImplEvents.OnInsertSalesLineShipmentFeeSelectShippingFee(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SalesLine, ShipmentMapping);
        end;

        SalesLine.Validate("No.", ShipmentMapping."Shipment Fee No.");
        if IncEcomSalesLine.Quantity <> 0 then
            SalesLine.Validate(Quantity, IncEcomSalesLine.Quantity);

        SalesLine.Validate("VAT %", IncEcomSalesLine."VAT %");

        SalesLine.Validate("Unit Price", IncEcomSalesLine."Unit Price");
        PopulateSalesLineDescriptionFromEcomSalesLine(IncEcomSalesLine, SalesLine);

        if ShipmentMapping.Description <> '' then
            Salesline.Description := ShipmentMapping.Description;

        SalesLine."NPR Inc Ecom Sales Line Id" := IncEcomSalesLine.SystemId;
        IncEcomSalesDocImplEvents.OnInsertSalesLineShipmentFeeBeforeFinalizeLine(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SalesLine);
        SalesLine.Modify(true);
    end;

    local procedure PopulateSalesLineDescriptionFromEcomSalesLine(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLine: Record "Sales Line")
    begin
        if IncEcomSalesLine.Description = '' then
            exit;

        SalesLine.Description := CopyStr(IncEcomSalesLine.Description, 1, MaxStrLen(SalesLine.Description));
        if StrLen(IncEcomSalesLine.Description) > MaxStrLen(SalesLine.Description) then
            SalesLine."Description 2" := CopyStr(IncEcomSalesLine.Description, MaxStrLen(SalesLine.Description) + 1, MaxStrLen(SalesLine."Description 2"));
    end;

    local procedure PopulateSalesHeaderSellToNameFromEcomSalesHeader(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
        if IncEcomSalesHeader."Sell-to Name" = '' then
            exit;

        SalesHeader."Sell-to Customer Name" := CopyStr(IncEcomSalesHeader."Sell-to Name", 1, MaxStrLen(SalesHeader."Sell-to Customer Name"));
        if StrLen(IncEcomSalesHeader."Sell-to Name") > MaxStrLen(SalesHeader."Sell-to Customer Name") then
            SalesHeader."Sell-to Customer Name 2" := CopyStr(IncEcomSalesHeader."Sell-to Name", MaxStrLen(SalesHeader."Sell-to Customer Name") + 1, MaxStrLen(SalesHeader."Sell-to Customer Name 2"));
    end;

    local procedure PopulateSalesHeaderShipToNameFromEcomSalesHeader(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
        if IncEcomSalesHeader."Ship-to Name" = '' then
            exit;

        SalesHeader."Ship-to Name" := CopyStr(IncEcomSalesHeader."Ship-to Name", 1, MaxStrLen(SalesHeader."Ship-to Name"));
        if StrLen(IncEcomSalesHeader."Ship-to Name") > MaxStrLen(SalesHeader."Ship-to Name") then
            SalesHeader."Ship-to Name 2" := CopyStr(IncEcomSalesHeader."Ship-to Name", MaxStrLen(SalesHeader."Ship-to Name") + 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
    end;

    local procedure PopulateCustomerNameFromEcomSalesHeader(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var Customer: Record Customer)
    begin
        if IncEcomSalesHeader."Sell-to Name" = '' then
            exit;

        Customer."Name" := CopyStr(IncEcomSalesHeader."Sell-to Name", 1, MaxStrLen(Customer."Name"));
        if StrLen(IncEcomSalesHeader."Sell-to Name") > MaxStrLen(Customer."Name") then
            Customer."Name 2" := CopyStr(IncEcomSalesHeader."Sell-to Name", MaxStrLen(Customer."Name") + 1, MaxStrLen(Customer."Name 2"));
    end;

    local procedure InsertSalesLineShipmentFeeAsComment(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesCommentLine: Record "Sales Comment Line")
    var
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
    begin
        SalesCommentLine.Init();
        SalesCommentLine."Document Type" := SalesHeader."Document Type";
        SalesCommentLine."No." := SalesHeader."No.";
        SalesCommentLine."Document Line No." := 0;
        SalesCommentLine."Line No." := IncEcomSalesDocUtils.GetInternalSalesDocumentCommentLastLineNo(SalesHeader);
        SalesCommentLine.Date := Today();
        SalesCommentLine.Comment := CopyStr(IncEcomSalesLine.Description, 1, MaxStrLen(SalesCommentLine.Comment));
        IncEcomSalesDocImplEvents.OnInsertSalesLineShipmentFeeAsCommentBeforeFinalizeComment(IncomingSalesHeader, SalesHeader, IncEcomSalesLine, SalesCommentLine);
        SalesCommentLine.Insert(true);
    end;

    local procedure InsertPaymentLines(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        IncEcomSalesPmtLine.Reset();
        IncEcomSalesPmtLine.SetRange("Document Type", IncomingSalesHeader."Document Type");
        IncEcomSalesPmtLine.SetRange("External Document No.", IncomingSalesHeader."External No.");
        if not IncEcomSalesPmtLine.FindSet() then
            exit;

        repeat
            Clear(PaymentLine);
            case IncEcomSalesPmtLine."Payment Method Type" of
                IncEcomSalesPmtLine."Payment Method Type"::"Payment Method":
                    InsertPaymentLinePaymentMethod(IncomingSalesHeader, SalesHeader, IncEcomSalesPmtLine, PaymentLine);
                else
                    IncEcomSalesPmtLine.FieldError("Payment Method Type");
            end;
        until IncEcomSalesPmtLine.Next() = 0;
    end;

    local procedure InsertCommentLines(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        RecordLinkManagement: Codeunit "Record Link Management";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        RecordLinkManagement.CopyLinks(IncomingSalesHeader, SalesHeader);
        IncEcomSalesDocImplEvents.OnAfterInsertCommentLines(IncomingSalesHeader, SalesHeader);
    end;


    local procedure InsertPaymentLinePaymentMethod(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
        CardPaymentInstrumentTypeLbl: Label 'Card';
    begin
        if IncEcomSalesPmtLine."Payment Method Type" <> IncEcomSalesPmtLine."Payment Method Type"::"Payment Method" then
            exit;

        if IncEcomSalesPmtLine.Amount = 0 then
            exit;

        PaymentMapping.Reset();
        PaymentMapping.SetRange("External Payment Method Code", IncEcomSalesPmtLine."External Payment Method Code");
        PaymentMapping.SetRange("External Payment Type", IncEcomSalesPmtLine."External Paymment Type");
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
        PaymentLine."Line No." := IncEcomSalesDocUtils.GetInternalSalesDocumentPaymentLastLineNo(SalesHeader) + 10000;
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + SalesHeader."NPR External Order No.", 1, MaxStrLen(PaymentLine.Description));
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine."Account Type" := PaymentMethod."Bal. Account Type";
        PaymentLine."Account No." := PaymentMethod."Bal. Account No.";
        PaymentLine."No." := CopyStr(IncEcomSalesPmtLine."Payment Reference", 1, MaxStrLen(PaymentLine."No."));
        PaymentLine."Transaction ID" := IncEcomSalesPmtLine."Payment Reference";
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"Payment Method";
        PaymentLine."Source No." := PaymentMethod.Code;
        PaymentLine.Amount := IncEcomSalesPmtLine.Amount;
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := PaymentMapping."Payment Gateway Code";
        PaymentLine."Payment Gateway Shopper Ref." := IncEcomSalesPmtLine."PAR Token";
        PaymentLine."Payment Token" := IncEcomSalesPmtLine."PSP Token";
        PaymentLine."Expiry Date Text" := IncEcomSalesPmtLine."Card Expiry Date";
        PaymentLine.Brand := IncEcomSalesPmtLine."Card Brand";
        PaymentLine."Payment Instrument Type" := CopyStr(CardPaymentInstrumentTypeLbl, 1, MaxStrLen(PaymentLine."Payment Instrument Type"));
        PaymentLine."Masked PAN" := IncEcomSalesPmtLine."Masked Card Number";
#pragma warning disable AA0139
        if Strlen(PaymentLine."Masked PAN") >= 4 then
            PaymentLine."Card Summary" := CopyStr(PaymentLine."Masked PAN", Strlen(PaymentLine."Masked PAN") - 3)
        else
            PaymentLine."Card Summary" := PaymentLine."Masked PAN";
#pragma warning restore AA0139
        PaymentLine."Card Alias Token" := IncEcomSalesPmtLine."Card Alias Token";
        PaymentLine."NPR Inc Ecom Sales Pmt Line Id" := IncEcomSalesPmtLine.SystemId;
        if PaymentMapping."Captured Externally" then
            PaymentLine."Date Captured" := GetDate(SalesHeader."Order Date", SalesHeader."Posting Date");

        IncEcomSalesDocImplEvents.OnInsertPaymentLinePaymentMethodBeforeFinalizeLine(IncomingSalesHeader, SalesHeader, IncEcomSalesPmtLine, PaymentLine);
        PaymentLine.Insert(true);
    end;

    local procedure UpdateExtCouponReservations(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header")
    var
        NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        NpDcExtCouponReservation.Reset();
        NpDcExtCouponReservation.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpDcExtCouponReservation.SetRange("Document No.", '');
        if NpDcExtCouponReservation.IsEmpty then
            exit;

        NpDcExtCouponReservation.ModifyAll("Document Type", SalesHeader."Document Type");
        NpDcExtCouponReservation.ModifyAll("Document No.", SalesHeader."No.");

        IncEcomSalesDocImplEvents.OnAfterUpdateExtCouponReservations(IncomingSalesHeader, SalesHeader);
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
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        SaleLine: Record "Sales Line";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        if not IncEcomSalesHeader.GetBySystemId(SalesHeader."NPR Inc Ecom Sale Id") then
            exit;

        SaleLine.Reset();
        SaleLine.SetRange("Document Type", SalesHeader."Document Type");
        SaleLine.SetRange("Document No.", SalesHeader."No.");
        if SaleLine.IsEmpty then begin
            if IncEcomSalesHeader."Posting Status" <> IncEcomSalesHeader."Posting Status"::Invoiced then begin
                IncEcomSalesHeader."Posting Status" := IncEcomSalesHeader."Posting Status"::Invoiced;
                IncEcomSalesDocImplEvents.OnUpdateSalesDocumentPostingStatusFromSalesHeaderBeforeFinalizeUpdate(SalesHeader, IncEcomSalesHeader);
                IncEcomSalesHeader.Modify();
            end;
        end else begin
            if IncEcomSalesHeader."Posting Status" <> IncEcomSalesHeader."Posting Status"::"Partially Invoiced" then begin
                IncEcomSalesHeader."Posting Status" := IncEcomSalesHeader."Posting Status"::"Partially Invoiced";
                IncEcomSalesDocImplEvents.OnUpdateSalesDocumentPostingStatusFromSalesHeaderBeforeFinalizeUpdate(SalesHeader, IncEcomSalesHeader);
                IncEcomSalesHeader.Modify();
            end;
        end;

        SendWebhookPostedStatus(SalesHeader, IncEcomSalesHeader);
        IncEcomSalesDocImplEvents.OnAfterUpdateSalesDocumentPostingStatusFromSalesHeader(SalesHeader, IncEcomSalesHeader);

    end;

    local procedure UpdateSalesDocumentLinePostingInformationSalesInvoice(SalesInvLine: Record "Sales Invoice Line")
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        if not IncEcomSalesLine.GetBySystemId(SalesInvLine."NPR Inc Ecom Sales Line Id") then
            exit;

        IncEcomSalesHeader.SetLoadFields("Price Excl. VAT");
        if not IncEcomSalesHeader.Get(IncEcomSalesLine."Document Type", IncEcomSalesLine."External Document No.") then
            Clear(IncEcomSalesHeader);

        IncEcomSalesLine."Invoiced Qty." += SalesInvLine.Quantity;
        if IncEcomSalesHeader."Price Excl. VAT" then
            IncEcomSalesLine."Invoiced Amount" += SalesInvLine.Amount
        else
            IncEcomSalesLine."Invoiced Amount" += SalesInvLine."Amount Including VAT";
        IncEcomSalesDocImplEvents.OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesInvoice(SalesInvLine, IncEcomSalesHeader, IncEcomSalesLine);
        IncEcomSalesLine.Modify();
    end;

    local procedure UpdateSalesDocumentLinePostingInformationSalesCreditMemo(SalesCrMemoLine: Record "Sales Cr.Memo Line")
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        if not IncEcomSalesLine.GetBySystemId(SalesCrMemoLine."NPR Inc Ecom Sales Line Id") then
            exit;

        IncEcomSalesHeader.SetLoadFields("Price Excl. VAT");
        if not IncEcomSalesHeader.Get(IncEcomSalesLine."Document Type", IncEcomSalesLine."External Document No.") then
            Clear(IncEcomSalesHeader);

        IncEcomSalesLine."Invoiced Qty." += SalesCrMemoLine.Quantity;
        if IncEcomSalesHeader."Price Excl. VAT" then
            IncEcomSalesLine."Invoiced Amount" += SalesCrMemoLine.Amount
        else
            IncEcomSalesLine."Invoiced Amount" += SalesCrMemoLine."Amount Including VAT";
        IncEcomSalesDocImplEvents.OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesCreditMemo(SalesCrMemoLine, IncEcomSalesHeader, IncEcomSalesLine);
        IncEcomSalesLine.Modify();
    end;

    internal procedure UpdateSalesDocumentPaymentLinePostingInformation(PaymentLine: Record "NPR Magento Payment Line")
    var
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        if not IncEcomSalesPmtLine.GetBySystemId(PaymentLine."NPR Inc Ecom Sales Pmt Line Id") then
            exit;

        IncEcomSalesPmtLine."Invoiced Amount" += PaymentLine.Amount;
        IncEcomSalesDocImplEvents.OnUpdateSalesDocumentPaymentLinePostingInformationBeforeFinalizeRecord(PaymentLine, IncEcomSalesPmtLine);
        IncEcomSalesPmtLine.Modify();
    end;

    internal procedure UpdateSalesDocumentPaymentLineCaptureInformation(PaymentLine: Record "NPR Magento Payment Line")
    var
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
        IncEcomSalesDocImplEvents: Codeunit "NPR IncEcomSalesDocImplEvents";
    begin
        if not IncEcomSalesPmtLine.GetBySystemId(PaymentLine."NPR Inc Ecom Sales Pmt Line Id") then
            exit;

        IncEcomSalesPmtLine."Captured Amount" += PaymentLine.Amount;
        IncEcomSalesDocImplEvents.OnUpdateSalesDocumentPaymentLineCaptureInformationBeforeFinalizeRecord(PaymentLine, IncEcomSalesPmtLine);
        IncEcomSalesPmtLine.Modify();
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

    local procedure SendWebhookPostedStatus(SalesHeader: Record "Sales Header"; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        IncEcomSalesWebhook: Codeunit "NPR Inc Ecom Sales Webhooks";
        PostedStatusText: Text[50];
    begin
        // Only handle actual posting statuses, exclude pending
        if not (IncEcomSalesHeader."Posting Status" in [
            IncEcomSalesHeader."Posting Status"::"Partially Invoiced",
            IncEcomSalesHeader."Posting Status"::Invoiced]) then
            exit;

        // Determine posted status text
        if IncEcomSalesHeader."Posting Status" = IncEcomSalesHeader."Posting Status"::Invoiced then
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
        IncEcomSalesWebhook: Codeunit "NPR Inc Ecom Sales Webhooks";
        IsPosted: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;

        if IsNullGuid(Rec."NPR Inc Ecom Sale Id") then
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

        ChangeIncEcomSalesHeaderStatusCanceled(Rec);

        // Call appropriate webhook based on document type
        case Rec."Document Type" of
            Rec."Document Type"::Order:
                IncEcomSalesWebhook.OnSalesOrderCancelled(Rec.SystemId, Rec."External Document No.", Rec."NPR External Order No.", Rec."NPR Inc Ecom Sale Id");
            Rec."Document Type"::"Return Order":
                IncEcomSalesWebhook.OnSalesReturnOrderCancelled(Rec.SystemId, Rec."External Document No.", Rec."NPR External Order No.", Rec."NPR Inc Ecom Sale Id");
        end;
    end;

    local procedure ChangeIncEcomSalesHeaderStatusCanceled(SalesHeader: Record "Sales Header")
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"]) then
            exit;
        if not IncEcomSalesHeader.GetBySystemId(SalesHeader."NPR Inc Ecom Sale Id") then
            exit;
        IncEcomSalesHeader."Creation Status" := IncEcomSalesHeader."Creation Status"::Canceled;
        IncEcomSalesHeader.Modify(true);
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

    internal procedure GetApiVersionV2(): Date
    begin
        exit(20251019D);
    end;
}
#endif
