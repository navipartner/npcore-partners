#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248601 "NPR Ecom Sales Doc Utils"
{
    Access = Internal;

    internal procedure GetTotalAmountCaption(CurrencyCode: Code[10]): Text
    var
        TotalAmountLbl: Label 'Total Amount';
    begin
        exit(GetCaptionClassWithCurrencyCode(TotalAmountLbl, CurrencyCode));
    end;

    internal procedure GetPaymentAmountCaption(CurrencyCode: Code[10]): Text
    var
        PaymentAmountLbl: Label 'Payment Amount';
    begin
        exit(GetCaptionClassWithCurrencyCode(PaymentAmountLbl, CurrencyCode));
    end;

    internal procedure GetCapturedPaymentAmountCaption(CurrencyCode: Code[10]): Text
    var
        PaymentAmountLbl: Label 'Captured Payment Amount';
    begin
        exit(GetCaptionClassWithCurrencyCode(PaymentAmountLbl, CurrencyCode));
    end;

    local procedure GetCaptionClassWithCurrencyCode(CaptionWithoutCurrencyCode: Text; CurrencyCode: Code[10]): Text
    begin
        exit('3,' + GetCaptionWithCurrencyCode(CaptionWithoutCurrencyCode, CurrencyCode));
    end;

    local procedure GetCaptionWithCurrencyCode(CaptionWithoutCurrencyCode: Text; CurrencyCode: Code[10]): Text
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode = '' then begin
            GLSetup.Get();
            CurrencyCode := GLSetup.GetCurrencyCode(CurrencyCode);
        end;

        if CurrencyCode <> '' then
            exit(CaptionWithoutCurrencyCode + StrSubstNo(' (%1)', CurrencyCode));

        exit(CaptionWithoutCurrencyCode);
    end;

    internal procedure OpenRelatedSalesDocumentsFromEcomDoc(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        NoRelatedDocumentsErrorLbl: Label 'No related documents found for %1.', Comment = '%1 - record id of ecom sales header';
    begin
        if OpenRelatedSalesOrdersFromEcomDoc(EcomSalesHeader) then
            exit;

        if OpenRelatedSalesInvoicesFromEcomDoc(EcomSalesHeader) then
            exit;

        if OpenRelatedSalesReturnOrderFromEcomDoc(EcomSalesHeader) then
            exit;

        if OpenRelatedSalesCrMemosFromEcomDoc(EcomSalesHeader) then
            exit;

        Error(NoRelatedDocumentsErrorLbl, Format(EcomSalesHeader.RecordId));
    end;

    local procedure OpenRelatedSalesOrdersFromEcomDoc(EcomSalesHeader: Record "NPR Ecom Sales Header") Success: Boolean;
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        if SalesHeader.IsEmpty then
            exit;

        Page.Run(Page::"Sales Order List", SalesHeader);

        Success := true;
    end;

    local procedure OpenRelatedSalesInvoicesFromEcomDoc(EcomSalesHeader: Record "NPR Ecom Sales Header") Success: Boolean;
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        if SalesInvoiceHeader.IsEmpty then
            exit;

        Page.Run(0, SalesInvoiceHeader);

        Success := true;
    end;

    local procedure OpenRelatedSalesReturnOrderFromEcomDoc(EcomSalesHeader: Record "NPR Ecom Sales Header") Success: Boolean;
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        if SalesHeader.IsEmpty then
            exit;

        Page.Run(Page::"Sales Return Order List", SalesHeader);

        Success := true;
    end;

    local procedure OpenRelatedSalesCrMemosFromEcomDoc(EcomSalesHeader: Record "NPR Ecom Sales Header") Success: Boolean;
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Reset();
        SalesCrMemoHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        if SalesCrMemoHeader.IsEmpty then
            exit;

        Page.Run(0, SalesCrMemoHeader);

        Success := true;
    end;

    internal procedure GetSalesDocLastPaymentLineLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header") LastLineNo: Integer;
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesPmtLine.SetLoadFields("Line No.");
        if not EcomSalesPmtLine.FindLast() then
            exit;

        LastLineNo := EcomSalesPmtLine."Line No.";
    end;

    internal procedure GetSalesDocLastSalesLineLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header") LastLineNo: Integer;
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetLoadFields("Line No.");
        if not EcomSalesLine.FindLast() then
            exit;

        LastLineNo := EcomSalesLine."Line No.";
    end;

    internal procedure DeleteSalesDocPaymentLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if not EcomSalesPmtLine.IsEmpty then
            EcomSalesPmtLine.DeleteAll(true);
    end;

    internal procedure DeleteSalesDocSalesLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Reset();
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if not EcomSalesLine.IsEmpty then
            EcomSalesLine.DeleteAll(true);
    end;

    internal procedure SetSalesDocCreationStatusCreated(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ModifyRecord: Boolean)
    var
        EcomSalesDocEvents: Codeunit "NPR Ecom Sales Doc Events";
    begin
        EcomSalesHeader."Created Date" := Today;
        EcomSalesHeader."Created Time" := Time;
        EcomSalesHeader."Created By User Name" := CopyStr(UserId, 1, MaxStrLen(EcomSalesHeader."Created By User Name"));
        EcomSalesHeader."Created By User Id" := UserSecurityId();
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        ClearEcomSalesHeaderErrorProcessingFields(EcomSalesHeader);
        EcomSalesDocEvents.OnSetSalesDocCreationStatusCreatedBeforeModifyRecord(EcomSalesHeader, ModifyRecord);
        if ModifyRecord then
            EcomSalesHeader.Modify(true);
    end;

    internal procedure SetSalesDocCreationStatusError(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ErrorMessage: Text[500]; UpdateStatus: Boolean; ModifyRecord: Boolean)
    var
        EcomSalesDocEvents: Codeunit "NPR Ecom Sales Doc Events";
    begin
        EcomSalesHeader."Last Error Date" := Today;
        EcomSalesHeader."Last Error Time" := Time;
        EcomSalesHeader."Last Error Rcvd By User Name" := CopyStr(UserId, 1, MaxStrLen(EcomSalesHeader."Last Error Rcvd By User Name"));
        EcomSalesHeader."Last Error Message" := ErrorMessage;
        EcomSalesHeader."Last Error Rcvd By User Id" := UserSecurityId();

        if UpdateStatus then
            EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Error;

        EcomSalesDocEvents.OnSetSalesDocCreationStatusErrorBeforeModifyRecord(EcomSalesHeader, ErrorMessage, UpdateStatus, ModifyRecord);
        if ModifyRecord then
            EcomSalesHeader.Modify(true);
    end;

    local procedure SetSalesDocStatusPending(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ModifyRecord: Boolean)
    var
        EcomSalesDocEvents: Codeunit "NPR Ecom Sales Doc Events";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RelatedSalesHeaderExistsErrorLbl: Label 'You cannot change the status of document no.: %1 to pending because there are related documents to it.', Comment = '%1 - document no.';
    begin
        if FindRelatedSalesHeaders(EcomSalesHeader, SalesHeader) then
            Error(RelatedSalesHeaderExistsErrorLbl, EcomSalesHeader."External No.");

        if FindRelatedSalesInvoiceHeaders(EcomSalesHeader, SalesInvoiceHeader) then
            Error(RelatedSalesHeaderExistsErrorLbl, EcomSalesHeader."External No.");

        ClearEcomSalesHeaderProcessingFields(EcomSalesHeader);
        EcomSalesDocEvents.OnSetSalesDocStatusPendingBeforeModifyRecord(EcomSalesHeader, ModifyRecord);
        if ModifyRecord then
            EcomSalesHeader.Modify();
    end;

    internal procedure SetSalesDocStatusPendingWithConfirmation(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ModifyRecord: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        PendingConfirmLbl: Label 'Are you sure you want to set the status of %1 external no. %2 to pending?', Comment = '%1 - document type, %2 - external no';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(PendingConfirmLbl, EcomSalesHeader."Document Type", EcomSalesHeader."External No."), true) then
            exit;

        SetSalesDocStatusPending(EcomSalesHeader, ModifyRecord);
    end;

    local procedure ClearEcomSalesHeaderProcessingFields(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Pending;
        EcomSalesHeader."Created Doc No." := '';
        EcomSalesHeader."Created Date" := 0D;
        EcomSalesHeader."Created Time" := 0T;
        EcomSalesHeader."Created By User Name" := '';
        Clear(EcomSalesHeader."Created By User Id");

        ClearEcomSalesHeaderErrorProcessingFields(EcomSalesHeader);

        EcomSalesHeader."Process Retry Count" := 0;
    end;

    local procedure ClearEcomSalesHeaderErrorProcessingFields(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader."Last Error Message" := '';
        EcomSalesHeader."Last Error Date" := 0D;
        EcomSalesHeader."Last Error Time" := 0T;
        EcomSalesHeader."Last Error Rcvd By User Name" := '';
        Clear(EcomSalesHeader."Last Error Rcvd By User Id");
    end;


    local procedure FindRelatedSalesHeaders(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header") Found: Boolean;
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        Found := not SalesHeader.IsEmpty;
    end;

    local procedure FindRelatedSalesInvoiceHeaders(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header") Found: Boolean;
    begin
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        Found := not SalesInvoiceHeader.IsEmpty;
    end;

    internal procedure GetIncEcomSalesHeaderCreationStatusStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Creation Status" of
            EcomSalesHeader."Creation Status"::Error:
                StyleText := 'Unfavorable';
            EcomSalesHeader."Creation Status"::Created:
                StyleText := 'Favorable';
        end;
    end;

    internal procedure GetIncEcomSalesHeaderErrorInformationStyle(EcomSalesHeader: Record "NPR Ecom Sales Header") StyleText: Text
    begin
        case EcomSalesHeader."Creation Status" of
            EcomSalesHeader."Creation Status"::Error:
                StyleText := 'Unfavorable';
        end;
    end;

    internal procedure OpenSalesDocumentCard(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.Get(EcomSalesLine."Document Entry No.");
        Page.Run(Page::"NPR Ecom Sales Document", EcomSalesHeader);
    end;

    internal procedure OpenPaymentLines(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetFilter("NPR Inc Ecom Sales Pmt Line Id", EcomSalesPmtLine.SystemId);

        Page.Run(0, PaymentLine);
    end;

    internal procedure OpenPostedSalesInvoiceLines(EcomSalesLine: Record "NPR Ecom Sales Line")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("NPR Inc Ecom Sales Line Id", EcomSalesLine.SystemId);

        Page.Run(0, SalesInvoiceLine);
    end;

    internal procedure OpenFailedSalesOrders()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetRange("Creation Status", EcomSalesHeader."Creation Status"::Error);

        Page.Run(0, EcomSalesHeader);
    end;

    internal procedure OpenSalesOrders(DateFilter: Text)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
        EcomSalesHeader.SetFilter("Received Date", DateFilter);

        Page.Run(0, EcomSalesHeader);
    end;

    internal procedure OpenCreatedDocumentFromEcomSalesHeader(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        case EcomSalesHeader."Document Type" of
            EcomSalesHeader."Document Type"::Order:
                begin
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", EcomSalesHeader."Created Doc No.");
                    Page.Run(page::"Sales Order", SalesHeader);
                end;
            EcomSalesHeader."Document Type"::"Return Order":
                begin
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
                    SalesHeader.SetRange("No.", EcomSalesHeader."Created Doc No.");
                    Page.Run(page::"Sales Return Order", SalesHeader);
                end;
        end;
    end;

    internal procedure GetInternalSalesDocumentCommentLastLineNo(SalesHeader: Record "Sales Header") LastLineNo: Integer;
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        SalesCommentLine.Reset();
        SalesCommentLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesCommentLine.SetRange("No.", SalesHeader."No.");
        SalesCommentLine.SetLoadFields("Line No.");
        if not SalesCommentLine.FindLast() then
            exit;

        LastLineNo := SalesCommentLine."Line No.";
    end;

    internal procedure GetInternalSalesDocumentLastLineNo(SalesHeader: Record "Sales Header") LastLineNo: Integer;
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetLoadFields("Line No.");
        if not SalesLine.FindLast() then
            exit;

        LastLineNo := SalesLine."Line No.";
    end;

    internal procedure GetInternalSalesDocumentPaymentLastLineNo(SalesHeader: Record "Sales Header") LastLineNo: Integer;
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetLoadFields("Line No.");
        if not PaymentLine.FindLast() then
            exit;

        LastLineNo := PaymentLine."Line No.";
    end;

    internal procedure GetItemNoAndVariantNoFromEcomSalesLine(EcomSalesLine: Record "NPR Ecom Sales Line"; var ItemNo: Code[20]; var VariantCode: Code[10]) Found: Boolean
    var
        ItemReference: Record "Item Reference";
        EcomSalesDocEvents: Codeunit "NPR Ecom Sales Doc Events";
        Handled: Boolean;
    begin
        EcomSalesDocEvents.OnBeforeGetItemNoAndVariantNoFromExternalNo(EcomSalesLine, ItemNo, VariantCode, Found, Handled);
        if Handled then
            exit;
#pragma warning disable AA0139
        ItemNo := EcomSalesLine."No.";
#pragma warning restore AA0139
        VariantCode := EcomSalesLine."Variant Code";
        Found := ItemNo <> '';
        if Found then
            exit;

        if EcomSalesLine."Barcode No." = '' then
            exit;

        ItemReference.Reset();
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", EcomSalesLine."Barcode No.");
        ItemReference.SetLoadFields("Item No.", "Variant Code");
        if not ItemReference.FindFirst() then
            exit;

        ItemNo := ItemReference."Item No.";
        VariantCode := ItemReference."Variant Code";
        Found := true;
    end;

    internal procedure CheckIncomingSalesDocumentAlreadyExists(EcomSalesDocType: Enum "NPR Ecom Sales Doc Type"; EcomSalesDocumentNo: Text[20])
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        DocumentAlreadyExistsErrorLbl: Label 'Sales document with type %1 and no %2 already exists.', Comment = '%1 - ecom sales document no, %2 - ecom sales document no', Locked = true;
    begin
        EcomSalesHeader.SetRange("External No.", EcomSalesDocumentNo);
        EcomSalesHeader.SetRange("Document Type", EcomSalesDocType);
        if EcomSalesHeader.IsEmpty then
            exit;
        Error(DocumentAlreadyExistsErrorLbl, EcomSalesDocType, EcomSalesDocumentNo);
    end;

    internal procedure GetSalesLocationCode(EcomSalesHeader: Record "NPR Ecom Sales Header") LocationCode: Code[10]
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        LocationCode := EcomSalesHeader."Location Code";
        if LocationCode <> '' then
            exit;

        IncEcomSalesDocSetup.SetLoadFields("Def. Sales Location Code");
        if not IncEcomSalesDocSetup.Get() then
            exit;

        LocationCode := IncEcomSalesDocSetup."Def. Sales Location Code";
    end;

    internal procedure OpenPaymentMethodMapping()
    var
        MagentoPaymentMapping: Record "NPR Magento Payment Mapping";
    begin
        Page.Run(Page::"NPR Magento Payment Mapping", MagentoPaymentMapping);
    end;

    internal procedure OpenShipmentMethodMapping()
    var
        MagentoShipmentMapping: Record "NPR Magento Shipment Mapping";
    begin
        Page.Run(Page::"NPR Magento Shipment Mapping", MagentoShipmentMapping);
    end;

    internal procedure GetCustConfigTemplate(TaxClass: Text) ConfigTemplateCode: Code[10]
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
        MagentoTaxClass: Record "NPR Magento Tax Class";
    begin
        if not IncEcomSalesDocSetup.Get() then
            IncEcomSalesDocSetup.Init();

        ConfigTemplateCode := IncEcomSalesDocSetup."Def Cust Config Template Code";
        if MagentoTaxClass.Get(TaxClass, MagentoTaxClass.Type::Customer) and (MagentoTaxClass."Customer Config. Template Code" <> '') then
            ConfigTemplateCode := MagentoTaxClass."Customer Config. Template Code";

        exit(ConfigTemplateCode);
    end;

    internal procedure GetCustTemplate(Customer: Record Customer) TemplateCode: Code[20]
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if not IncEcomSalesDocSetup.Get() then
            exit;

        TemplateCode := IncEcomSalesDocSetup."Def. Customer Template Code";
    end;

    internal procedure GetCustomerTemplateAndConfigCode(EcomSalesHeader: Record "NPR Ecom Sales Header"; var CustTemplateCode: Code[20]; var ConfigTemplateCode: Code[10])
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if EcomSalesHeader."Customer Template" <> '' then begin
            CustTemplateCode := EcomSalesHeader."Customer Template";
            ConfigTemplateCode := ''; // Ignore config. template if customer template is set
        end else begin
            if EcomSalesHeader."Configuration Template" <> '' then begin
                CustTemplateCode := '';
                ConfigTemplateCode := EcomSalesHeader."Configuration Template";
            end else begin
                if not IncEcomSalesDocSetup.Get() then
                    IncEcomSalesDocSetup.Init();
                CustTemplateCode := IncEcomSalesDocSetup."Def. Customer Template Code";
                ConfigTemplateCode := IncEcomSalesDocSetup."Def Cust Config Template Code";
            end;
        end;
    end;

    internal procedure GetApiVersionDateByRequest(RequestedApiVersion: Date): Date
    var
        EcomSalesDocImpl: Codeunit "NPR Ecom Sales Doc Impl";
        EcomSalesDocImplV2: Codeunit "NPR Ecom Sales Doc Impl V2";
    begin
        case true of
            RequestedApiVersion >= EcomSalesDocImplV2.GetApiVersion():
                exit(EcomSalesDocImplV2.GetApiVersion());
            else
                exit(EcomSalesDocImpl.GetApiVersion());
        end;
    end;

    internal procedure GetInternalEcomDocumentPaymentLastLineNo(EcomSalesHeader: Record "NPR Ecom Sales Header") LastLineNo: Integer;
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"NPR Ecom Sales Header");
        case EcomSalesHeader."Document Type" of
            EcomSalesHeader."Document Type"::Order:
                PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
            EcomSalesHeader."Document Type"::"Return Order":
                PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::"Return Order");
        end;
        PaymentLine.SetRange("Document No.", EcomSalesHeader."External No.");
        PaymentLine.SetLoadFields("Line No.");
        if not PaymentLine.FindLast() then
            exit;

        LastLineNo := PaymentLine."Line No.";
    end;

    internal procedure DeleteMagentoPaymentLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        MagentoPaymentLine.SetRange("Source Table No.", EcomSalesHeader.RecordId.TableNo);
        if MagentoPaymentLine.IsEmpty then
            exit;
        MagentoPaymentLine.DeleteAll(true);
    end;

    internal procedure DeleteVoucherSalesLines(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.Reset();
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("External Document No.", EcomSalesHeader."External No.");
        NpRvSalesLine.SetRange("Document No.", '');
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        NpRvSalesLine.SetRange("Document Line No.", 0);
        if not NpRvSalesLine.IsEmpty then
            NpRvSalesLine.DeleteAll(true);
    end;
}
#endif