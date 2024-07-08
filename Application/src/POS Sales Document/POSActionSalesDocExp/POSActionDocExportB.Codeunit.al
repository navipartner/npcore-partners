codeunit 6059913 "NPR POS Action: Doc. ExportB"
{
    Access = Internal;
    internal procedure SelectCustomer(var SalePOS: Record "NPR POS Sale"; POSSale: Codeunit "NPR POS Sale"; CustomerTableView: Text; CustomerLookupPage: Integer): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then
            exit(true);

        if CustomerTableView <> '' then
            Customer.SetView(CustomerTableView);

        if PAGE.RunModal(CustomerLookupPage, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        Commit();
        POSSale.RefreshCurrent();
        exit(true);
    end;


    internal procedure SetInputs(ExtDocumentNo: code[35]; ContactNo: text[30]; Reference: text[35]; var SalePOS: Record "NPR POS Sale"): Boolean
    var
        ModifyRec: Boolean;
    begin
        if (ExtDocumentNo <> '') then begin
            SalePOS.Validate("External Document No.", CopyStr(ExtDocumentNo, 1, MaxStrLen(SalePOS."External Document No.")));
            ModifyRec := true;
        end;

        if (ContactNo <> '') then begin
            SalePOS.Validate("Contact No.", CopyStr(ContactNo, 1, MaxStrLen(SalePOS."Contact No.")));
            ModifyRec := true;
        end;

        if (Reference <> '') then begin
            SalePOS.Validate(Reference, CopyStr(Reference, 1, MaxStrLen(SalePOS.Reference)));
            ModifyRec := true;
        end;

        exit(ModifyRec);
    end;


    internal procedure SaleLinesExists(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        ErrNoSaleLines: Label 'There are no sale lines to export';
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.IsEmpty() then
            Error(ErrNoSaleLines);
    end;

    internal procedure CheckCustomer(SalePOS: Record "NPR POS Sale"; CustomerTableView: Text)
    var
        Customer: Record Customer;
        Err_Customer_Not_In_Filter: Label 'The customer with Customer No. %1 is not within the filter defined in the POS Action parameters', Comment = '%1 = Customer No.';
    begin
        Customer.SetView(CustomerTableView);
        Customer.FilterGroup(40);
        Customer.SetRange("No.", SalePOS."Customer No.");
        if Customer.IsEmpty then
            Error(Err_Customer_Not_In_Filter, SalePOS."Customer No.");
    end;

    internal procedure SetDocumentType(AmountInclVAT: Decimal; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; DocumentTypePozitive: Option "Order",Invoice,Quote,Restrict,"Blanket Order"; DocumentTypeNegative: Option ReturnOrder,CreditMemo,Restrict)
    var
        WrongNegativeSignErr: Label 'Amount must be positive for: %1';
        WrongPozitiveSignErr: Label 'Amount must be negative for: %1';
        OptionDocTypePozitive: Label 'Order,Invoice,Quote,Restrict';
        OptionDocTypeNegative: Label 'Return Order,Credit Memo,Restrict';
    begin
        if AmountInclVAT >= 0 then
            case DocumentTypePozitive of
                DocumentTypePozitive::Order:
                    RetailSalesDocMgt.SetDocumentTypeOrder();
                DocumentTypePozitive::Invoice:
                    RetailSalesDocMgt.SetDocumentTypeInvoice();
                DocumentTypePozitive::Quote:
                    RetailSalesDocMgt.SetDocumentTypeQuote();
                DocumentTypePozitive::Restrict:
                    Error(WrongPozitiveSignErr, SelectStr(DocumentTypeNegative + 1, OptionDocTypeNegative));
                DocumentTypePozitive::"Blanket Order":
                    RetailSalesDocMgt.SetDocumentTypeBlanketOrder();
            end
        else
            case DocumentTypeNegative of
                DocumentTypeNegative::CreditMemo:
                    RetailSalesDocMgt.SetDocumentTypeCreditMemo();
                DocumentTypeNegative::ReturnOrder:
                    RetailSalesDocMgt.SetDocumentTypeReturnOrder();
                DocumentTypeNegative::Restrict:
                    Error(WrongNegativeSignErr, SelectStr(DocumentTypePozitive + 1, OptionDocTypePozitive));
            end;
    end;

    procedure SetLocationSource(var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; LocationSource: Option Undefined,"POS Store","POS Sale",SpecificLocation; SpecificLocationCode: Code[10])
    var
        LocationSourceMustBeSpecified: Label 'POS Action''s parameter ''%1'' cannot be set to ''%2'' value', Comment = 'POS Action''s parameter ''Use Location From'' cannot be set to ''<Undefined>'' value';
        CaptionUseLocationFrom: Label 'Use Location From';
        CaptionUseSpecLocationCode: Label 'Use Specific Location Code';
        OptionNameUseLocationFrom: Label '<Undefined>,POS Store,POS Sale,SpecificLocation', Locked = true;
        SpecLocationCodeMustBeSpecified: Label 'POS Action''s parameter ''%1'' is set to ''%2''. You must specify location code to be used for sale document as a parameter of the POS action (the parameter name is ''%3'')', Comment = 'POS Action''s parameter ''Use Location From'' is set to ''Specific Location''. You must specify location code to be used for sale document as a parameter of the POS action (the parameter name is ''Use Specific Location Code'')';
    begin
        if LocationSource = LocationSource::Undefined then
            Error(LocationSourceMustBeSpecified, CaptionUseLocationFrom, SelectStr(LocationSource + 1, OptionNameUseLocationFrom));

        if (LocationSource = LocationSource::SpecificLocation) and (SpecificLocationCode = '') then
            Error(SpecLocationCodeMustBeSpecified, CaptionUseLocationFrom, SelectStr(LocationSource + 1, OptionNameUseLocationFrom), CaptionUseSpecLocationCode);

        RetailSalesDocMgt.SetLocationSource(LocationSource, SpecificLocationCode);
    end;

    procedure SetPaymentMethodCode(var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; PaymentMethodCodeSource: Option "Sales Header Default","Force Blank Code","Specific Payment Method Code"; SpecificPaymentMethodCode: Code[10])
    var
        SpecPaymentMethodCodeMustBeSpecified: Label 'POS Action''s parameter ''%1'' is set to ''%2''. You must specify payment method code to be used for sale document as a parameter of the POS action (the parameter name is ''%3'')', Comment = 'POS Action''s parameter ''Use Location From'' is set to ''Specific Location''. You must specify location code to be used for sale document as a parameter of the POS action (the parameter name is ''Use Specific Location Code'')';
        CaptionPaymentMethodCodeFrom: Label 'Use Payment Method Code From';
        CaptionPaymentMethodCode: Label 'Payment Method Code';
        OptionNamePaymentMethCodeFrom: label 'Sales Header Default,Force Blank Code,Specific Payment Method Code', locked = true;

    begin
        if (PaymentMethodCodeSource = PaymentMethodCodeSource::"Specific Payment Method Code") and (SpecificPaymentMethodCode = '') then
            Error(SpecPaymentMethodCodeMustBeSpecified, CaptionPaymentMethodCodeFrom, SelectStr(PaymentMethodCodeSource + 1, OptionNamePaymentMethCodeFrom), CaptionPaymentMethodCode);

        RetailSalesDocMgt.SetPaymentMethodCodeFrom(PaymentMethodCodeSource);
        RetailSalesDocMgt.SetPaymentMethod(SpecificPaymentMethodCode);
    end;

    internal procedure HandlePrepayment(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; PrepaymentValue: Decimal; PrepaymentIsAmount: Boolean; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean; SalePosting: Enum "NPR POS Sales Document Post")
    var
        HandlePayment: Codeunit "NPR POS Doc. Export Try Pay";
        ERR_PREPAY: Label 'Sale was exported correctly but prepayment in new sale failed: %1';
    begin
        //An error after sale end, before front end sync, is not allowed so we catch all
        Commit();
        if not HandlePayment.HandlePrepaymentTransactional(POSSession, SalesHeader, PrepaymentValue, PrepaymentIsAmount, Print, Send, Pdf2Nav, HandlePayment, SalePosting) then
            Message(ERR_PREPAY, GetLastErrorText);
    end;

    internal procedure HandlePayAndPost(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; Pdf2Nav: Boolean; Send: Boolean; FullPosting: Boolean; SalePosting: Enum "NPR POS Sales Document Post")
    var
        HandlePayment: Codeunit "NPR POS Doc. Export Try Pay";
        ERR_PAY: Label 'Sale was exported correctly but payment in new sale failed: %1';
    begin
        //An error after sale end, before front end sync, is not allowed so we catch all
        Commit();
        if not HandlePayment.HandlePayAndPostTransactional(POSSession, SalesHeader, Print, Pdf2Nav, Send, FullPosting, HandlePayment, SalePosting) then
            Message(ERR_PAY, GetLastErrorText);
    end;
}
