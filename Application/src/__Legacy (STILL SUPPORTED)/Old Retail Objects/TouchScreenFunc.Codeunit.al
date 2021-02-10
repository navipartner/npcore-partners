// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6014505 "NPR Touch Screen - Func."
{
    Permissions = TableData "NPR Audit Roll" = rimd;

    var
        RetailSetupGlobal: Record "NPR Retail Setup";
        RetailSalesCode: Codeunit "NPR Retail Sales Code";
        RetailFormCodeGlobal: Codeunit "NPR Retail Form Code";
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //POSEventMarshaller: Codeunit "POS Event Marshaller";
        LastInteger: Integer;

    procedure AskRefAtt(var SalePOS: Record "NPR Sale POS"; ForceContactNo: Boolean): Boolean
    var
        ReferenceTxt: Label 'Ext. Document No.';
        AttentionTxt: Label 'Attention:';
        Txt001: Label 'The reference number of the customers quote, order etc.';
        Txt002: Label 'The name on the customer collecting the goods.';
    begin
        //askRefAtt
        RetailSetupGlobal.Get;

        if (SalePOS."Customer No." = '') and ForceContactNo then begin
            SalePOS.Reference := '';
            SalePOS."Contact No." := '';
            SalePOS.Modify(true);
            exit(false);
        end;

        /* Because of a modify on the table Sale code*/
        Commit;

        if (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) and ForceContactNo then begin
            // TODO: CTRLUPGRADE - The block below must be refactored to not use Marshaller
            Error('CTRLUPGRADE');
            /*
            if RetailSetupGlobal."Ask for Reference" then begin
                SalePOS.Reference := CopyStr(POSEventMarshaller.SearchBox(ReferenceTxt, Txt001, 50), 1, 20);
            end;
            if RetailSetupGlobal."Ask for Attention Name" then begin
                SalePOS."Contact No." := CopyStr(POSEventMarshaller.SearchBox(AttentionTxt, Txt002, 50), 1, 30);
            end;
            */
        end;

        if not ForceContactNo then begin
            // TODO: CTRLUPGRADE - The block below must be refactored to not use Marshaller
            Error('CTRLUPGRADE');
            /*
            SalePOS.Reference := CopyStr(POSEventMarshaller.SearchBox(ReferenceTxt, Txt001, 50), 1, 30);
            SalePOS."Contact No." := CopyStr(POSEventMarshaller.SearchBox(AttentionTxt, Txt002, 50), 1, 30);
            SalePOS.Modify;
            */
        end;

        exit(true);

    end;

    procedure BalanceInvoice(var SalePOS: Record "NPR Sale POS"; var SaleLinePOS: Record "NPR Sale Line POS"; InvoiceIn: Code[20]) InvoiceNo: Code[20]
    var
        Customer: Record Customer;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        InputInvoice: Label 'Enter Invoice Number';
        SaleLinePOSCheck: Record "NPR Sale Line POS";
        "Field": Record "Field";
        LineAmount: Decimal;
        ConfimBalance: Label 'Do you wish to apply %1 %2 for customer %3?';
        ErrDoubleEntry: Label 'Error. Document %1 %2 is alleredy selected for balancing.';
        ErrAllreadyBalanced: Label 'Error. Document %1 %2 is already balanced.';
        ErrCurrency: Label 'Error. Currency code %1 cannot be settled in this way';
        TextBalance: Label 'Balancing of %1';
    begin
        if SalePOS."Customer No." <> '' then
            CustLedgerEntry.SetRange("Customer No.", SalePOS."Customer No.");

        Commit;

        if InvoiceIn = '' then begin
            // TODO: CTRLUPGRADE - The block below must be refactored to not use Marshaller
            Error('CTRLUPGRADE');
            /*
            if not POSEventMarshaller.NumPadCode(InputInvoice, InvoiceNo, false, false) then
                exit('');
            */
        end else
            InvoiceNo := InvoiceIn;

        if InvoiceNo in ['', '<CANCEL>'] then
            exit('');

        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        CustLedgerEntry.SetRange(Open, true);
        InvoiceNo := '';
        if not CustLedgerEntry.FindFirst then begin
            Message(ErrAllreadyBalanced,
                    CustLedgerEntry.GetFilter("Document Type"),
                    CustLedgerEntry.GetFilter("Document No."));
            exit('');
        end;

        if Customer.Get(CustLedgerEntry."Customer No.") then;

        SaleLinePOSCheck.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOSCheck.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOSCheck.SetRange("Buffer Document Type", CustLedgerEntry."Document Type");
        SaleLinePOSCheck.SetRange("Buffer Document No.", CustLedgerEntry."Document No.");
        if SaleLinePOSCheck.FindFirst then begin
            Message(ErrDoubleEntry, CustLedgerEntry."Document Type", CustLedgerEntry."Document No.");
            exit('');
        end;

        if not Confirm(StrSubstNo(ConfimBalance, CustLedgerEntry."Document Type", CustLedgerEntry."Document No.", Customer.Name), true) then
            exit('');

        InvoiceNo := CustLedgerEntry."Document No.";

        SalePOS.Validate("Customer No.", CustLedgerEntry."Customer No.");

        if not (CustLedgerEntry."Currency Code" in ['', 'DKK']) then
            Error(ErrCurrency, CustLedgerEntry."Currency Code");

        Field.Get(21, 14); // Debpost.restbel�b
        if Field.Class = Field.Class::FlowField then
            CustLedgerEntry.CalcFields("Remaining Amount");

        if (SaleLinePOS.Type = SaleLinePOS.Type::Customer) and
           (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Deposit) and
             (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) and
               (SaleLinePOS.Date <= CustLedgerEntry."Pmt. Discount Date") then
            LineAmount := (CustLedgerEntry."Remaining Amount" - CustLedgerEntry."Original Pmt. Disc. Possible")
        else
            LineAmount := CustLedgerEntry."Remaining Amount";

        SaleLinePOS."Buffer Document Type" := CustLedgerEntry."Document Type";
        SaleLinePOS."Buffer Document No." := CustLedgerEntry."Document No.";
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Validate("Unit Price", LineAmount);
        SaleLinePOS.Description := StrSubstNo(TextBalance, CustLedgerEntry.Description);
        SaleLinePOS.Modify;
    end;

    procedure BufferInit(var NPRTempBuffer: Record "NPR TEMP Buffer"; var TemplateCode: Code[50]; var i: Integer; DescriptionFieldNo: Integer; Description: Text[250]; Bold: Boolean; Color: Integer; Sel: Boolean; Indent: Integer)
    begin
        //bufferInit
        if i <= LastInteger then
            NPRTempBuffer.Get(TemplateCode, i)
        else begin
            NPRTempBuffer.Init;
            NPRTempBuffer.Template := TemplateCode;
            NPRTempBuffer."Line No." := i;
            NPRTempBuffer.Insert;
            LastInteger := i;
        end;

        case DescriptionFieldNo of
            1:
                begin
                    NPRTempBuffer.Description := Description;
                    NPRTempBuffer.Bold := Bold;
                    NPRTempBuffer.Color := Color;
                    NPRTempBuffer.Sel := Sel;
                    NPRTempBuffer.Indent := Indent;
                end;
            2:
                begin
                    NPRTempBuffer."Description 2" := Description;
                    NPRTempBuffer."Bold 2" := Bold;
                    NPRTempBuffer."Color 2" := Color;
                    NPRTempBuffer."Sel 2" := Sel;
                    NPRTempBuffer."Indent 2" := Indent;
                end;
            3:
                begin
                    NPRTempBuffer."Description 3" := Description;
                    NPRTempBuffer."Bold 3" := Bold;
                    NPRTempBuffer."Color 3" := Color;
                    NPRTempBuffer."Sel 3" := Sel;
                    NPRTempBuffer."Indent 3" := Indent;
                end;
            4:
                begin
                    NPRTempBuffer."Description 4" := Description;
                    NPRTempBuffer."Bold 4" := Bold;
                    NPRTempBuffer."Color 4" := Color;
                    NPRTempBuffer."Sel 4" := Sel;
                    NPRTempBuffer."Indent 4" := Indent;
                end;
            5:
                begin
                    NPRTempBuffer."Description 5" := Description;
                    NPRTempBuffer."Bold 5" := Bold;
                    NPRTempBuffer."Color 5" := Color;
                    NPRTempBuffer."Sel 5" := Sel;
                    NPRTempBuffer."Indent 5" := Indent;
                end;
        end;

        NPRTempBuffer.Modify;
    end;

    procedure CalcPaymentRounding(RegisterNo: Code[10]) RoundingPrecision: Decimal
    var
        Register: Record "NPR Register";
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        //beregnAfrunding
        Register.Get(RegisterNo);
        PaymentTypePOS.Get(Register."Primary Payment Type");
        RoundingPrecision := Round(PaymentTypePOS."Rounding Precision" / 2, 0.001, '=');
    end;

    procedure DeleteCustomerLine(var SalePOS: Record "NPR Sale POS")
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Customer No. Line", true);
        SaleLinePOS.DeleteAll(true);
    end;

    procedure GetPaymentType(var PaymentTypePOS: Record "NPR Payment Type POS"; var Register: Record "NPR Register"; PaymentCode: Code[10]): Boolean
    begin
        //GetPaymentType
        PaymentTypePOS.Reset;
        PaymentTypePOS.SetRange("No.", PaymentCode);
        PaymentTypePOS.SetRange("Register No.", Register."Register No.");
        if PaymentTypePOS.Find('-') then
            exit(true);

        PaymentTypePOS.SetRange("Register No.");
        if PaymentTypePOS.Find('-') then
            exit(true);

        exit(false);
    end;

    procedure GetSalesStats(var SalePOS: Record "NPR Sale POS"; var HeadingText: Text[250]; var NPRTempBuffer: Record "NPR TEMP Buffer")
    var
        Txt001: Label 'Sales statistics';
        SalePOSStatistics: Page "NPR Sale POS - Statistics";
    begin
        //hentVisEkspStat()
        HeadingText := Txt001;
        SalePOSStatistics.SetRecord(SalePOS);
        SalePOSStatistics.Initialize(0);
        SalePOSStatistics.GetSaleLineStat(NPRTempBuffer);
    end;

    procedure GetTurnoverStats(var SalePOS: Record "NPR Sale POS"; var HeadingText: Text[250]; var NPRTempBuffer: Record "NPR TEMP Buffer")
    var
        Txt001: Label 'Turnover statistics';
        TurnoverStatistics: Page "NPR Turnover Statistics";
    begin
        //hentVisOmsStat
        Clear(TurnoverStatistics);
        Clear(NPRTempBuffer);
        TurnoverStatistics.Init();
        TurnoverStatistics.GetTurnoverStat(NPRTempBuffer);
        HeadingText := Txt001;
    end;

    procedure ImportSalesTicket(var SalePOS: Record "NPR Sale POS"; var ValidationCode: Code[50])
    var
        Text001: Label 'Type in the receipt number to be imported';
        Text002: Label 'MATCH';
        Text003: Label 'Type receipt no. first!';
        Text004: Label 'Receipt No.';
        Text005: Label 'not found!';
        AuditRoll: Record "NPR Audit Roll";
        SaleLinePOS: Record "NPR Sale Line POS";
        LineNo: Integer;
    begin
        if ValidationCode = '' then begin
            // TODO: CTRLUPGRADE - The block below must be refactored to not use Marshaller
            Error('CTRLUPGRADE');
            /*
            if not POSEventMarshaller.NumPadCode(Text001, ValidationCode, true, false) then begin
                ValidationCode := '';
                Error('');
            end;
            */
        end;
        if ValidationCode = '' then begin
            Error(Text003);
        end;

        AuditRoll.Reset;
        AuditRoll.SetRange("Sales Ticket No.", ValidationCode);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetFilter(Quantity, '>%1', 0);
        if not AuditRoll.FindSet then begin
            ValidationCode := '';
            Error(Text004 + ' ' + ValidationCode + ' ' + Text005);
        end;

        SalePOS."Retursalg Bonnummer" := ValidationCode;
        SalePOS.Modify;
        Commit;
        Clear(SaleLinePOS);
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast then;
        LineNo := SaleLinePOS."Line No.";

        repeat
            LineNo += 10000;
            SaleLinePOS.Init;
            SaleLinePOS.Validate("Register No.", SalePOS."Register No.");
            SaleLinePOS.Validate("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.Validate("Line No.", LineNo);
            SaleLinePOS.Validate(Date, Today);
            SaleLinePOS.Validate(Type, AuditRoll.Type);
            SaleLinePOS.Validate("No.", AuditRoll."No.");
            SaleLinePOS.Validate(Quantity, -AuditRoll.Quantity);
            SaleLinePOS.Validate("Unit Price", AuditRoll."Unit Price");
            SaleLinePOS.Validate("Variant Code", AuditRoll."Variant Code");
            if AuditRoll."Line Discount %" <> 0 then
                SaleLinePOS.Validate("Discount %", AuditRoll."Line Discount %");
            if AuditRoll."Line Discount Amount" <> 0 then
                SaleLinePOS.Validate("Discount Amount", AuditRoll."Line Discount Amount");
            SaleLinePOS.Insert(true);
        until AuditRoll.Next = 0;

        ValidationCode := '';
    end;

    procedure InfoCustomer(var SalePOS: Record "NPR Sale POS"; var HeadingText: Text[250]; var NPRTempBuffer: Record "NPR TEMP Buffer") CommentLineExists: Boolean
    var
        Cust: Record Customer;
        CommentLine: Record "Comment Line";
        i: Integer;
        Txt002: Label 'Comments';
        Contact: Record Contact;
        Txt004: Label 'Basic data';
        Utility: Codeunit "NPR Utility";
        TemplateCode: Code[50];
    begin
        //getCustInfo
        case SalePOS."Customer Type" of
            SalePOS."Customer Type"::Ord:
                begin
                    Cust.Get(SalePOS."Customer No.");
                    Cust.CalcFields(Balance);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Txt004, true, 0, true, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust."Search Name"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Cust."Search Name", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust.Address), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Cust.Address, false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust."Address 2"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Cust."Address 2", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust."Post Code"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Cust."Post Code", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust.City), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Cust.City, false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust."Country/Region Code"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Cust."Country/Region Code", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust."Phone No."), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Cust."Phone No.", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust."Credit Limit (LCY)"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Format(Cust."Credit Limit (LCY)"), false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust.Blocked), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Format(Cust.Blocked), false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Cust.FieldCaption(Cust.Balance), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Utility.FormatDec2Text(Cust.Balance, 2), false, 0, false, 0);

                    /* COMMENTS */
                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Txt002, true, 0, true, 0);

                    CommentLine.Reset;
                    CommentLine.SetRange("Table Name", CommentLine."Table Name"::Customer);
                    CommentLine.SetRange("No.", Cust."No.");
                    CommentLineExists := false;
                    if CommentLine.Find('-') then
                        repeat
                            i += 1;
                            BufferInit(NPRTempBuffer, TemplateCode, i, 1, CommentLine.Comment, false, 0, false, 0);
                            BufferInit(NPRTempBuffer, TemplateCode, i, 2, Format(CommentLine.Date), false, 0, false, 0);
                            CommentLineExists := true;
                        until (CommentLine.Next = 0);
                end;
            SalePOS."Customer Type"::Cash:
                begin
                    Contact.Get(SalePOS."Customer No.");

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Txt004, true, 0, true, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact."No."), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact."No.", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact.Name), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact.Name, false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact."Search Name"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact."Search Name", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact.Address), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact.Address, false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact."Address 2"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact."Address 2", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact."Post Code"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact."Post Code", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact.City), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact.City, false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact."Country/Region Code"), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact."Country/Region Code", false, 0, false, 0);

                    i += 1;
                    BufferInit(NPRTempBuffer, TemplateCode, i, 1, Contact.FieldCaption(Contact."Phone No."), true, 0, false, 0);
                    BufferInit(NPRTempBuffer, TemplateCode, i, 2, Contact."Phone No.", false, 0, false, 0);
                end;
        end;

    end;

    procedure ItemLedgerEntries(SourceType: Option Customer,"Cash Customer"; SourceNo: Code[20])
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Txt001: Label 'You must choose a customer number';
    begin
        //ItemLedgerEntries
        if SourceNo = '' then
            Error(Txt001);

        ItemLedgerEntry.SetRange("Source No.", SourceNo);
        PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRegisterOpen(Register: Record "NPR Register")
    begin
    end;

    procedure Round2Payment(PaymentTypePOS: Record "NPR Payment Type POS"; Amount: Decimal): Decimal
    begin
        //Round2Payment
        if PaymentTypePOS."Rounding Precision" = 0 then
            exit(Amount);

        exit(Round(Amount, PaymentTypePOS."Rounding Precision", '='));
    end;

    procedure SaleDebit(var SalePOS: Record "NPR Sale POS"; var SalesHeader: Record "Sales Header" temporary; var ValidationText: Code[20]; Internal: Boolean): Boolean
    var
        Customer: Record Customer;
        RetailSetup: Record "NPR Retail Setup";
        POSCheckCrLimit: Codeunit "NPR POS-Check Cr. Limit";
        "Filter": Code[20];
        SaleLinePOS: Record "NPR Sale Line POS";
    begin

        Commit;
        RetailSetup.Get;
        Filter := ValidationText;
        ValidationText := '';
        if not LookupCustomer(Internal, Filter, Customer) then
            exit(false);

        DeleteCustomerLine(SalePOS);
        SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Ord);
        SalePOS.Validate("Customer No.", Customer."No.");

        if RetailSetup."Customer Credit Level Warning" then begin
            RetailFormCodeGlobal.CreateSalesHeader(SalePOS, SalesHeader);
            Commit;
            if not POSCheckCrLimit.SalesHeaderPOSCheck(SalesHeader) then begin
                DeleteCustomerLine(SalePOS);
                SalePOS."Customer No." := '';
                RetailFormCodeGlobal.CreateSalesHeader(SalePOS, SalesHeader);
                SalePOS.Validate("Customer No.");
            end;
        end;

        SalePOS.Modify;
        Commit;

        AskRefAtt(SalePOS, true);

        SalePOS.Modify;
        ValidationText := '';
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter(Quantity, '<>0');
        if SaleLinePOS.FindSet(true, false) then
            repeat
                SaleLinePOS.Validate(Quantity);
                SaleLinePOS.Modify(true);
            until SaleLinePOS.Next = 0;
        exit(true);
    end;

    procedure SaleCashCustomer(var SalePOS: Record "NPR Sale POS"; var SalesHeader: Record "Sales Header" temporary; var SearchText: Code[20])
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        Customer: Record Customer;
        Register: Record "NPR Register";
        Contact: Record Contact;
        AuditRoll: Record "NPR Audit Roll";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TouchScreenCRMContacts: Page "NPR Touch Screen: CRM Contacts";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        //salgKontantKunde
        SalesInvoiceHeader.Reset;
        Customer.Reset;
        AuditRoll.Reset;
        SalesHeader.Reset;
        Clear(RetailSalesCode);
        Clear(GenJnlPostLine);
        SaleLinePOS.Reset;

        Commit;

        Register.Get(SalePOS."Register No.");

        if SearchText = '' then begin
            Contact.Reset;
            if SearchText <> '' then begin
                Contact.SetCurrentKey("Search Name");
                Contact.SetFilter("Search Name", '%1', '*@' + SearchText + '*');
            end else
                Contact.Reset;
            SearchText := '';
            TouchScreenCRMContacts.SetRecord(Contact);
            TouchScreenCRMContacts.LookupMode(true);
            if PAGE.RunModal(PAGE::"NPR Touch Screen: CRM Contacts", Contact) = ACTION::LookupOK then begin
                DeleteCustomerLine(SalePOS);
                SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Cash);
                SalePOS.Validate("Customer No.", Contact."No.");
            end else
                if TouchScreenCRMContacts.LookupOk then begin
                    DeleteCustomerLine(SalePOS);
                    TouchScreenCRMContacts.GetRecord(Contact);
                    SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Cash);
                    SalePOS.Validate("Customer No.", Contact."No.");
                end;
        end else begin
            SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Cash);
            SalePOS.Validate("Customer No.", SearchText);
        end;

        AskRefAtt(SalePOS, true);

        SalePOS.Modify;

        SearchText := '';
    end;

    procedure TestRegisterRegistration(var SalePOS: Record "NPR Sale POS") ret: Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        Item: Record Item;
        Txt001: Label 'You have to put a Serial Number on %1 !';
    begin
        //testkasseregistrering()

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.Find('-') then
            repeat
                if (SaleLinePOS."Sale Type" = SaleLinePOS."Sale Type"::Sale) and
                  (SaleLinePOS.Type = SaleLinePOS.Type::Item) then begin
                    Item.Get(SaleLinePOS."No.");
                    if Item."Costing Method" = Item."Costing Method"::Specific then
                        if SaleLinePOS."Serial No." = '' then
                            Error(Txt001, SaleLinePOS.Description);
                end;
            until SaleLinePOS.Next = 0;
        SaleLinePOS.Reset;
    end;

    procedure TestSalesDate()
    var
        AuditRoll: Record "NPR Audit Roll";
        Txt002: Label 'System date error - %1! Sales can not be made from this register, because of not closed sales on date %2.';
    begin
        //TjekdatoEKSPEDITION
        if WorkDate <> Today then begin
            WorkDate := Today;
        end;
        AuditRoll.Init;
        AuditRoll.SetCurrentKey("Sale Date");
        AuditRoll.SetFilter("Sale Date", '%1..', Today + 1);
        if not AuditRoll.IsEmpty then
            Error(Txt002, Today, AuditRoll.GetRangeMin("Sale Date"));
    end;

    local procedure InitFilterFields(TableId: Integer; var TempField: Record "Field" temporary)
    var
        Customer: Record Customer;
        Item: Record Item;
        LookupTemplate: Record "NPR Lookup Template";
        LookupTemplateLine: Record "NPR Lookup Template Line";
    begin
        TempField.DeleteAll;

        LookupTemplateLine.SetRange("Lookup Template Table No.", TableId);
        LookupTemplateLine.SetFilter("Field No.", '>%1', 0);
        LookupTemplateLine.SetRange(Searchable, true);
        if LookupTemplate.Get(TableId) and LookupTemplateLine.FindSet then begin
            repeat
                if not TempField.Get(LookupTemplateLine."Lookup Template Table No.", LookupTemplateLine."Field No.") then begin
                    TempField.Init;
                    TempField.TableNo := LookupTemplateLine."Lookup Template Table No.";
                    TempField."No." := LookupTemplateLine."Field No.";
                    TempField.Insert;
                end;
            until LookupTemplateLine.Next = 0;
            exit;
        end;
        case TableId of
            DATABASE::Item:
                begin
                    TempField.Init;
                    TempField.TableNo := DATABASE::Item;
                    TempField."No." := Item.FieldNo("No.");
                    TempField.Insert;

                    TempField.Init;
                    TempField.TableNo := DATABASE::Item;
                    TempField."No." := Item.FieldNo(Description);
                    TempField.Insert;
                end;
            DATABASE::Customer:
                begin
                    TempField.Init;
                    TempField.TableNo := DATABASE::Customer;
                    TempField."No." := Customer.FieldNo("No.");
                    TempField.Insert;

                    TempField.Init;
                    TempField.TableNo := DATABASE::Customer;
                    TempField."No." := Customer.FieldNo(Name);
                    TempField.Insert;
                end;
        end;
    end;

    procedure SetupTempCustomer(SearchString: Text; var TempCustomer: Record Customer temporary): Boolean
    var
        Customer: Record Customer;
        TempField: Record "Field" temporary;
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if SearchString = '' then
            exit(false);

        TempCustomer.DeleteAll;

        InitFilterFields(DATABASE::Customer, TempField);
        TempField.FindSet;
        repeat
            Clear(Customer);
            RecRef.GetTable(Customer);
            FieldRef := RecRef.Field(TempField."No.");
            FieldRef.SetFilter('@*' + ConvertStr(SearchString, ' ', '*') + '*');
            RecRef.SetTable(Customer);

            if Customer.FindSet then
                repeat
                    if not TempCustomer.Get(Customer."No.") then begin
                        TempCustomer.Init;
                        TempCustomer := Customer;
                        TempCustomer.Insert;
                    end;
                until Customer.Next = 0;
        until TempField.Next = 0;

        exit(true);
    end;

    local procedure SetupTempCustomerStaff(var TempCust: Record Customer temporary)
    var
        Cust: Record Customer;
        RetailSetup: Record "NPR Retail Setup";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(TempCust);
        if not RecRef.IsTemporary then
            exit;

        TempCust.DeleteAll;

        if not RetailSetup.Get then
            exit;

        Cust.Reset;
        Cust.SetFilter("Customer Price Group", '%1&<>%2', RetailSetup."Staff Price Group", '');
        if Cust.FindSet then
            repeat
                TempCust.Init;
                TempCust := Cust;
                TempCust.Insert;
            until Cust.Next = 0;

        Cust.Reset;
        Cust.SetFilter("Customer Disc. Group", '%1&<>%2', RetailSetup."Staff Disc. Group", '');
        if not Cust.FindSet then
            exit;

        if Cust.FindSet then
            repeat
                if not TempCust.Get(Cust."No.") then begin
                    TempCust.Init;
                    TempCust := Cust;
                    TempCust.Insert;
                end;
            until Cust.Next = 0;
    end;

    procedure GetLastSaleInfo("Register No.": Code[10]; var Total: Decimal; var PaymentAmountTotal: Decimal; var LastSaleDate: Text[30]; var ReturnAmountTotal: Decimal; var ReceiptNo: Text[30]): Boolean
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        //getLastSaleRightCol
        AuditRoll.SetRange("Register No.", "Register No.");
        AuditRoll.SetFilter("Sale Type", '<>%1', AuditRoll."Sale Type"::"Open/Close");
        AuditRoll.SetFilter(Type, '<>%1', AuditRoll.Type::Cancelled);
        AuditRoll.SetRange("Sale Date", Today);
        if AuditRoll.FindLast() then begin
            AuditRoll.SetRange(Type);
            AuditRoll.SetFilter("Sale Type", '%1|%2', AuditRoll."Sale Type"::Sale, AuditRoll."Sale Type"::Deposit);
            AuditRoll.SetRange("Sales Ticket No.", AuditRoll."Sales Ticket No.");
            if AuditRoll.FindSet() then
                repeat
                    Total += AuditRoll."Amount Including VAT";
                until AuditRoll.Next = 0;
            AuditRoll.SetRange(Type, AuditRoll.Type::Payment);
            AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Payment);
            AuditRoll.SetFilter("Amount Including VAT", '>%1', 0);
            if AuditRoll.FindSet() then
                repeat
                    PaymentAmountTotal += AuditRoll."Amount Including VAT"
                until AuditRoll.Next = 0;
            AuditRoll.SetFilter("Amount Including VAT", '<%1', 0);
            if AuditRoll.FindSet() then
                repeat
                    ReturnAmountTotal += AuditRoll."Amount Including VAT";
                until AuditRoll.Next = 0;
            LastSaleDate := Format(AuditRoll."Sale Date") + ' | ' + Format(AuditRoll."Closing Time");
            ReceiptNo := AuditRoll."Sales Ticket No.";
        end;
    end;

    local procedure LookupCustomer(Internal: Boolean; "Filter": Code[20]; var Cust: Record Customer): Boolean
    var
        Cust2: Record Customer;
        RetailSetup: Record "NPR Retail Setup";
        TempCust: Record Customer temporary;
        TouchEventSubscribers: Codeunit "NPR Touch - Event Subscribers";
        // TODO: CTRLUPGRADE - references a removed unused codeunit
        //POSWebUIMgt: Codeunit "POS Web UI Management";
        RecRef: RecordRef;
        CustNo: Text;
    begin
        RetailSetup.Get;
        // TODO: CTRLUPGRADE - The block below cannot be done that way in Transcendence. You must invoke FrontEnd.SetOption request, and set the "EanBox" option to "".
        /*
        if Filter <> '' then
            POSEventMarshaller.ClearEanBoxText();
        */

        if Internal then begin
            SetupTempCustomerStaff(TempCust);

            if RetailSetup."Use NAV Lookup in POS" then begin
                if PAGE.RunModal(PAGE::"NPR Touch Screen: Customers", TempCust) <> ACTION::LookupOK then
                    exit(false);

                Cust := TempCust;
                exit(true);
            end;

            RecRef.GetTable(TempCust);
        end else
            if Filter <> '' then begin
                SetupTempCustomer(Filter, TempCust);

                if RetailSetup."Use NAV Lookup in POS" then begin
                    if PAGE.RunModal(PAGE::"NPR Touch Screen: Customers", TempCust) <> ACTION::LookupOK then
                        exit(false);

                    Cust := TempCust;
                    exit(true);
                end;

                RecRef.GetTable(TempCust);
            end else begin
                if RetailSetup."Use NAV Lookup in POS" then
                    exit(PAGE.RunModal(PAGE::"NPR Touch Screen: Customers", Cust) = ACTION::LookupOK);

                RecRef.GetTable(Cust);
            end;

        // TODO: CTRLUPGRADE - uses old Standard feature not yet supported on Transcendence
        ERROR('CTRLUPGRADE');
        /*
        POSWebUIMgt.ConfigureLookupTemplate(Template, RecRef);
        TouchEventSubscribers.ConfigureCustomer();
        BindSubscription(TouchEventSubscribers);
        CustNo := POSEventMarshaller.Lookup(Cust.TableCaption, Template, RecRef, true, true, PAGE::"Customer Card");
        */

        if CustNo = '' then
            exit(false);

        Cust2.SetPosition(CustNo);
        if not Cust2.Find then
            exit(false);

        Cust := Cust2;
        exit(true);
    end;
}
