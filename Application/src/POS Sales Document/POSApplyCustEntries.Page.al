page 6014493 "NPR POS Apply Cust. Entries"
{
    Caption = 'Apply Customer Entries';
    DataCaptionFields = "Customer No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "Cust. Ledger Entry";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("ApplyingCustLedgEntry.""Posting Date"""; ApplyingCustLedgEntry."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("ApplyingCustLedgEntry.""Document Type"""; ApplyingCustLedgEntry."Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("ApplyingCustLedgEntry.""Document No."""; ApplyingCustLedgEntry."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field(ApplyingCustomerNo; ApplyingCustLedgEntry."Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(ApplyingDescription; ApplyingCustLedgEntry.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("ApplyingCustLedgEntry.""Currency Code"""; ApplyingCustLedgEntry."Currency Code")
                {
                    ApplicationArea = All;
                    Caption = 'Currency Code';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("ApplyingCustLedgEntry.Amount"; ApplyingCustLedgEntry.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("ApplyingCustLedgEntry.""Remaining Amount"""; ApplyingCustLedgEntry."Remaining Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Remaining Amount';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Applies-to ID"; "Applies-to ID")
                {
                    ApplicationArea = All;
                    Visible = "Applies-to IDVisible";
                    ToolTip = 'Specifies the value of the Applies-to ID field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Original Amount"; "Original Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Original Amount field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Remaining Amount field';
                }
                field("CalcApplnRemainingAmount(""Remaining Amount"")"; CalcApplnRemainingAmount("Remaining Amount"))
                {
                    ApplicationArea = All;
                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Remaining Amount';
                    ToolTip = 'Specifies the value of the Appln. Remaining Amount field';
                }
                field("Amount to Apply"; "Amount to Apply")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount to Apply field';

                    trigger OnValidate()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);

                        if (xRec."Amount to Apply" = 0) or ("Amount to Apply" = 0) and
                           (ApplnType = ApplnType::"Applies-to ID")
                        then
                            SetCustApplId;
                        Get("Entry No.");
                        AmounttoApplyOnAfterValidate;
                    end;
                }
                field("CalcApplnAmounttoApply(""Amount to Apply"")"; CalcApplnAmounttoApply("Amount to Apply"))
                {
                    ApplicationArea = All;
                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Amount to Apply';
                    ToolTip = 'Specifies the value of the Appln. Amount to Apply field';
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the value of the Due Date field';
                }
                field("Pmt. Discount Date"; "Pmt. Discount Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pmt. Discount Date field';

                    trigger OnValidate()
                    begin
                        RecalcApplnAmount;
                    end;
                }
                field("Pmt. Disc. Tolerance Date"; "Pmt. Disc. Tolerance Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pmt. Disc. Tolerance Date field';
                }
                field("Original Pmt. Disc. Possible"; "Original Pmt. Disc. Possible")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Original Pmt. Disc. Possible field';
                }
                field("Remaining Pmt. Disc. Possible"; "Remaining Pmt. Disc. Possible")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining Pmt. Disc. Possible field';

                    trigger OnValidate()
                    begin
                        RecalcApplnAmount;
                    end;
                }
                field("CalcApplnRemainingAmount(""Remaining Pmt. Disc. Possible"")"; CalcApplnRemainingAmount("Remaining Pmt. Disc. Possible"))
                {
                    ApplicationArea = All;
                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Pmt. Disc. Possible';
                    ToolTip = 'Specifies the value of the Appln. Pmt. Disc. Possible field';
                }
                field("Max. Payment Tolerance"; "Max. Payment Tolerance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max. Payment Tolerance field';
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field(Positive; Positive)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Positive field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
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
                            ApplicationArea = All;
                            Editable = false;
                            ShowCaption = false;
                            TableRelation = Currency;
                            ToolTip = 'Specifies the value of the ApplnCurrencyCode field';
                        }
                    }
                    group(Control1903098801)
                    {
                        Caption = 'Amount to Apply';
                        field(AmountToApply; AppliedAmount)
                        {
                            ApplicationArea = All;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Amount to Apply';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Amount to Apply field';
                        }
                    }
                    group("Pmt. Disc. Amount")
                    {
                        Caption = 'Pmt. Disc. Amount';
                        field("-PmtDiscAmount"; -PmtDiscAmount)
                        {
                            ApplicationArea = All;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Pmt. Disc. Amount';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Pmt. Disc. Amount field';
                        }
                    }
                    group(Rounding)
                    {
                        Caption = 'Rounding';
                        field(ApplnRounding; ApplnRounding)
                        {
                            ApplicationArea = All;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Rounding';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Rounding field';
                        }
                    }
                    group("Applied Amount")
                    {
                        Caption = 'Applied Amount';
                        field(AppliedAmount; AppliedAmount + (-PmtDiscAmount) + ApplnRounding)
                        {
                            ApplicationArea = All;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Applied Amount';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Applied Amount field';
                        }
                    }
                    group("Available Amount")
                    {
                        Caption = 'Available Amount';
                        field(ApplyingAmount; ApplyingAmount)
                        {
                            ApplicationArea = All;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Available Amount';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Available Amount field';
                        }
                    }
                    group(Balance)
                    {
                        Caption = 'Balance';
                        field(ControlBalance; AppliedAmount + (-PmtDiscAmount) + ApplyingAmount + ApplnRounding)
                        {
                            ApplicationArea = All;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Balance';
                            Editable = false;
                            ToolTip = 'Specifies the value of the Balance field';
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
                ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Reminder/Fin. Charge Entries action';
                }
                action("Applied E&ntries")
                {
                    Caption = 'Applied E&ntries';
                    Image = Approve;
                    RunObject = Page "Applied Customer Entries";
                    RunPageOnRec = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Applied E&ntries action';
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Dimensions action';

                    trigger OnAction()
                    begin
                        ShowDimensions;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Detailed &Ledger Entries action';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Set Applies-to ID action';

                    trigger OnAction()
                    begin
                        if (CalcType = CalcType::GenJnlLine) and (ApplnType = ApplnType::"Applies-to Doc. No.") then
                            Error(CannotSetAppliesToIDErr);

                        SetCustApplId;
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Only Selected Entries to Be Applied action';

                    trigger OnAction()
                    begin
                        ShowAppliedEntries := not ShowAppliedEntries;
                        if ShowAppliedEntries then begin
                            if CalcType = CalcType::GenJnlLine then
                                SetRange("Applies-to ID", GenJnlLine."Applies-to ID")
                            else begin
                                CustEntryApplID := UserId;
                                if CustEntryApplID = '' then
                                    CustEntryApplID := '***';
                                SetRange("Applies-to ID", CustEntryApplID);
                            end;
                        end else
                            SetRange("Applies-to ID");
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
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

                trigger OnAction()
                begin
                    Navigate.SetDoc("Posting Date", "Document No.");
                    Navigate.Run;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if ApplnType = ApplnType::"Applies-to Doc. No." then
            CalcApplnAmount;
    end;

    trigger OnAfterGetRecord()
    begin
        StyleTxt := SetStyle;
    end;

    trigger OnInit()
    begin
        "Applies-to IDVisible" := true;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);
        if "Applies-to ID" <> xRec."Applies-to ID" then
            CalcApplnAmount;
        exit(false);
    end;

    trigger OnOpenPage()
    begin
        if CalcType = CalcType::Direct then begin
            Cust.Get("Customer No.");
            ApplnCurrencyCode := Cust."Currency Code";
            FindApplyingEntry;
        end;

        "Applies-to IDVisible" := ApplnType <> ApplnType::"Applies-to Doc. No.";

        GLSetup.Get;

        if ApplnType = ApplnType::"Applies-to Doc. No." then
            CalcApplnAmount;
        PostingDone := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then
            LookupOKOnPush;
        if ApplnType = ApplnType::"Applies-to Doc. No." then begin
            if OK and (ApplyingCustLedgEntry."Posting Date" < "Posting Date") then begin
                OK := false;
                Error(
                  EarlierPostingDateErr, ApplyingCustLedgEntry."Document Type", ApplyingCustLedgEntry."Document No.",
                  "Document Type", "Document No.");
            end;
            if OK then begin
                if "Amount to Apply" = 0 then
                    "Amount to Apply" := "Remaining Amount";
                CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);
            end;
        end;
        if (CalcType = CalcType::Direct) and not OK and not PostingDone then begin
            Rec := ApplyingCustLedgEntry;
            "Applying Entry" := false;
            "Applies-to ID" := '';
            "Amount to Apply" := 0;
            CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", Rec);
        end;
    end;

    var
        ApplyingCustLedgEntry: Record "Cust. Ledger Entry" temporary;
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
        Text002: Label 'You must select an applying entry before you can post the application.';
        ShowAppliedEntries: Boolean;
        Text003: Label 'You must post the application from the window where you entered the applying entry.';
        CannotSetAppliesToIDErr: Label 'You cannot set Applies-to ID while selecting Applies-to Doc. No.';
        OK: Boolean;
        EarlierPostingDateErr: Label 'You cannot apply and post an entry to an entry with an earlier posting date.\\Instead, post the document of type %1 with the number %2 and then apply it to the document of type %3 with the number %4.';
        PostingDone: Boolean;
        [InDataSet]
        "Applies-to IDVisible": Boolean;
        Text012: Label 'The application was successfully posted.';
        Text013: Label 'The %1 entered must not be before the %1 on the %2.';
        Text019: Label 'Post application process has been canceled.';
        SaleLinePOS: Record "NPR POS Sale Line";
        BalancePOSLine: Boolean;

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

        SetApplyingCustLedgEntry;
    end;

    procedure SetSales(NewSalesHeader: Record "Sales Header"; var NewCustLedgEntry: Record "Cust. Ledger Entry"; ApplnTypeSelect: Integer)
    var
        TotalAdjCostLCY: Decimal;
    begin
        SalesHeader := NewSalesHeader;
        CopyFilters(NewCustLedgEntry);

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

        SetApplyingCustLedgEntry;
    end;

    procedure SetService(NewServHeader: Record "Service Header"; var NewCustLedgEntry: Record "Cust. Ledger Entry"; ApplnTypeSelect: Integer)
    var
        ServAmountsMgt: Codeunit "Serv-Amounts Mgt.";
        TotalAdjCostLCY: Decimal;
    begin
        ServHeader := NewServHeader;
        CopyFilters(NewCustLedgEntry);

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

        SetApplyingCustLedgEntry;
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
                    ApplyingCustLedgEntry."Entry No." := 1;
                    ApplyingCustLedgEntry."Posting Date" := SalesHeader."Posting Date";
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then
                        ApplyingCustLedgEntry."Document Type" := SalesHeader."Document Type"::"Credit Memo"
                    else
                        ApplyingCustLedgEntry."Document Type" := SalesHeader."Document Type";
                    ApplyingCustLedgEntry."Document No." := SalesHeader."No.";
                    ApplyingCustLedgEntry."Customer No." := SalesHeader."Bill-to Customer No.";
                    ApplyingCustLedgEntry.Description := SalesHeader."Posting Description";
                    ApplyingCustLedgEntry."Currency Code" := SalesHeader."Currency Code";
                    if ApplyingCustLedgEntry."Document Type" = ApplyingCustLedgEntry."Document Type"::"Credit Memo" then begin
                        ApplyingCustLedgEntry.Amount := -TotalSalesLine."Amount Including VAT";
                        ApplyingCustLedgEntry."Remaining Amount" := -TotalSalesLine."Amount Including VAT";
                    end else begin
                        ApplyingCustLedgEntry.Amount := TotalSalesLine."Amount Including VAT";
                        ApplyingCustLedgEntry."Remaining Amount" := TotalSalesLine."Amount Including VAT";
                    end;
                    CalcApplnAmount;
                end;
            CalcType::ServHeader:
                begin
                    ApplyingCustLedgEntry."Entry No." := 1;
                    ApplyingCustLedgEntry."Posting Date" := ServHeader."Posting Date";
                    ApplyingCustLedgEntry."Document Type" := ServHeader."Document Type";
                    ApplyingCustLedgEntry."Document No." := ServHeader."No.";
                    ApplyingCustLedgEntry."Customer No." := ServHeader."Bill-to Customer No.";
                    ApplyingCustLedgEntry.Description := ServHeader."Posting Description";
                    ApplyingCustLedgEntry."Currency Code" := ServHeader."Currency Code";
                    if ApplyingCustLedgEntry."Document Type" = ApplyingCustLedgEntry."Document Type"::"Credit Memo" then begin
                        ApplyingCustLedgEntry.Amount := -TotalServLine."Amount Including VAT";
                        ApplyingCustLedgEntry."Remaining Amount" := -TotalServLine."Amount Including VAT";
                    end else begin
                        ApplyingCustLedgEntry.Amount := TotalServLine."Amount Including VAT";
                        ApplyingCustLedgEntry."Remaining Amount" := TotalServLine."Amount Including VAT";
                    end;
                    CalcApplnAmount;
                end;
            CalcType::Direct:
                begin
                    if "Applying Entry" then begin
                        if ApplyingCustLedgEntry."Entry No." <> 0 then
                            CustLedgEntry := ApplyingCustLedgEntry;
                        "CustEntry-Edit".Run(Rec);
                        if "Applies-to ID" = '' then
                            SetCustApplId;
                        CalcFields(Amount);
                        ApplyingCustLedgEntry := Rec;
                        if CustLedgEntry."Entry No." <> 0 then begin
                            Rec := CustLedgEntry;
                            "Applying Entry" := false;
                            SetCustApplId;
                        end;
                        SetFilter("Entry No.", '<> %1', ApplyingCustLedgEntry."Entry No.");
                        ApplyingAmount := ApplyingCustLedgEntry."Remaining Amount";
                        ApplnDate := ApplyingCustLedgEntry."Posting Date";
                        ApplnCurrencyCode := ApplyingCustLedgEntry."Currency Code";
                    end;
                    CalcApplnAmount;
                end;
            CalcType::GenJnlLine:
                begin
                    ApplyingCustLedgEntry."Entry No." := 1;
                    ApplyingCustLedgEntry."Posting Date" := GenJnlLine."Posting Date";
                    ApplyingCustLedgEntry."Document Type" := GenJnlLine."Document Type";
                    ApplyingCustLedgEntry."Document No." := GenJnlLine."Document No.";
                    if GenJnlLine."Bal. Account Type" = GenJnlLine."Account Type"::Customer then begin
                        ApplyingCustLedgEntry."Customer No." := GenJnlLine."Bal. Account No.";
                        Customer.Get(ApplyingCustLedgEntry."Customer No.");
                        ApplyingCustLedgEntry.Description := Customer.Name;
                    end else begin
                        ApplyingCustLedgEntry."Customer No." := GenJnlLine."Account No.";
                        ApplyingCustLedgEntry.Description := GenJnlLine.Description;
                    end;
                    ApplyingCustLedgEntry."Currency Code" := GenJnlLine."Currency Code";
                    ApplyingCustLedgEntry.Amount := GenJnlLine.Amount;
                    ApplyingCustLedgEntry."Remaining Amount" := GenJnlLine.Amount;
                    CalcApplnAmount;
                end;
        end;
    end;

    procedure SetCustApplId()
    begin
        if (CalcType = CalcType::GenJnlLine) and (ApplyingCustLedgEntry."Posting Date" < "Posting Date") then
            Error(
              EarlierPostingDateErr, ApplyingCustLedgEntry."Document Type", ApplyingCustLedgEntry."Document No.",
              "Document Type", "Document No.");

        if ApplyingCustLedgEntry."Entry No." <> 0 then
            GenJnlApply.CheckAgainstApplnCurrency(
              ApplnCurrencyCode, "Currency Code", GenJnlLine."Account Type"::Customer, true);

        CustLedgEntry.Copy(Rec);
        CurrPage.SetSelectionFilter(CustLedgEntry);

        CustEntrySetApplID.SetApplId(CustLedgEntry, ApplyingCustLedgEntry, GetAppliesToID);

        CalcApplnAmount;
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
                    FindAmountRounding;
                    CustEntryApplID := UserId;
                    if CustEntryApplID = '' then
                        CustEntryApplID := '***';

                    CustLedgEntry := ApplyingCustLedgEntry;

                    AppliedCustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
                    AppliedCustLedgEntry.SetRange("Customer No.", "Customer No.");
                    AppliedCustLedgEntry.SetRange(Open, true);
                    AppliedCustLedgEntry.SetRange("Applies-to ID", CustEntryApplID);

                    if ApplyingCustLedgEntry."Entry No." <> 0 then begin
                        CustLedgEntry.CalcFields("Remaining Amount");
                        AppliedCustLedgEntry.SetFilter("Entry No.", '<>%1', ApplyingCustLedgEntry."Entry No.");
                    end;

                    HandlChosenEntries(0,
                      CustLedgEntry."Remaining Amount",
                      CustLedgEntry."Currency Code",
                      CustLedgEntry."Posting Date");
                end;
            CalcType::GenJnlLine:
                begin
                    FindAmountRounding;
                    if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Customer then
                        ExchAccGLJnlLine.Run(GenJnlLine);

                    case ApplnType of
                        ApplnType::"Applies-to Doc. No.":
                            begin
                                AppliedCustLedgEntry := Rec;
                                with AppliedCustLedgEntry do begin
                                    CalcFields("Remaining Amount");
                                    if "Currency Code" <> ApplnCurrencyCode then begin
                                        "Remaining Amount" :=
                                          CurrExchRate.ExchangeAmtFCYToFCY(
                                            ApplnDate, "Currency Code", ApplnCurrencyCode, "Remaining Amount");
                                        "Remaining Pmt. Disc. Possible" :=
                                          CurrExchRate.ExchangeAmtFCYToFCY(
                                            ApplnDate, "Currency Code", ApplnCurrencyCode, "Remaining Pmt. Disc. Possible");
                                        "Amount to Apply" :=
                                          CurrExchRate.ExchangeAmtFCYToFCY(
                                            ApplnDate, "Currency Code", ApplnCurrencyCode, "Amount to Apply");
                                    end;

                                    if "Amount to Apply" <> 0 then
                                        AppliedAmount := Round("Amount to Apply", AmountRoundingPrecision)
                                    else
                                        AppliedAmount := Round("Remaining Amount", AmountRoundingPrecision);

                                    if PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(
                                         GenJnlLine, AppliedCustLedgEntry, 0, false) and
                                       ((Abs(GenJnlLine.Amount) + ApplnRoundingPrecision >=
                                         Abs(AppliedAmount - "Remaining Pmt. Disc. Possible")) or
                                        (GenJnlLine.Amount = 0))
                                    then
                                        PmtDiscAmount := "Remaining Pmt. Disc. Possible";

                                    if not DifferentCurrenciesInAppln then
                                        DifferentCurrenciesInAppln := ApplnCurrencyCode <> "Currency Code";
                                end;
                                CheckRounding;
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
                    FindAmountRounding;

                    case ApplnType of
                        ApplnType::"Applies-to Doc. No.":
                            begin
                                AppliedCustLedgEntry := Rec;
                                with AppliedCustLedgEntry do begin
                                    CalcFields("Remaining Amount");

                                    if "Currency Code" <> ApplnCurrencyCode then
                                        "Remaining Amount" :=
                                          CurrExchRate.ExchangeAmtFCYToFCY(
                                            ApplnDate, "Currency Code", ApplnCurrencyCode, "Remaining Amount");

                                    AppliedAmount := Round("Remaining Amount", AmountRoundingPrecision);

                                    if not DifferentCurrenciesInAppln then
                                        DifferentCurrenciesInAppln := ApplnCurrencyCode <> "Currency Code";
                                end;
                                CheckRounding;
                            end;
                        ApplnType::"Applies-to ID":
                            begin
                                AppliedCustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
                                if CalcType = CalcType::SalesHeader then
                                    AppliedCustLedgEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.")
                                else
                                    AppliedCustLedgEntry.SetRange("Customer No.", ServHeader."Bill-to Customer No.");
                                AppliedCustLedgEntry.SetRange(Open, true);
                                AppliedCustLedgEntry.SetRange("Applies-to ID", GetAppliesToID);

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
        if ApplnCurrencyCode = "Currency Code" then
            exit(Amount);

        if ApplnDate = 0D then
            ApplnDate := "Posting Date";
        ApplnRemainingAmount :=
          CurrExchRate.ApplnExchangeAmtFCYToFCY(
            ApplnDate, "Currency Code", ApplnCurrencyCode, Amount, ValidExchRate);
        exit(ApplnRemainingAmount);
    end;

    local procedure CalcApplnAmounttoApply(AmounttoApply: Decimal): Decimal
    var
        ApplnAmounttoApply: Decimal;
    begin
        ValidExchRate := true;

        if ApplnCurrencyCode = "Currency Code" then
            exit(AmounttoApply);

        if ApplnDate = 0D then
            ApplnDate := "Posting Date";
        ApplnAmounttoApply :=
          CurrExchRate.ApplnExchangeAmtFCYToFCY(
            ApplnDate, "Currency Code", ApplnCurrencyCode, AmounttoApply, ValidExchRate);
        exit(ApplnAmounttoApply);
    end;

    local procedure FindAmountRounding()
    begin
        if ApplnCurrencyCode = '' then begin
            Currency.Init;
            Currency.Code := '';
            Currency.InitRoundingPrecision;
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
            if ApplnCurrencyCode <> "Currency Code" then
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
            CustLedgEntry.SetRange("Customer No.", "Customer No.");
            CustLedgEntry.SetRange("Applies-to ID", CustEntryApplID);
            CustLedgEntry.SetRange(Open, true);
            CustLedgEntry.SetRange("Applying Entry", true);
            if CustLedgEntry.FindFirst then begin
                CustLedgEntry.CalcFields(Amount, "Remaining Amount");
                ApplyingCustLedgEntry := CustLedgEntry;
                SetFilter("Entry No.", '<>%1', CustLedgEntry."Entry No.");
                ApplyingAmount := CustLedgEntry."Remaining Amount";
                ApplnDate := CustLedgEntry."Posting Date";
                ApplnCurrencyCode := CustLedgEntry."Currency Code";
            end;
            CalcApplnAmount;
        end;
    end;

    local procedure HandlChosenEntries(Type: Option Direct,GenJnlLine,SalesHeader; CurrentAmount: Decimal; CurrencyCode: Code[10]; "Posting Date": Date)
    var
        AppliedCustLedgEntryTemp: Record "Cust. Ledger Entry" temporary;
        PossiblePmtDisc: Decimal;
        OldPmtDisc: Decimal;
        CorrectionAmount: Decimal;
        CanUseDisc: Boolean;
        FromZeroGenJnl: Boolean;
    begin
        if AppliedCustLedgEntry.FindSet(false, false) then begin
            repeat
                AppliedCustLedgEntryTemp := AppliedCustLedgEntry;
                AppliedCustLedgEntryTemp.Insert;
            until AppliedCustLedgEntry.Next = 0;
        end else
            exit;

        FromZeroGenJnl := (CurrentAmount = 0) and (Type = Type::GenJnlLine);

        repeat
            if not FromZeroGenJnl then
                AppliedCustLedgEntryTemp.SetRange(Positive, CurrentAmount < 0);
            if AppliedCustLedgEntryTemp.FindFirst then begin
                ExchangeAmountsOnLedgerEntry(Type, CurrencyCode, AppliedCustLedgEntryTemp, "Posting Date");

                case Type of
                    Type::Direct:
                        CanUseDisc := PaymentToleranceMgt.CheckCalcPmtDiscCust(CustLedgEntry, AppliedCustLedgEntryTemp, 0, false, false);
                    Type::GenJnlLine:
                        CanUseDisc := PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(GenJnlLine2, AppliedCustLedgEntryTemp, 0, false)
                    else
                        CanUseDisc := false;
                end;

                if CanUseDisc and
                   (Abs(AppliedCustLedgEntryTemp."Amount to Apply") >= Abs(AppliedCustLedgEntryTemp."Remaining Amount" -
                      AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible"))
                then begin
                    if (Abs(CurrentAmount) > Abs(AppliedCustLedgEntryTemp."Remaining Amount" -
                          AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible"))
                    then begin
                        PmtDiscAmount := PmtDiscAmount + AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible";
                        CurrentAmount := CurrentAmount + AppliedCustLedgEntryTemp."Remaining Amount" -
                          AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible";
                    end else
                        if (Abs(CurrentAmount) = Abs(AppliedCustLedgEntryTemp."Remaining Amount" -
                              AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible"))
                        then begin
                            PmtDiscAmount := PmtDiscAmount + AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible" + PossiblePmtDisc;
                            CurrentAmount := CurrentAmount + AppliedCustLedgEntryTemp."Remaining Amount" -
                              AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible" - PossiblePmtDisc;
                            PossiblePmtDisc := 0;
                            AppliedAmount := AppliedAmount + CorrectionAmount;
                        end else
                            if FromZeroGenJnl then begin
                                PmtDiscAmount := PmtDiscAmount + AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible";
                                CurrentAmount := CurrentAmount +
                                  AppliedCustLedgEntryTemp."Remaining Amount" - AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible";
                            end else begin
                                if (CurrentAmount + AppliedCustLedgEntryTemp."Remaining Amount" >= 0) <> (CurrentAmount >= 0) then begin
                                    PmtDiscAmount := PmtDiscAmount + PossiblePmtDisc;
                                    AppliedAmount := AppliedAmount + CorrectionAmount;
                                end;
                                CurrentAmount := CurrentAmount + AppliedCustLedgEntryTemp."Remaining Amount" -
                                  AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible";
                                PossiblePmtDisc := AppliedCustLedgEntryTemp."Remaining Pmt. Disc. Possible";
                            end;
                end else begin
                    if ((CurrentAmount - PossiblePmtDisc + AppliedCustLedgEntryTemp."Amount to Apply") * CurrentAmount) <= 0 then begin
                        PmtDiscAmount := PmtDiscAmount + PossiblePmtDisc;
                        CurrentAmount := CurrentAmount - PossiblePmtDisc;
                        PossiblePmtDisc := 0;
                        AppliedAmount := AppliedAmount + CorrectionAmount;
                    end;
                    CurrentAmount := CurrentAmount + AppliedCustLedgEntryTemp."Amount to Apply";
                end;
            end else begin
                AppliedCustLedgEntryTemp.SetRange(Positive);
                AppliedCustLedgEntryTemp.FindFirst;
                ExchangeAmountsOnLedgerEntry(Type, CurrencyCode, AppliedCustLedgEntryTemp, "Posting Date");
            end;

            if OldPmtDisc <> PmtDiscAmount then
                AppliedAmount := AppliedAmount + AppliedCustLedgEntryTemp."Remaining Amount"
            else
                AppliedAmount := AppliedAmount + AppliedCustLedgEntryTemp."Amount to Apply";
            OldPmtDisc := PmtDiscAmount;

            if PossiblePmtDisc <> 0 then
                CorrectionAmount := AppliedCustLedgEntryTemp."Remaining Amount" - AppliedCustLedgEntryTemp."Amount to Apply"
            else
                CorrectionAmount := 0;

            if not DifferentCurrenciesInAppln then
                DifferentCurrenciesInAppln := ApplnCurrencyCode <> AppliedCustLedgEntryTemp."Currency Code";

            AppliedCustLedgEntryTemp.Delete;
            AppliedCustLedgEntryTemp.SetRange(Positive);

        until not AppliedCustLedgEntryTemp.FindFirst;
        PmtDiscAmount += PossiblePmtDisc;
        CheckRounding;
    end;

    local procedure AmounttoApplyOnAfterValidate()
    begin
        if ApplnType <> ApplnType::"Applies-to Doc. No." then begin
            CalcApplnAmount;
            CurrPage.Update(false);
        end;
    end;

    local procedure RecalcApplnAmount()
    begin
        CurrPage.Update(true);
        CalcApplnAmount;
    end;

    local procedure LookupOKOnPush()
    begin
        OK := true;
    end;

    procedure SetSalesLine(NewGenJnlLine: Record "NPR POS Sale Line"; ApplnTypeSelect: Integer)
    begin
            SaleLinePOS := NewGenJnlLine;
            BalancePOSLine := true;

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
            CalculateCurrency := ApplyingCustLedgEntry."Entry No." <> 0
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
