page 6014493 "NPR POS Apply Cust. Entries"
{
    Caption = 'Apply Customer Entries';
    DataCaptionFields = "Customer No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;

    SourceTable = "Cust. Ledger Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ApplyingPostingDate; TempApplyingCustLedgEntry."Posting Date")
                {

                    Caption = 'Posting Date';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field(ApplyingDocumentType; TempApplyingCustLedgEntry."Document Type")
                {

                    Caption = 'Document Type';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field(ApplyingDocumentNo; TempApplyingCustLedgEntry."Document No.")
                {

                    Caption = 'Document No.';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field(ApplyingCustomerNo; TempApplyingCustLedgEntry."Customer No.")
                {

                    Caption = 'Customer No.';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field(ApplyingDescription; TempApplyingCustLedgEntry.Description)
                {

                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(ApplyingCurrencyCode; TempApplyingCustLedgEntry."Currency Code")
                {

                    Caption = 'Currency Code';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field(ApplyingAmount2; TempApplyingCustLedgEntry.Amount)
                {

                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(ApplyingRemainingAmount; TempApplyingCustLedgEntry."Remaining Amount")
                {

                    Caption = 'Remaining Amount';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                    ApplicationArea = NPRRetail;
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Applies-to ID"; Rec."Applies-to ID")
                {

                    Visible = "Applies-to IDVisible";
                    ToolTip = 'Specifies the value of the Applies-to ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Type"; Rec."Document Type")
                {

                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Original Amount"; Rec."Original Amount")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Original Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Appln. Remaining Amount"; CalcApplnRemainingAmount(Rec."Remaining Amount"))
                {

                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Remaining Amount';
                    ToolTip = 'Specifies the value of the Appln. Remaining Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount to Apply"; Rec."Amount to Apply")
                {

                    ToolTip = 'Specifies the value of the Amount to Apply field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", Rec);
                        if (xRec."Amount to Apply" = 0) or (Rec."Amount to Apply" = 0) and
                           (ApplnType = ApplnType::"Applies-to ID")
                        then
                            SetCustApplId();
                        Rec.Get(Rec."Entry No.");
                        AmounttoApplyOnAfterValidate();
                    end;
                }
                field("CalcApplnAmounttoApply(Amount to Apply)"; CalcApplnAmounttoApply(Rec."Amount to Apply"))
                {

                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Amount to Apply';
                    ToolTip = 'Specifies the value of the Appln. Amount to Apply field';
                    ApplicationArea = NPRRetail;
                }
                field("Due Date"; Rec."Due Date")
                {

                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Due Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {

                    ToolTip = 'Specifies the value of the Pmt. Discount Date field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RecalcApplnAmount();
                    end;
                }
                field("Pmt. Disc. Tolerance Date"; Rec."Pmt. Disc. Tolerance Date")
                {

                    ToolTip = 'Specifies the value of the Pmt. Disc. Tolerance Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Original Pmt. Disc. Possible"; Rec."Original Pmt. Disc. Possible")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Original Pmt. Disc. Possible field';
                    ApplicationArea = NPRRetail;
                }
                field("Remaining Pmt. Disc. Possible"; Rec."Remaining Pmt. Disc. Possible")
                {

                    ToolTip = 'Specifies the value of the Remaining Pmt. Disc. Possible field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        RecalcApplnAmount();
                    end;
                }
                field("CalcApplnRemainingAmount(Remaining Pmt. Disc. Possible)"; CalcApplnRemainingAmount(Rec."Remaining Pmt. Disc. Possible"))
                {

                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Pmt. Disc. Possible';
                    ToolTip = 'Specifies the value of the Appln. Pmt. Disc. Possible field';
                    ApplicationArea = NPRRetail;
                }
                field("Max. Payment Tolerance"; Rec."Max. Payment Tolerance")
                {

                    ToolTip = 'Specifies the value of the Max. Payment Tolerance field';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Open field';
                    ApplicationArea = NPRRetail;
                }
                field(Positive; Rec.Positive)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Positive field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Control41)
            {
                ShowCaption = false;
                fixed(Control1903222401)
                {
                    ShowCaption = false;
                    group("Appln. Currency")
                    {
                        Caption = 'Appln. Currency';
                        field(ApplnCurrencyCode; ApplnCurrencyCode)
                        {

                            Editable = false;
                            ShowCaption = false;
                            TableRelation = Currency;
                            ToolTip = 'Specifies the value of the ApplnCurrencyCode field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control1903098801)
                    {
                        Caption = 'Amount to Apply';
                        field(AmountToApply; AppliedAmount)
                        {

                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Amount to Apply';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Amount to Apply field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group("Pmt. Disc. Amount")
                    {
                        Caption = 'Pmt. Disc. Amount';
                        field("-PmtDiscAmount"; -PmtDiscAmount)
                        {

                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Pmt. Disc. Amount';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Pmt. Disc. Amount field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Rounding)
                    {
                        Caption = 'Rounding';
                        field(ApplnRounding; ApplnRounding)
                        {

                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Rounding';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Rounding field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group("Applied Amount")
                    {
                        Caption = 'Applied Amount';
                        field(AppliedAmount; AppliedAmount + (-PmtDiscAmount) + ApplnRounding)
                        {

                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Applied Amount';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Applied Amount field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group("Available Amount")
                    {
                        Caption = 'Available Amount';
                        field(ApplyingAmount; ApplyingAmount)
                        {

                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Available Amount';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Available Amount field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Balance)
                    {
                        Caption = 'Balance';
                        field(ControlBalance; AppliedAmount + (-PmtDiscAmount) + ApplyingAmount + ApplnRounding)
                        {

                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Balance';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Balance field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(Control1903096107; "Customer Ledger Entry FactBox")
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
                Visible = true;
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Ent&ry")
            {
                Caption = 'Ent&ry';
                Image = Entry;
                action("Reminder/Fin. Charge Entries")
                {
                    Caption = 'Reminder/Fin. Charge Entries';
                    Image = Reminder;
                    RunObject = Page "Reminder/Fin. Charge Entries";
                    RunPageLink = "Customer Entry No." = FIELD("Entry No.");
                    RunPageView = SORTING("Customer Entry No.");

                    ToolTip = 'Executes the Reminder/Fin. Charge Entries action';
                    ApplicationArea = NPRRetail;
                }
                action("Applied E&ntries")
                {
                    Caption = 'Applied E&ntries';
                    Image = Approve;
                    RunObject = Page "Applied Customer Entries";
                    RunPageOnRec = true;

                    ToolTip = 'Executes the Applied E&ntries action';
                    ApplicationArea = NPRRetail;
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    ToolTip = 'Executes the Dimensions action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Detailed &Ledger Entries")
                {
                    Caption = 'Detailed &Ledger Entries';
                    Image = View;
                    RunObject = Page "Detailed Cust. Ledg. Entries";
                    RunPageLink = "Cust. Ledger Entry No." = FIELD("Entry No.");
                    RunPageView = SORTING("Cust. Ledger Entry No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';

                    ToolTip = 'Executes the Detailed &Ledger Entries action';
                    ApplicationArea = NPRRetail;
                }
            }
            group("&Application")
            {
                Caption = '&Application';
                Image = Apply;
                action("Set Applies-to ID")
                {
                    Caption = 'Set Applies-to ID';
                    Image = SelectLineToApply;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F11';

                    ToolTip = 'Executes the Set Applies-to ID action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        if (CalcType = CalcType::GenJnlLine) and (ApplnType = ApplnType::"Applies-to Doc. No.") then
                            Error(CannotSetAppliesToIDErr);

                        SetCustApplId();
                    end;
                }
                separator("-")
                {
                    Caption = '-';
                }
                action("Show Only Selected Entries to Be Applied")
                {
                    Caption = 'Show Only Selected Entries to Be Applied';
                    Image = ShowSelected;

                    ToolTip = 'Executes the Show Only Selected Entries to Be Applied action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        ShowAppliedEntries := not ShowAppliedEntries;
                        if ShowAppliedEntries then begin
                            if CalcType = CalcType::GenJnlLine then
                                Rec.SetRange("Applies-to ID", GenJnlLine."Applies-to ID")
                            else begin
                                CustEntryApplID := UserId;
                                if CustEntryApplID = '' then
                                    CustEntryApplID := '***';
                                Rec.SetRange("Applies-to ID", CustEntryApplID);
                            end;
                        end else
                            Rec.SetRange("Applies-to ID");
                    end;
                }
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                ToolTip = 'Executes the &Navigate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if ApplnType = ApplnType::"Applies-to Doc. No." then
            CalcApplnAmount();
    end;

    trigger OnAfterGetRecord()
    begin
        StyleTxt := Rec.SetStyle();
    end;

    trigger OnInit()
    begin
        "Applies-to IDVisible" := true;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);
        if Rec."Applies-to ID" <> xRec."Applies-to ID" then
            CalcApplnAmount();
        exit(false);
    end;

    trigger OnOpenPage()
    begin
        if CalcType = CalcType::Direct then begin
            Cust.Get(Rec."Customer No.");
            ApplnCurrencyCode := Cust."Currency Code";
            FindApplyingEntry();
        end;

        "Applies-to IDVisible" := ApplnType <> ApplnType::"Applies-to Doc. No.";

        GLSetup.Get();

        if ApplnType = ApplnType::"Applies-to Doc. No." then
            CalcApplnAmount();
        PostingDone := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then
            LookupOKOnPush();
        if ApplnType = ApplnType::"Applies-to Doc. No." then begin
            if OK and (TempApplyingCustLedgEntry."Posting Date" < Rec."Posting Date") then begin
                OK := false;
                Error(
                  EarlierPostingDateErr, TempApplyingCustLedgEntry."Document Type", TempApplyingCustLedgEntry."Document No.",
                  Rec."Document Type", Rec."Document No.");
            end;
            if OK then begin
                if Rec."Amount to Apply" = 0 then
                    Rec."Amount to Apply" := Rec."Remaining Amount";
                CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);
            end;
        end;
        if (CalcType = CalcType::Direct) and not OK and not PostingDone then begin
            Rec := TempApplyingCustLedgEntry;
            Rec."Applying Entry" := false;
            Rec."Applies-to ID" := '';
            Rec."Amount to Apply" := 0;
            CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);
        end;
    end;

    var
        TempApplyingCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        ServHeader: Record "Service Header";
        Cust: Record Customer;
        CustLedgEntry: Record "Cust. Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        TotalServLine: Record "Service Line";
        TotalServLineLCY: Record "Service Line";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        SalesPost: Codeunit "Sales-Post";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        Navigate: Page Navigate;
        AppliedAmount: Decimal;
        ApplyingAmount: Decimal;
        PmtDiscAmount: Decimal;
        ApplnDate: Date;
        ApplnCurrencyCode: Code[10];
        ApplnRoundingPrecision: Decimal;
        ApplnRounding: Decimal;
        ApplnType: Option " ","Applies-to Doc. No.","Applies-to ID";
        AmountRoundingPrecision: Decimal;
        VATAmount: Decimal;
        VATAmountText: Text[30];
        StyleTxt: Text;
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        CalcType: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine;
        CustEntryApplID: Code[50];
        ValidExchRate: Boolean;
        DifferentCurrenciesInAppln: Boolean;
        ShowAppliedEntries: Boolean;
        CannotSetAppliesToIDErr: Label 'You cannot set Applies-to ID while selecting Applies-to Doc. No.';
        OK: Boolean;
        EarlierPostingDateErr: Label 'You cannot apply and post an entry to an entry with an earlier posting date.\\Instead, post the document of type %1 with the number %2 and then apply it to the document of type %3 with the number %4.';
        PostingDone: Boolean;
        [InDataSet]
        "Applies-to IDVisible": Boolean;
        SaleLinePOS: Record "NPR POS Sale Line";

    procedure SetGenJnlLine(NewGenJnlLine: Record "Gen. Journal Line"; ApplnTypeSelect: Integer)
    begin
        GenJnlLine := NewGenJnlLine;

        if GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer then
            ApplyingAmount := GenJnlLine.Amount;
        if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Customer then
            ApplyingAmount := -GenJnlLine.Amount;
        ApplnDate := GenJnlLine."Posting Date";
        ApplnCurrencyCode := GenJnlLine."Currency Code";
        CalcType := CalcType::GenJnlLine;

        case ApplnTypeSelect of
            GenJnlLine.FieldNo("Applies-to Doc. No."):
                ApplnType := ApplnType::"Applies-to Doc. No.";
            GenJnlLine.FieldNo("Applies-to ID"):
                ApplnType := ApplnType::"Applies-to ID";
        end;

        SetApplyingCustLedgEntry();
    end;

    procedure SetSales(NewSalesHeader: Record "Sales Header"; var NewCustLedgEntry: Record "Cust. Ledger Entry"; ApplnTypeSelect: Integer)
    var
        TotalAdjCostLCY: Decimal;
    begin
        SalesHeader := NewSalesHeader;
        Rec.CopyFilters(NewCustLedgEntry);

        SalesPost.SumSalesLines(
          SalesHeader, 0, TotalSalesLine, TotalSalesLineLCY,
          VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::"Return Order",
          SalesHeader."Document Type"::"Credit Memo":
                ApplyingAmount := -TotalSalesLine."Amount Including VAT"
            else
                ApplyingAmount := TotalSalesLine."Amount Including VAT";
        end;

        ApplnDate := SalesHeader."Posting Date";
        ApplnCurrencyCode := SalesHeader."Currency Code";
        CalcType := CalcType::SalesHeader;

        case ApplnTypeSelect of
            SalesHeader.FieldNo("Applies-to Doc. No."):
                ApplnType := ApplnType::"Applies-to Doc. No.";
            SalesHeader.FieldNo("Applies-to ID"):
                ApplnType := ApplnType::"Applies-to ID";
        end;

        SetApplyingCustLedgEntry();
    end;

    procedure SetService(NewServHeader: Record "Service Header"; var NewCustLedgEntry: Record "Cust. Ledger Entry"; ApplnTypeSelect: Integer)
    var
        ServAmountsMgt: Codeunit "Serv-Amounts Mgt.";
        TotalAdjCostLCY: Decimal;
    begin
        ServHeader := NewServHeader;
        Rec.CopyFilters(NewCustLedgEntry);

        ServAmountsMgt.SumServiceLines(
          ServHeader, 0, TotalServLine, TotalServLineLCY,
          VATAmount, VATAmountText, ProfitLCY, ProfitPct, TotalAdjCostLCY);

        case ServHeader."Document Type" of
            ServHeader."Document Type"::"Credit Memo":
                ApplyingAmount := -TotalServLine."Amount Including VAT"
            else
                ApplyingAmount := TotalServLine."Amount Including VAT";
        end;

        ApplnDate := ServHeader."Posting Date";
        ApplnCurrencyCode := ServHeader."Currency Code";
        CalcType := CalcType::ServHeader;

        case ApplnTypeSelect of
            ServHeader.FieldNo("Applies-to Doc. No."):
                ApplnType := ApplnType::"Applies-to Doc. No.";
            ServHeader.FieldNo("Applies-to ID"):
                ApplnType := ApplnType::"Applies-to ID";
        end;

        SetApplyingCustLedgEntry();
    end;

    procedure SetCustLedgEntry(NewCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        Rec := NewCustLedgEntry;
    end;

    procedure SetApplyingCustLedgEntry()
    var
        Customer: Record Customer;
        "CustEntry-Edit": Codeunit "Cust. Entry-Edit";
    begin
        case CalcType of
            CalcType::SalesHeader:
                begin
                    TempApplyingCustLedgEntry."Entry No." := 1;
                    TempApplyingCustLedgEntry."Posting Date" := SalesHeader."Posting Date";
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then
                        TempApplyingCustLedgEntry."Document Type" := SalesHeader."Document Type"::"Credit Memo"
                    else
                        TempApplyingCustLedgEntry."Document Type" := SalesHeader."Document Type";
                    TempApplyingCustLedgEntry."Document No." := SalesHeader."No.";
                    TempApplyingCustLedgEntry."Customer No." := SalesHeader."Bill-to Customer No.";
                    TempApplyingCustLedgEntry.Description := SalesHeader."Posting Description";
                    TempApplyingCustLedgEntry."Currency Code" := SalesHeader."Currency Code";
                    if TempApplyingCustLedgEntry."Document Type" = TempApplyingCustLedgEntry."Document Type"::"Credit Memo" then begin
                        TempApplyingCustLedgEntry.Amount := -TotalSalesLine."Amount Including VAT";
                        TempApplyingCustLedgEntry."Remaining Amount" := -TotalSalesLine."Amount Including VAT";
                    end else begin
                        TempApplyingCustLedgEntry.Amount := TotalSalesLine."Amount Including VAT";
                        TempApplyingCustLedgEntry."Remaining Amount" := TotalSalesLine."Amount Including VAT";
                    end;
                    CalcApplnAmount();
                end;
            CalcType::ServHeader:
                begin
                    TempApplyingCustLedgEntry."Entry No." := 1;
                    TempApplyingCustLedgEntry."Posting Date" := ServHeader."Posting Date";
                    TempApplyingCustLedgEntry."Document Type" := ServHeader."Document Type";
                    TempApplyingCustLedgEntry."Document No." := ServHeader."No.";
                    TempApplyingCustLedgEntry."Customer No." := ServHeader."Bill-to Customer No.";
                    TempApplyingCustLedgEntry.Description := ServHeader."Posting Description";
                    TempApplyingCustLedgEntry."Currency Code" := ServHeader."Currency Code";
                    if TempApplyingCustLedgEntry."Document Type" = TempApplyingCustLedgEntry."Document Type"::"Credit Memo" then begin
                        TempApplyingCustLedgEntry.Amount := -TotalServLine."Amount Including VAT";
                        TempApplyingCustLedgEntry."Remaining Amount" := -TotalServLine."Amount Including VAT";
                    end else begin
                        TempApplyingCustLedgEntry.Amount := TotalServLine."Amount Including VAT";
                        TempApplyingCustLedgEntry."Remaining Amount" := TotalServLine."Amount Including VAT";
                    end;
                    CalcApplnAmount();
                end;
            CalcType::Direct:
                begin
                    if Rec."Applying Entry" then begin
                        if TempApplyingCustLedgEntry."Entry No." <> 0 then
                            CustLedgEntry := TempApplyingCustLedgEntry;
                        "CustEntry-Edit".Run(Rec);
                        if Rec."Applies-to ID" = '' then
                            SetCustApplId();
                        Rec.CalcFields(Amount);
                        TempApplyingCustLedgEntry := Rec;
                        if CustLedgEntry."Entry No." <> 0 then begin
                            Rec := CustLedgEntry;
                            Rec."Applying Entry" := false;
                            SetCustApplId();
                        end;
                        Rec.SetFilter("Entry No.", '<> %1', TempApplyingCustLedgEntry."Entry No.");
                        ApplyingAmount := TempApplyingCustLedgEntry."Remaining Amount";
                        ApplnDate := TempApplyingCustLedgEntry."Posting Date";
                        ApplnCurrencyCode := TempApplyingCustLedgEntry."Currency Code";
                    end;
                    CalcApplnAmount();
                end;
            CalcType::GenJnlLine:
                begin
                    TempApplyingCustLedgEntry."Entry No." := 1;
                    TempApplyingCustLedgEntry."Posting Date" := GenJnlLine."Posting Date";
                    TempApplyingCustLedgEntry."Document Type" := GenJnlLine."Document Type";
                    TempApplyingCustLedgEntry."Document No." := GenJnlLine."Document No.";
                    if GenJnlLine."Bal. Account Type" = GenJnlLine."Account Type"::Customer then begin
                        TempApplyingCustLedgEntry."Customer No." := GenJnlLine."Bal. Account No.";
                        Customer.Get(TempApplyingCustLedgEntry."Customer No.");
                        TempApplyingCustLedgEntry.Description := Customer.Name;
                    end else begin
                        TempApplyingCustLedgEntry."Customer No." := GenJnlLine."Account No.";
                        TempApplyingCustLedgEntry.Description := GenJnlLine.Description;
                    end;
                    TempApplyingCustLedgEntry."Currency Code" := GenJnlLine."Currency Code";
                    TempApplyingCustLedgEntry.Amount := GenJnlLine.Amount;
                    TempApplyingCustLedgEntry."Remaining Amount" := GenJnlLine.Amount;
                    CalcApplnAmount();
                end;
        end;
    end;

    procedure SetCustApplId()
    begin
        if (CalcType = CalcType::GenJnlLine) and (TempApplyingCustLedgEntry."Posting Date" < Rec."Posting Date") then
            Error(
              EarlierPostingDateErr, TempApplyingCustLedgEntry."Document Type", TempApplyingCustLedgEntry."Document No.",
              Rec."Document Type", Rec."Document No.");

        if TempApplyingCustLedgEntry."Entry No." <> 0 then
            GenJnlApply.CheckAgainstApplnCurrency(
              ApplnCurrencyCode, Rec."Currency Code", GenJnlLine."Account Type"::Customer, true);

        CustLedgEntry.Copy(Rec);
        CurrPage.SetSelectionFilter(CustLedgEntry);

        CustEntrySetApplID.SetApplId(CustLedgEntry, TempApplyingCustLedgEntry, GetAppliesToID());

        CalcApplnAmount();
    end;

    local procedure GetAppliesToID() AppliesToID: Code[50]
    begin
        case CalcType of
            CalcType::GenJnlLine:
                AppliesToID := GenJnlLine."Applies-to ID";
            CalcType::SalesHeader:
                AppliesToID := SalesHeader."Applies-to ID";
            CalcType::ServHeader:
                AppliesToID := ServHeader."Applies-to ID";
        end;
    end;

    procedure CalcApplnAmount()
    var
        ExchAccGLJnlLine: Codeunit "Exchange Acc. G/L Journal Line";
    begin
        AppliedAmount := 0;
        PmtDiscAmount := 0;
        DifferentCurrenciesInAppln := false;

        case CalcType of
            CalcType::Direct:
                begin
                    FindAmountRounding();
                    CustEntryApplID := UserId;
                    if CustEntryApplID = '' then
                        CustEntryApplID := '***';

                    CustLedgEntry := TempApplyingCustLedgEntry;

                    AppliedCustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
                    AppliedCustLedgEntry.SetRange("Customer No.", Rec."Customer No.");
                    AppliedCustLedgEntry.SetRange(Open, true);
                    AppliedCustLedgEntry.SetRange("Applies-to ID", CustEntryApplID);

                    if TempApplyingCustLedgEntry."Entry No." <> 0 then begin
                        CustLedgEntry.CalcFields("Remaining Amount");
                        AppliedCustLedgEntry.SetFilter("Entry No.", '<>%1', TempApplyingCustLedgEntry."Entry No.");
                    end;

                    HandlChosenEntries(0,
                      CustLedgEntry."Remaining Amount",
                      CustLedgEntry."Currency Code",
                      CustLedgEntry."Posting Date");
                end;
            CalcType::GenJnlLine:
                begin
                    FindAmountRounding();
                    if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Customer then
                        ExchAccGLJnlLine.Run(GenJnlLine);

                    case ApplnType of
                        ApplnType::"Applies-to Doc. No.":
                            begin
                                AppliedCustLedgEntry := Rec;
                                AppliedCustLedgEntry.CalcFields("Remaining Amount");
                                if AppliedCustLedgEntry."Currency Code" <> ApplnCurrencyCode then begin
                                    AppliedCustLedgEntry."Remaining Amount" :=
                                      CurrExchRate.ExchangeAmtFCYToFCY(
                                        ApplnDate, AppliedCustLedgEntry."Currency Code", ApplnCurrencyCode, AppliedCustLedgEntry."Remaining Amount");
                                    AppliedCustLedgEntry."Remaining Pmt. Disc. Possible" :=
                                      CurrExchRate.ExchangeAmtFCYToFCY(
                                        ApplnDate, AppliedCustLedgEntry."Currency Code", ApplnCurrencyCode, AppliedCustLedgEntry."Remaining Pmt. Disc. Possible");
                                    AppliedCustLedgEntry."Amount to Apply" :=
                                      CurrExchRate.ExchangeAmtFCYToFCY(
                                        ApplnDate, AppliedCustLedgEntry."Currency Code", ApplnCurrencyCode, AppliedCustLedgEntry."Amount to Apply");
                                end;

                                if AppliedCustLedgEntry."Amount to Apply" <> 0 then
                                    AppliedAmount := Round(AppliedCustLedgEntry."Amount to Apply", AmountRoundingPrecision)
                                else
                                    AppliedAmount := Round(AppliedCustLedgEntry."Remaining Amount", AmountRoundingPrecision);

                                if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(
                                     GenJnlLine, AppliedCustLedgEntry, 0, false) and
                                   ((Abs(GenJnlLine.Amount) + ApplnRoundingPrecision >=
                                     Abs(AppliedAmount - AppliedCustLedgEntry."Remaining Pmt. Disc. Possible")) or
                                    (GenJnlLine.Amount = 0))
                                then
                                    PmtDiscAmount := AppliedCustLedgEntry."Remaining Pmt. Disc. Possible";

                                if not DifferentCurrenciesInAppln then
                                    DifferentCurrenciesInAppln := ApplnCurrencyCode <> AppliedCustLedgEntry."Currency Code";
                                CheckRounding();
                            end;
                        ApplnType::"Applies-to ID":
                            begin
                                GenJnlLine2 := GenJnlLine;
                                AppliedCustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
                                AppliedCustLedgEntry.SetRange("Customer No.", GenJnlLine."Account No.");
                                AppliedCustLedgEntry.SetRange(Open, true);
                                AppliedCustLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");

                                HandlChosenEntries(1,
                                  GenJnlLine2.Amount,
                                  GenJnlLine2."Currency Code",
                                  GenJnlLine2."Posting Date");
                            end;
                    end;
                end;
            CalcType::SalesHeader, CalcType::ServHeader:
                begin
                    FindAmountRounding();

                    case ApplnType of
                        ApplnType::"Applies-to Doc. No.":
                            begin
                                AppliedCustLedgEntry := Rec;
                                AppliedCustLedgEntry.CalcFields("Remaining Amount");

                                if AppliedCustLedgEntry."Currency Code" <> ApplnCurrencyCode then
                                    AppliedCustLedgEntry."Remaining Amount" :=
                                      CurrExchRate.ExchangeAmtFCYToFCY(
                                        ApplnDate, AppliedCustLedgEntry."Currency Code", ApplnCurrencyCode, AppliedCustLedgEntry."Remaining Amount");

                                AppliedAmount := Round(AppliedCustLedgEntry."Remaining Amount", AmountRoundingPrecision);

                                if not DifferentCurrenciesInAppln then
                                    DifferentCurrenciesInAppln := ApplnCurrencyCode <> AppliedCustLedgEntry."Currency Code";
                                CheckRounding();
                            end;
                        ApplnType::"Applies-to ID":
                            begin
                                AppliedCustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
                                if CalcType = CalcType::SalesHeader then
                                    AppliedCustLedgEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.")
                                else
                                    AppliedCustLedgEntry.SetRange("Customer No.", ServHeader."Bill-to Customer No.");
                                AppliedCustLedgEntry.SetRange(Open, true);
                                AppliedCustLedgEntry.SetRange("Applies-to ID", GetAppliesToID());

                                HandlChosenEntries(2,
                                  ApplyingAmount,
                                  ApplnCurrencyCode,
                                  ApplnDate);
                            end;
                    end;
                end;
        end;
    end;

    local procedure CalcApplnRemainingAmount(Amount: Decimal): Decimal
    var
        ApplnRemainingAmount: Decimal;
    begin
        ValidExchRate := true;
        if ApplnCurrencyCode = Rec."Currency Code" then
            exit(Amount);

        if ApplnDate = 0D then
            ApplnDate := Rec."Posting Date";
        ApplnRemainingAmount :=
          CurrExchRate.ApplnExchangeAmtFCYToFCY(
            ApplnDate, Rec."Currency Code", ApplnCurrencyCode, Amount, ValidExchRate);
        exit(ApplnRemainingAmount);
    end;

    local procedure CalcApplnAmounttoApply(AmounttoApply: Decimal): Decimal
    var
        ApplnAmounttoApply: Decimal;
    begin
        ValidExchRate := true;

        if ApplnCurrencyCode = Rec."Currency Code" then
            exit(AmounttoApply);

        if ApplnDate = 0D then
            ApplnDate := Rec."Posting Date";
        ApplnAmounttoApply :=
          CurrExchRate.ApplnExchangeAmtFCYToFCY(
            ApplnDate, Rec."Currency Code", ApplnCurrencyCode, AmounttoApply, ValidExchRate);
        exit(ApplnAmounttoApply);
    end;

    local procedure FindAmountRounding()
    begin
        if ApplnCurrencyCode = '' then begin
            Currency.Init();
            Currency.Code := '';
            Currency.InitRoundingPrecision();
        end else
            if ApplnCurrencyCode <> Currency.Code then
                Currency.Get(ApplnCurrencyCode);

        AmountRoundingPrecision := Currency."Amount Rounding Precision";
    end;

    local procedure CheckRounding()
    begin
        ApplnRounding := 0;

        case CalcType of
            CalcType::SalesHeader, CalcType::ServHeader:
                exit;
            CalcType::GenJnlLine:
                if (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::Payment) and
                   (GenJnlLine."Document Type" <> GenJnlLine."Document Type"::Refund)
                then
                    exit;
        end;

        if ApplnCurrencyCode = '' then
            ApplnRoundingPrecision := GLSetup."Appln. Rounding Precision"
        else begin
            if ApplnCurrencyCode <> Rec."Currency Code" then
                Currency.Get(ApplnCurrencyCode);
            ApplnRoundingPrecision := Currency."Appln. Rounding Precision";
        end;

        if (Abs((AppliedAmount - PmtDiscAmount) + ApplyingAmount) <= ApplnRoundingPrecision) and DifferentCurrenciesInAppln then
            ApplnRounding := -((AppliedAmount - PmtDiscAmount) + ApplyingAmount);
    end;

    procedure GetCustLedgEntry(var CustLedgEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgEntry := Rec;
    end;

    local procedure FindApplyingEntry()
    begin
        if CalcType = CalcType::Direct then begin
            CustEntryApplID := UserId;
            if CustEntryApplID = '' then
                CustEntryApplID := '***';

            CustLedgEntry.SetCurrentKey("Customer No.", "Applies-to ID", Open);
            CustLedgEntry.SetRange("Customer No.", Rec."Customer No.");
            CustLedgEntry.SetRange("Applies-to ID", CustEntryApplID);
            CustLedgEntry.SetRange(Open, true);
            CustLedgEntry.SetRange("Applying Entry", true);
            if CustLedgEntry.FindFirst() then begin
                CustLedgEntry.CalcFields(Amount, "Remaining Amount");
                TempApplyingCustLedgEntry := CustLedgEntry;
                Rec.SetFilter("Entry No.", '<>%1', CustLedgEntry."Entry No.");
                ApplyingAmount := CustLedgEntry."Remaining Amount";
                ApplnDate := CustLedgEntry."Posting Date";
                ApplnCurrencyCode := CustLedgEntry."Currency Code";
            end;
            CalcApplnAmount();
        end;
    end;

    local procedure HandlChosenEntries(Type: Option Direct,GenJnlLine,SalesHeader; CurrentAmount: Decimal; CurrencyCode: Code[10]; "Posting Date": Date)
    var
        TempAppliedCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        PossiblePmtDisc: Decimal;
        OldPmtDisc: Decimal;
        CorrectionAmount: Decimal;
        CanUseDisc: Boolean;
        FromZeroGenJnl: Boolean;
    begin
        if AppliedCustLedgEntry.FindSet(false, false) then begin
            repeat
                TempAppliedCustLedgEntry := AppliedCustLedgEntry;
                TempAppliedCustLedgEntry.Insert();
            until AppliedCustLedgEntry.Next() = 0;
        end else
            exit;

        FromZeroGenJnl := (CurrentAmount = 0) and (Type = Type::GenJnlLine);

        repeat
            if not FromZeroGenJnl then
                TempAppliedCustLedgEntry.SetRange(Positive, CurrentAmount < 0);
            if TempAppliedCustLedgEntry.FindFirst() then begin
                ExchangeAmountsOnLedgerEntry(Type, CurrencyCode, TempAppliedCustLedgEntry, "Posting Date");

                case Type of
                    Type::Direct:
                        CanUseDisc := PaymentToleranceMgt.CheckCalcPmtDiscCust(CustLedgEntry, TempAppliedCustLedgEntry, 0, false, false);
                    Type::GenJnlLine:
                        CanUseDisc := PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(GenJnlLine2, TempAppliedCustLedgEntry, 0, false)
                    else
                        CanUseDisc := false;
                end;

                if CanUseDisc and
                   (Abs(TempAppliedCustLedgEntry."Amount to Apply") >= Abs(TempAppliedCustLedgEntry."Remaining Amount" -
                      TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible"))
                then begin
                    if (Abs(CurrentAmount) > Abs(TempAppliedCustLedgEntry."Remaining Amount" -
                          TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible"))
                    then begin
                        PmtDiscAmount := PmtDiscAmount + TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                        CurrentAmount := CurrentAmount + TempAppliedCustLedgEntry."Remaining Amount" -
                          TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                    end else
                        if (Abs(CurrentAmount) = Abs(TempAppliedCustLedgEntry."Remaining Amount" -
                              TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible"))
                        then begin
                            PmtDiscAmount := PmtDiscAmount + TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible" + PossiblePmtDisc;
                            CurrentAmount := CurrentAmount + TempAppliedCustLedgEntry."Remaining Amount" -
                              TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible" - PossiblePmtDisc;
                            PossiblePmtDisc := 0;
                            AppliedAmount := AppliedAmount + CorrectionAmount;
                        end else
                            if FromZeroGenJnl then begin
                                PmtDiscAmount := PmtDiscAmount + TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                                CurrentAmount := CurrentAmount +
                                  TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                            end else begin
                                if (CurrentAmount + TempAppliedCustLedgEntry."Remaining Amount" >= 0) <> (CurrentAmount >= 0) then begin
                                    PmtDiscAmount := PmtDiscAmount + PossiblePmtDisc;
                                    AppliedAmount := AppliedAmount + CorrectionAmount;
                                end;
                                CurrentAmount := CurrentAmount + TempAppliedCustLedgEntry."Remaining Amount" -
                                  TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                                PossiblePmtDisc := TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                            end;
                end else begin
                    if ((CurrentAmount - PossiblePmtDisc + TempAppliedCustLedgEntry."Amount to Apply") * CurrentAmount) <= 0 then begin
                        PmtDiscAmount := PmtDiscAmount + PossiblePmtDisc;
                        CurrentAmount := CurrentAmount - PossiblePmtDisc;
                        PossiblePmtDisc := 0;
                        AppliedAmount := AppliedAmount + CorrectionAmount;
                    end;
                    CurrentAmount := CurrentAmount + TempAppliedCustLedgEntry."Amount to Apply";
                end;
            end else begin
                TempAppliedCustLedgEntry.SetRange(Positive);
                TempAppliedCustLedgEntry.FindFirst();
                ExchangeAmountsOnLedgerEntry(Type, CurrencyCode, TempAppliedCustLedgEntry, "Posting Date");
            end;

            if OldPmtDisc <> PmtDiscAmount then
                AppliedAmount := AppliedAmount + TempAppliedCustLedgEntry."Remaining Amount"
            else
                AppliedAmount := AppliedAmount + TempAppliedCustLedgEntry."Amount to Apply";
            OldPmtDisc := PmtDiscAmount;

            if PossiblePmtDisc <> 0 then
                CorrectionAmount := TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Amount to Apply"
            else
                CorrectionAmount := 0;

            if not DifferentCurrenciesInAppln then
                DifferentCurrenciesInAppln := ApplnCurrencyCode <> TempAppliedCustLedgEntry."Currency Code";

            TempAppliedCustLedgEntry.Delete();
            TempAppliedCustLedgEntry.SetRange(Positive);

        until not TempAppliedCustLedgEntry.FindFirst();
        PmtDiscAmount += PossiblePmtDisc;
        CheckRounding();
    end;

    local procedure AmounttoApplyOnAfterValidate()
    begin
        if ApplnType <> ApplnType::"Applies-to Doc. No." then begin
            CalcApplnAmount();
            CurrPage.Update(false);
        end;
    end;

    local procedure RecalcApplnAmount()
    begin
        CurrPage.Update(true);
        CalcApplnAmount();
    end;

    local procedure LookupOKOnPush()
    begin
        OK := true;
    end;

    procedure SetSalesLine(NewGenJnlLine: Record "NPR POS Sale Line"; ApplnTypeSelect: Integer)
    begin
        SaleLinePOS := NewGenJnlLine;

        ApplnDate := SaleLinePOS.Date;
        ApplnCurrencyCode := SaleLinePOS."Currency Code";
        CalcType := CalcType::POSLine;

        case ApplnTypeSelect of
            SaleLinePOS.FieldNo("Buffer Document No."):
                ApplnType := ApplnType::"Applies-to Doc. No.";
            SaleLinePOS.FieldNo("Buffer ID"):
                begin
                    ApplnType := ApplnType::"Applies-to ID";
                    CustEntryApplID := NewGenJnlLine."Buffer ID"
                end;
        end;
    end;

    local procedure ExchangeAmountsOnLedgerEntry(Type: Option Direct,GenJnlLine,SalesHeader; CurrencyCode: Code[10]; var CalcCustLedgEntry: Record "Cust. Ledger Entry"; PostingDate: Date)
    var
        CalculateCurrency: Boolean;
    begin
        CalcCustLedgEntry.CalcFields("Remaining Amount");

        if Type = Type::Direct then
            CalculateCurrency := TempApplyingCustLedgEntry."Entry No." <> 0
        else
            CalculateCurrency := true;

        if (CurrencyCode <> CalcCustLedgEntry."Currency Code") and CalculateCurrency then begin
            CalcCustLedgEntry."Remaining Amount" :=
              CurrExchRate.ExchangeAmount(
                CalcCustLedgEntry."Remaining Amount",
                CalcCustLedgEntry."Currency Code",
                CurrencyCode, PostingDate);
            CalcCustLedgEntry."Remaining Pmt. Disc. Possible" :=
              CurrExchRate.ExchangeAmount(
                CalcCustLedgEntry."Remaining Pmt. Disc. Possible",
                CalcCustLedgEntry."Currency Code",
                CurrencyCode, PostingDate);
            CalcCustLedgEntry."Amount to Apply" :=
              CurrExchRate.ExchangeAmount(
                CalcCustLedgEntry."Amount to Apply",
                CalcCustLedgEntry."Currency Code",
                CurrencyCode, PostingDate);
        end;
    end;
}
