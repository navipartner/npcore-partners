#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248399 "NPR Inc Ecom Sales Doc Utils"
{
    Access = Internal;
    ObsoleteState = "Pending";
    ObsoleteTag = '2025-10-26';
    ObsoleteReason = 'Replaced with NPR Ecom Sales Doc Utils';

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

    internal procedure OpenRelatedSalesDocumentsFromEcomDoc(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        NoRelatedDocumentsErrorLbl: Label 'No related documents found for %1.', Comment = '%1 - record id of ecom sales header';
    begin
        if OpenRelatedSalesOrdersFromEcomDoc(IncEcomSalesHeader) then
            exit;

        if OpenRelatedSalesInvoicesFromEcomDoc(IncEcomSalesHeader) then
            exit;

        if OpenRelatedSalesReturnOrderFromEcomDoc(IncEcomSalesHeader) then
            exit;

        if OpenRelatedSalesCrMemosFromEcomDoc(IncEcomSalesHeader) then
            exit;

        Error(NoRelatedDocumentsErrorLbl, Format(IncEcomSalesHeader.RecordId));
    end;

    local procedure OpenRelatedSalesOrdersFromEcomDoc(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") Success: Boolean;
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", IncEcomSalesHeader.SystemId);
        if SalesHeader.IsEmpty then
            exit;

        Page.Run(Page::"Sales Order List", SalesHeader);

        Success := true;
    end;

    local procedure OpenRelatedSalesInvoicesFromEcomDoc(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") Success: Boolean;
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("NPR Inc Ecom Sale Id", IncEcomSalesHeader.SystemId);
        if SalesInvoiceHeader.IsEmpty then
            exit;

        Page.Run(0, SalesInvoiceHeader);

        Success := true;
    end;

    local procedure OpenRelatedSalesReturnOrderFromEcomDoc(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") Success: Boolean;
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", IncEcomSalesHeader.SystemId);
        if SalesHeader.IsEmpty then
            exit;

        Page.Run(Page::"Sales Return Order List", SalesHeader);

        Success := true;
    end;

    local procedure OpenRelatedSalesCrMemosFromEcomDoc(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") Success: Boolean;
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Reset();
        SalesCrMemoHeader.SetRange("NPR Inc Ecom Sale Id", IncEcomSalesHeader.SystemId);
        if SalesCrMemoHeader.IsEmpty then
            exit;

        Page.Run(0, SalesCrMemoHeader);

        Success := true;
    end;

    internal procedure GetSalesDocLastPaymentLineLineNo(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") LastLineNo: Integer;
    var
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
    begin
        IncEcomSalesPmtLine.SetRange("Document Type", IncEcomSalesHeader."Document Type");
        IncEcomSalesPmtLine.SetRange("External Document No.", IncEcomSalesHeader."External No.");
        IncEcomSalesPmtLine.SetLoadFields("Line No.");
        if not IncEcomSalesPmtLine.FindLast() then
            exit;

        LastLineNo := IncEcomSalesPmtLine."Line No.";
    end;

    internal procedure GetSalesDocLastSalesLineLineNo(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") LastLineNo: Integer;
    var
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
    begin
        IncEcomSalesLine.SetRange("Document Type", IncEcomSalesHeader."Document Type");
        IncEcomSalesLine.SetRange("External Document No.", IncEcomSalesHeader."External No.");
        IncEcomSalesLine.SetLoadFields("Line No.");
        if not IncEcomSalesLine.FindLast() then
            exit;

        LastLineNo := IncEcomSalesLine."Line No.";
    end;

    internal procedure DeleteSalesDocPaymentLines(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line";
    begin
        IncEcomSalesPmtLine.SetRange("Document Type", IncEcomSalesHeader."Document Type");
        IncEcomSalesPmtLine.SetRange("External Document No.", IncEcomSalesHeader."External No.");
        if not IncEcomSalesPmtLine.IsEmpty then
            IncEcomSalesPmtLine.DeleteAll(true);
    end;

    internal procedure DeleteSalesDocSalesLines(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        IncEcomSalesLine: Record "NPR Inc Ecom Sales Line";
    begin
        IncEcomSalesLine.Reset();
        IncEcomSalesLine.SetRange("Document Type", IncEcomSalesHeader."Document Type");
        IncEcomSalesLine.SetRange("External Document No.", IncEcomSalesHeader."External No.");
        if not IncEcomSalesLine.IsEmpty then
            IncEcomSalesLine.DeleteAll(true);
    end;

    internal procedure SetSalesDocCreationStatusCreated(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; ModifyRecord: Boolean)
    var
        IncEcomSalesDocEvents: Codeunit "NPR Inc Ecom Sales Doc Events";
    begin
        IncEcomSalesHeader."Created Date" := Today;
        IncEcomSalesHeader."Created Time" := Time;
        IncEcomSalesHeader."Created By User Name" := CopyStr(UserId, 1, MaxStrLen(IncEcomSalesHeader."Created By User Name"));
        IncEcomSalesHeader."Created By User Id" := UserSecurityId();
        IncEcomSalesHeader."Creation Status" := IncEcomSalesHeader."Creation Status"::Created;
        ClearEcomSalesHeaderErrorProcessingFields(IncEcomSalesHeader);
        IncEcomSalesDocEvents.OnSetSalesDocCreationStatusCreatedBeforeModifyRecord(IncEcomSalesHeader, ModifyRecord);
        if ModifyRecord then
            IncEcomSalesHeader.Modify(true);
    end;

    internal procedure SetSalesDocCreationStatusError(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; ErrorMessage: Text[500]; UpdateStatus: Boolean; ModifyRecord: Boolean)
    var
        IncEcomSalesDocEvents: Codeunit "NPR Inc Ecom Sales Doc Events";
    begin
        IncEcomSalesHeader."Last Error Date" := Today;
        IncEcomSalesHeader."Last Error Time" := Time;
        IncEcomSalesHeader."Last Error Rcvd By User Name" := CopyStr(UserId, 1, MaxStrLen(IncEcomSalesHeader."Last Error Rcvd By User Name"));
        IncEcomSalesHeader."Last Error Message" := ErrorMessage;
        IncEcomSalesHeader."Last Error Rcvd By User Id" := UserSecurityId();

        if UpdateStatus then
            IncEcomSalesHeader."Creation Status" := IncEcomSalesHeader."Creation Status"::Error;

        IncEcomSalesDocEvents.OnSetSalesDocCreationStatusErrorBeforeModifyRecord(IncEcomSalesHeader, ErrorMessage, UpdateStatus, ModifyRecord);
        if ModifyRecord then
            IncEcomSalesHeader.Modify(true);
    end;

    local procedure SetSalesDocStatusPending(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; ModifyRecord: Boolean)
    var
        IncEcomSalesDocEvents: Codeunit "NPR Inc Ecom Sales Doc Events";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RelatedSalesHeaderExistsErrorLbl: Label 'You cannot change the status of document no.: %1 to pending because there are related documents to it.', Comment = '%1 - document no.';
    begin
        if FindRelatedSalesHeaders(IncEcomSalesHeader, SalesHeader) then
            Error(RelatedSalesHeaderExistsErrorLbl, IncEcomSalesHeader."External No.");

        if FindRelatedSalesInvoiceHeaders(IncEcomSalesHeader, SalesInvoiceHeader) then
            Error(RelatedSalesHeaderExistsErrorLbl, IncEcomSalesHeader."External No.");

        ClearEcomSalesHeaderProcessingFields(IncEcomSalesHeader);
        IncEcomSalesDocEvents.OnSetSalesDocStatusPendingBeforeModifyRecord(IncEcomSalesHeader, ModifyRecord);
        if ModifyRecord then
            IncEcomSalesHeader.Modify();
    end;

    internal procedure SetSalesDocStatusPendingWithConfirmation(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; ModifyRecord: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        PendingConfirmLbl: Label 'Are you sure you want to set the status of %1 external no. %2 to pending?', Comment = '%1 - document type, %2 - external no';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(PendingConfirmLbl, IncEcomSalesHeader."Document Type", IncEcomSalesHeader."External No."), true) then
            exit;

        SetSalesDocStatusPending(IncEcomSalesHeader, ModifyRecord);
    end;

    local procedure ClearEcomSalesHeaderProcessingFields(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    begin
        IncEcomSalesHeader."Creation Status" := IncEcomSalesHeader."Creation Status"::Pending;
        IncEcomSalesHeader."Created Doc No." := '';
        IncEcomSalesHeader."Created Date" := 0D;
        IncEcomSalesHeader."Created Time" := 0T;
        IncEcomSalesHeader."Created By User Name" := '';
        Clear(IncEcomSalesHeader."Created By User Id");

        ClearEcomSalesHeaderErrorProcessingFields(IncEcomSalesHeader);

        IncEcomSalesHeader."Process Retry Count" := 0;
    end;

    local procedure ClearEcomSalesHeaderErrorProcessingFields(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    begin
        IncEcomSalesHeader."Last Error Message" := '';
        IncEcomSalesHeader."Last Error Date" := 0D;
        IncEcomSalesHeader."Last Error Time" := 0T;
        IncEcomSalesHeader."Last Error Rcvd By User Name" := '';
        Clear(IncEcomSalesHeader."Last Error Rcvd By User Id");
    end;


    local procedure FindRelatedSalesHeaders(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header") Found: Boolean;
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", IncEcomSalesHeader.SystemId);
        Found := not SalesHeader.IsEmpty;
    end;

    local procedure FindRelatedSalesInvoiceHeaders(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesInvoiceHeader: Record "Sales Invoice Header") Found: Boolean;
    begin
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("NPR Inc Ecom Sale Id", IncEcomSalesHeader.SystemId);
        Found := not SalesInvoiceHeader.IsEmpty;
    end;

    internal procedure GetIncEcomSalesHeaderCreationStatusStyle(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") StyleText: Text
    begin
        Case IncEcomSalesHeader."Creation Status" of
            IncEcomSalesHeader."Creation Status"::Error:
                StyleText := 'Unfavorable';
            IncEcomSalesHeader."Creation Status"::Created:
                StyleText := 'Favorable';
        End;
    end;

    internal procedure GetIncEcomSalesHeaderErrorInformationStyle(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") StyleText: Text
    begin
        Case IncEcomSalesHeader."Creation Status" of
            IncEcomSalesHeader."Creation Status"::Error:
                StyleText := 'Unfavorable';
        End;
    end;

    internal procedure OpenSalesDocumentCard(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line")
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
    begin
        IncEcomSalesHeader.Get(IncEcomSalesLine."Document Type", IncEcomSalesLine."External Document No.");
        Page.Run(Page::"NPR Inc Ecom Sales Document", IncEcomSalesHeader);
    end;

    internal procedure OpenPaymentLines(IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.Reset();
        PaymentLine.SetFilter("NPR Inc Ecom Sales Pmt Line Id", IncEcomSalesPmtLine.SystemId);

        Page.Run(0, PaymentLine);
    end;

    internal procedure OpenPostedSalesInvoiceLines(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("NPR Inc Ecom Sales Line Id", IncEcomSalesLine.SystemId);

        Page.Run(0, SalesInvoiceLine);
    end;

    internal procedure OpenFailedSalesOrders()
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
    begin
        IncEcomSalesHeader.Reset();
        IncEcomSalesHeader.SetRange("Document Type", IncEcomSalesHeader."Document Type"::Order);
        IncEcomSalesHeader.SetRange("Creation Status", IncEcomSalesHeader."Creation Status"::Error);

        Page.Run(0, IncEcomSalesHeader);
    end;

    internal procedure OpenSalesOrders(DateFilter: Text)
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
    begin
        IncEcomSalesHeader.Reset();
        IncEcomSalesHeader.SetRange("Document Type", IncEcomSalesHeader."Document Type"::Order);
        IncEcomSalesHeader.SetFilter("Received Date", DateFilter);

        Page.Run(0, IncEcomSalesHeader);
    end;

    internal procedure OpenCreatedDocumentFromEcomSalesHeader(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        case IncEcomSalesHeader."Document Type" of
            IncEcomSalesHeader."Document Type"::Order:
                begin
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SetRange("No.", IncEcomSalesHeader."Created Doc No.");
                    Page.Run(page::"Sales Order", SalesHeader);
                end;
            IncEcomSalesHeader."Document Type"::"Return Order":
                begin
                    SalesHeader.Reset();
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
                    SalesHeader.SetRange("No.", IncEcomSalesHeader."Created Doc No.");
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

    internal procedure GetItemNoAndVariantNoFromEcomSalesLine(IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var ItemNo: Code[20]; var VariantCode: Code[10]) Found: Boolean
    var
        ItemReference: Record "Item Reference";
        IncEcomSalesDocEvents: Codeunit "NPR Inc Ecom Sales Doc Events";
        Handled: Boolean;
    begin
        IncEcomSalesDocEvents.OnBeforeGetItemNoAndVariantNoFromExternalNo(IncEcomSalesLine, ItemNo, VariantCode, Found, Handled);
        if Handled then
            exit;
#pragma warning disable AA0139
        ItemNo := IncEcomSalesLine."No.";
#pragma warning restore AA0139
        VariantCode := IncEcomSalesLine."Variant Code";
        Found := ItemNo <> '';
        if Found then
            exit;

        if IncEcomSalesLine."Barcode No." = '' then
            exit;

        ItemReference.Reset();
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", IncEcomSalesLine."Barcode No.");
        ItemReference.SetLoadFields("Item No.", "Variant Code");
        if not ItemReference.FindFirst() then
            exit;

        ItemNo := ItemReference."Item No.";
        VariantCode := ItemReference."Variant Code";
        Found := true;
    end;

    internal procedure CheckIncomingSalesDocumentAlreadyExists(IncEcomSalesDocType: Enum "NPR Inc Ecom Sales Doc Type"; IncEcomSalesDocumentNo: Text[20])
    var
        IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header";
        DocumentAlreadyExistsErrorLbl: Label 'Sales document with type %1 and no %2 already exists.', Comment = '%1 - ecom sales document no, %2 - ecom sales document no', Locked = true;
    begin
        IncEcomSalesHeader.SetRange("External No.", IncEcomSalesDocumentNo);
        IncEcomSalesHeader.SetRange("Document Type", IncEcomSalesDocType);
        if IncEcomSalesHeader.IsEmpty then
            exit;
        Error(DocumentAlreadyExistsErrorLbl, IncEcomSalesDocType, IncEcomSalesDocumentNo);
    end;

    internal procedure GetSalesLocationCode(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header") LocationCode: Code[10]
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        LocationCode := IncEcomSalesHeader."Location Code.";
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

    internal procedure GetCustomerTemplateAndConfigCode(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var CustTemplateCode: Code[20]; var ConfigTemplateCode: Code[10])
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        if IncEcomSalesHeader."Customer Template" <> '' then begin
            CustTemplateCode := IncEcomSalesHeader."Customer Template";
            ConfigTemplateCode := ''; // Ignore config. template if customer template is set
        end else begin
            if IncEcomSalesHeader."Configuration Template" <> '' then begin
                CustTemplateCode := '';
                ConfigTemplateCode := IncEcomSalesHeader."Configuration Template";
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
        IncEcomSalesDocImpl: Codeunit "NPR Inc Ecom Sales Doc Impl";
        IncEcomSalesDocImplV2: Codeunit "NPR Inc Ecom Sales Doc Impl V2";
    begin
        case true of
            RequestedApiVersion >= IncEcomSalesDocImplV2.GetApiVersion():
                exit(IncEcomSalesDocImplV2.GetApiVersion());
            else
                exit(IncEcomSalesDocImpl.GetApiVersion());
        end;
    end;
}
#endif