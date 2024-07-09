page 6014493 "NPR POS Apply Cust. Entries"
{
    Extensible = False;
    Caption = 'Apply Customer Entries';
    DataCaptionFields = "Customer No.";
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    PromotedActionCategories = 'New,Process,Report,Line,Entry';
    SourceTable = "Cust. Ledger Entry";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Not needed.';
                field(ApplyingPostingDate; TempApplyingCustLedgEntry."Posting Date")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Posting Date';
                    Editable = false;
                    ToolTip = 'Specifies the posting date of the entry to be applied. This date is used to find the correct exchange rate when applying entries in different currencies.';
                }
                field(ApplyingDocumentType; TempApplyingCustLedgEntry."Document Type")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Document Type';
                    Editable = false;
                    ToolTip = 'Specifies the document type of the entry to be applied.';
                }
                field(ApplyingDocumentNo; TempApplyingCustLedgEntry."Document No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Document No.';
                    Editable = false;
                    ToolTip = 'Specifies the document number of the entry to be applied.';
                }
                field(ApplyingCustomerNo; TempApplyingCustLedgEntry."Customer No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer No.';
                    Editable = false;
                    ToolTip = 'Specifies the customer number of the entry to be applied.';
                }
                field(ApplyingCustomerName; TempApplyingCustLedgEntry."Customer Name")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the customer name of the entry to be applied.';
                    Visible = CustNameVisible;
                }
                field(ApplyingDescription; TempApplyingCustLedgEntry.Description)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the description of the entry to be applied.';
                }
                field(ApplyingCurrencyCode; TempApplyingCustLedgEntry."Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Currency Code';
                    Editable = false;
                    ToolTip = 'Specifies the code for the currency that amounts are shown in.';
                }
                field(ApplyingAmount2; TempApplyingCustLedgEntry."Sales (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Amount';
                    Editable = false;
                    ToolTip = 'Specifies the amount on the entry to be applied.';
                }
                field(ApplyingRemainingAmount; TempApplyingCustLedgEntry."Profit (LCY)")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Remaining Amount';
                    Editable = false;
                    ToolTip = 'Specifies the remaining amount on the entry to be applied.';
                }
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field(AppliesToID; Rec."Applies-to ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ID of entries that will be applied to when you choose the Apply Entries action.';
                    Visible = AppliesToIDVisible;

                    trigger OnValidate()
                    begin
                        if (CalcType = CalcType::GenJnlLine) and (ApplnType = ApplnType::"Applies-to Doc. No.") then
                            Error(CannotSetAppliesToIDErr);

                        SetCustApplId(true);

                        CurrPage.Update(false);
                    end;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the customer entry''s posting date.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the document type that the customer entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the entry''s document number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the customer account number that the entry is linked to.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the customer name that the entry is linked to.';
                    Visible = CustNameVisible;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies a description of the customer entry.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the currency code for the amount on the line.';
                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the original entry.';
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the entry.';
                    Visible = false;
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the total of the ledger entries that represent debits.';
                    Visible = false;
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the total of the ledger entries that represent credits.';
                    Visible = false;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies the amount that remains to be applied to before the entry has been completely applied.';
                }
                field("Appln. Remaining Amount"; CalcApplnRemainingAmount(Rec."Remaining Amount"))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Remaining Amount';
                    ToolTip = 'Specifies the amount that remains to be applied to before the entry is totally applied to.';
                }
                field("Amount to Apply"; Rec."Amount to Apply")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the amount to apply.';

                    trigger OnValidate()
                    begin
                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", Rec);
                        if (xRec."Amount to Apply" = 0) or (Rec."Amount to Apply" = 0) and
                           ((ApplnType = ApplnType::"Applies-to ID") or (CalcType = CalcType::Direct))
                        then
                            SetCustApplId(false);
                        Rec.Get(Rec."Entry No.");
                        AmountToApplyOnAfterValidate();
                    end;
                }
                field(ApplnAmountToApply; CalcApplnAmountToApply(Rec."Amount to Apply"))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Amount to Apply';
                    ToolTip = 'Specifies the amount to apply.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the due date on the entry.';
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date on which the amount in the entry must be paid for a payment discount to be granted.';

                    trigger OnValidate()
                    begin
                        RecalcApplnAmount();
                    end;
                }
                field("Pmt. Disc. Tolerance Date"; Rec."Pmt. Disc. Tolerance Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the last date the amount in the entry must be paid in order for a payment discount tolerance to be granted.';
                }
                field("Original Pmt. Disc. Possible"; Rec."Original Pmt. Disc. Possible")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the discount that the customer can obtain if the entry is applied to before the payment discount date.';
                    Visible = false;
                }
                field("Remaining Pmt. Disc. Possible"; Rec."Remaining Pmt. Disc. Possible")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the remaining payment discount which can be received if the payment is made before the payment discount date.';

                    trigger OnValidate()
                    begin
                        RecalcApplnAmount();
                    end;
                }
                field("CalcApplnRemainingAmount(Remaining Pmt. Disc. Possible)"; CalcApplnRemainingAmount(Rec."Remaining Pmt. Disc. Possible"))
                {
                    ApplicationArea = NPRRetail;
                    AutoFormatExpression = ApplnCurrencyCode;
                    AutoFormatType = 1;
                    Caption = 'Appln. Pmt. Disc. Possible';
                    ToolTip = 'Specifies the discount that the customer can obtain if the entry is applied to before the payment discount date.';
                }
                field("Max. Payment Tolerance"; Rec."Max. Payment Tolerance")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the maximum tolerated amount the entry can differ from the amount on the invoice or credit memo.';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies whether the amount on the entry has been fully paid or there is still a remaining amount that must be applied to.';
                }
                field(Positive; Rec.Positive)
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Specifies if the entry to be applied is positive.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
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
                            ApplicationArea = NPRRetail;
                            Editable = false;
                            ShowCaption = false;
                            TableRelation = Currency;
                            ToolTip = 'Specifies the currency code that the amount will be applied in, in case of different currencies.';
                        }
                    }
                    group(Control1903098801)
                    {
                        Caption = 'Amount to Apply';
                        field(AmountToApply; AppliedAmount)
                        {
                            ApplicationArea = NPRRetail;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Amount to Apply';
                            Editable = false;
                            ToolTip = 'Specifies the sum of the amounts on all the selected customer ledger entries that will be applied by the entry shown in the Available Amount field. The amount is in the currency represented by the code in the Currency Code field.';
                        }
                    }
                    group("Pmt. Disc. Amount")
                    {
                        Caption = 'Pmt. Disc. Amount';
                        field(PmtDiscountAmount; -PmtDiscAmount)
                        {
                            ApplicationArea = NPRRetail;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Pmt. Disc. Amount';
                            Editable = false;
                            ToolTip = 'Specifies the sum of the payment discount amounts granted on all the selected customer ledger entries that will be applied by the entry shown in the Available Amount field. The amount is in the currency represented by the code in the Currency Code field.';
                        }
                    }
                    group(Rounding)
                    {
                        Caption = 'Rounding';
                        field(ApplnRounding; ApplnRounding)
                        {
                            ApplicationArea = NPRRetail;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Rounding';
                            Editable = false;
                            ToolTip = 'Specifies the rounding difference when you apply entries in different currencies to one another. The amount is in the currency represented by the code in the Currency Code field.';
                        }
                    }
                    group("Applied Amount")
                    {
                        Caption = 'Applied Amount';
                        field(AppliedAmount; AppliedAmount + (-PmtDiscAmount) + ApplnRounding)
                        {
                            ApplicationArea = NPRRetail;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Applied Amount';
                            Editable = false;
                            ToolTip = 'Specifies the sum of the amounts in the Amount to Apply field, Pmt. Disc. Amount field, and the Rounding. The amount is in the currency represented by the code in the Currency Code field.';
                        }
                    }
                    group("Available Amount")
                    {
                        Caption = 'Available Amount';
                        field(ApplyingAmount; ApplyingAmount)
                        {
                            ApplicationArea = NPRRetail;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Available Amount';
                            Editable = false;
                            ToolTip = 'Specifies the amount of the journal entry, sales credit memo, or current customer ledger entry that you have selected as the applying entry.';
                        }
                    }
                    group(Balance)
                    {
                        Caption = 'Balance';
                        field(ControlBalance; AppliedAmount + (-PmtDiscAmount) + ApplyingAmount + ApplnRounding)
                        {
                            ApplicationArea = NPRRetail;
                            AutoFormatExpression = ApplnCurrencyCode;
                            AutoFormatType = 1;
                            Caption = 'Balance';
                            Editable = false;
                            ToolTip = 'Specifies any extra amount that will remain after the application.';
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(Control1903096107; "Customer Ledger Entry FactBox")
            {
                ApplicationArea = NPRRetail;
                SubPageLink = "Entry No." = FIELD("Entry No.");
                Visible = true;
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
                    ApplicationArea = NPRRetail;
                    Caption = 'Reminder/Fin. Charge Entries';
                    Image = Reminder;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    RunObject = Page "Reminder/Fin. Charge Entries";
                    RunPageLink = "Customer Entry No." = FIELD("Entry No.");
                    RunPageView = SORTING("Customer Entry No.");
                    ToolTip = 'View the reminders and finance charge entries that you have entered for the customer.';
                }
                action("Applied E&ntries")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Applied E&ntries';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    RunObject = Page "Applied Customer Entries";
                    RunPageOnRec = true;
                    ToolTip = 'View the ledger entries that have been applied to this record.';
                }
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = NPRRetail;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action("Detailed &Ledger Entries")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Detailed &Ledger Entries';
                    Image = View;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    RunObject = Page "Detailed Cust. Ledg. Entries";
                    RunPageLink = "Cust. Ledger Entry No." = FIELD("Entry No.");
                    RunPageView = SORTING("Cust. Ledger Entry No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View a summary of the all posted entries and adjustments related to a specific customer ledger entry.';
                }
                action("&Navigate")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Find entries...';
                    Image = Navigate;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ShortCutKey = 'Shift+Ctrl+I';
                    ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';

                    trigger OnAction()
                    begin
                        Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                        Navigate.Run();
                    end;
                }
            }
        }
        area(processing)
        {
            group("&Application")
            {
                Caption = '&Application';
                Image = Apply;
                action("Set Applies-to ID")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Set Applies-to ID';
                    Image = SelectLineToApply;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Set the Applies-to ID field on the posted entry to automatically be filled in with the document number of the entry in the journal.';

                    trigger OnAction()
                    begin
                        if (CalcType in [CalcType::GenJnlLine, CalcType::POSLine]) and (ApplnType = ApplnType::"Applies-to Doc. No.") then
                            Error(CannotSetAppliesToIDErr);

                        SetCustApplId(false);
                    end;
                }
                action("Show Only Selected Entries to Be Applied")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Show Only Selected Entries to Be Applied';
                    Image = ShowSelected;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    ToolTip = 'View the selected ledger entries that will be applied to the specified record.';

                    trigger OnAction()
                    begin
                        ShowAppliedEntries := not ShowAppliedEntries;
                        if ShowAppliedEntries then begin
                            if CalcType = CalcType::GenJnlLine then
                                Rec.SetRange("Applies-to ID", GenJnlLine."Applies-to ID")
                            else begin
                                CustEntryApplID := GetAppliesToID();
                                if CustEntryApplID = '' then begin
                                    CustEntryApplID := CopyStr(UserId, 1, MaxStrLen(CustEntryApplID));
                                    if CustEntryApplID = '' then
                                        CustEntryApplID := '***';
                                end;
                                Rec.SetRange("Applies-to ID", CustEntryApplID);
                            end;
                        end else
                            Rec.SetRange("Applies-to ID");
                    end;
                }
            }
            action(ShowPostedDocument)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show Posted Document';
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Show details for the posted payment, invoice, or credit memo.';

                trigger OnAction()
                begin
                    Rec.ShowDoc();
                end;
            }
            action(ShowDocumentAttachment)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show Document Attachment';
                Enabled = HasDocumentAttachment;
                Image = Attach;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View documents or images that are attached to the posted invoice or credit memo.';

                trigger OnAction()
                begin
                    Rec.ShowPostedDocAttachment();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if ApplnType = ApplnType::"Applies-to Doc. No." then
            CalcApplnAmount();
        HasDocumentAttachment := Rec.HasPostedDocAttachment();
    end;

    trigger OnAfterGetRecord()
    begin
        StyleTxt := Rec.SetStyle();
    end;

    trigger OnInit()
    begin
        AppliesToIDVisible := true;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Codeunit.Run(Codeunit::"Cust. Entry-Edit", Rec);
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

        SalesSetup.Get();
        CustNameVisible := SalesSetup."Copy Customer Name to Entries";

        AppliesToIDVisible := ApplnType <> ApplnType::"Applies-to Doc. No.";

        GLSetup.Get();

        if ApplnType = ApplnType::"Applies-to Doc. No." then
            CalcApplnAmount();
        PostingDone := false;

        OnAfterOnOpenPage(GenJnlLine, Rec, TempApplyingCustLedgEntry);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RaiseError: Boolean;
    begin
        if CloseAction = ACTION::LookupOK then
            LookupOKOnPush();
        if ApplnType = ApplnType::"Applies-to Doc. No." then begin
            if OK then begin
                RaiseError := TempApplyingCustLedgEntry."Posting Date" < Rec."Posting Date";
                OnBeforeEarlierPostingDateError(TempApplyingCustLedgEntry, Rec, RaiseError, CalcType);
                if RaiseError then begin
                    OK := false;
                    Error(
                      EarlierPostingDateErr, TempApplyingCustLedgEntry."Document Type", TempApplyingCustLedgEntry."Document No.",
                      Rec."Document Type", Rec."Document No.");
                end;
            end;
            if OK then begin
                if Rec."Amount to Apply" = 0 then
                    Rec."Amount to Apply" := Rec."Remaining Amount";
                Codeunit.Run(Codeunit::"Cust. Entry-Edit", Rec);
            end;
        end;
        if (CalcType = CalcType::Direct) and not OK and not PostingDone then begin
            Rec := TempApplyingCustLedgEntry;
            Rec."Applying Entry" := false;
            Rec."Applies-to ID" := '';
            Rec."Amount to Apply" := 0;
            Codeunit.Run(Codeunit::"Cust. Entry-Edit", Rec);
        end;
    end;

    var
        Currency: Record Currency;
        CurrExchRate: Record "Currency Exchange Rate";
        GenJnlLine: Record "Gen. Journal Line";
        SalesHeader: Record "Sales Header";
        ServHeader: Record "Service Header";
        Cust: Record Customer;
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        TotalServLine: Record "Service Line";
        TotalServLineLCY: Record "Service Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        GenJnlApply: Codeunit "Gen. Jnl.-Apply";
        SalesPost: Codeunit "Sales-Post";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        Navigate: Page Navigate;
        StyleTxt: Text;
        CustEntryApplID: Code[50];
        ValidExchRate: Boolean;
        ShowAppliedEntries: Boolean;
        CannotSetAppliesToIDErr: Label 'You cannot set Applies-to ID while selecting Applies-to Doc. No.';
        OK: Boolean;
        EarlierPostingDateErr: Label 'You cannot apply and post an entry to an entry with an earlier posting date.\\Instead, post the document of type %1 with the number %2 and then apply it to the document of type %3 with the number %4.';
        PostingDone: Boolean;
        AppliesToIDVisible: Boolean;
        HasDocumentAttachment: Boolean;
        CustNameVisible: Boolean;

    protected var
        TempApplyingCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
        GenJnlLine2: Record "Gen. Journal Line";
        CustLedgEntry: Record "Cust. Ledger Entry";
        ApplnDate: Date;
        ApplnRoundingPrecision: Decimal;
        ApplnRounding: Decimal;
        ApplnType: Option " ","Applies-to Doc. No.","Applies-to ID";
        AmountRoundingPrecision: Decimal;
        VATAmount: Decimal;
        VATAmountText: Text[30];
        AppliedAmount: Decimal;
        ApplyingAmount: Decimal;
        PmtDiscAmount: Decimal;
        ApplnCurrencyCode: Code[10];
        DifferentCurrenciesInAppln: Boolean;
        ProfitLCY: Decimal;
        ProfitPct: Decimal;
        CalcType: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine;

    internal procedure SetGenJnlLine(NewGenJnlLine: Record "Gen. Journal Line"; ApplnTypeSelect: Integer)
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

    internal procedure SetSales(NewSalesHeader: Record "Sales Header"; var NewCustLedgEntry: Record "Cust. Ledger Entry"; ApplnTypeSelect: Integer)
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

    internal procedure SetService(NewServHeader: Record "Service Header"; var NewCustLedgEntry: Record "Cust. Ledger Entry"; ApplnTypeSelect: Integer)
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

    internal procedure SetCustLedgEntry(NewCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        Rec := NewCustLedgEntry;
    end;

    internal procedure SetApplyingCustLedgEntry()
    var
        Customer: Record Customer;
    begin
        OnBeforeSetApplyingCustLedgEntry(AppliedCustLedgEntry, GenJnlLine, SalesHeader, CalcType, ServHeader);

        case CalcType of
            CalcType::SalesHeader:
                begin
                    TempApplyingCustLedgEntry."Entry No." := 1;
                    TempApplyingCustLedgEntry."Posting Date" := SalesHeader."Posting Date";
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::"Return Order" then
                        TempApplyingCustLedgEntry."Document Type" := TempApplyingCustLedgEntry."Document Type"::"Credit Memo"
                    else
                        TempApplyingCustLedgEntry."Document Type" := TempApplyingCustLedgEntry."Document Type"::Invoice;
                    TempApplyingCustLedgEntry."Document No." := SalesHeader."No.";
                    TempApplyingCustLedgEntry."Customer No." := SalesHeader."Bill-to Customer No.";
                    TempApplyingCustLedgEntry.Description := SalesHeader."Posting Description";
                    TempApplyingCustLedgEntry."Currency Code" := SalesHeader."Currency Code";
                    if TempApplyingCustLedgEntry."Document Type" = TempApplyingCustLedgEntry."Document Type"::"Credit Memo" then begin
                        TempApplyingCustLedgEntry."Sales (LCY)" := -TotalSalesLine."Amount Including VAT";
                        TempApplyingCustLedgEntry."Profit (LCY)" := -TotalSalesLine."Amount Including VAT";
                    end else begin
                        TempApplyingCustLedgEntry."Sales (LCY)" := TotalSalesLine."Amount Including VAT";
                        TempApplyingCustLedgEntry."Profit (LCY)" := TotalSalesLine."Amount Including VAT";
                    end;
                    CalcApplnAmount();
                end;
            CalcType::ServHeader:
                begin
                    TempApplyingCustLedgEntry."Entry No." := 1;
                    TempApplyingCustLedgEntry."Posting Date" := ServHeader."Posting Date";
                    if ServHeader."Document Type" = ServHeader."Document Type"::"Credit Memo" then
                        TempApplyingCustLedgEntry."Document Type" := TempApplyingCustLedgEntry."Document Type"::"Credit Memo"
                    else
                        TempApplyingCustLedgEntry."Document Type" := TempApplyingCustLedgEntry."Document Type"::Invoice;
                    TempApplyingCustLedgEntry."Document No." := ServHeader."No.";
                    TempApplyingCustLedgEntry."Customer No." := ServHeader."Bill-to Customer No.";
                    TempApplyingCustLedgEntry.Description := ServHeader."Posting Description";
                    TempApplyingCustLedgEntry."Currency Code" := ServHeader."Currency Code";
                    if TempApplyingCustLedgEntry."Document Type" = TempApplyingCustLedgEntry."Document Type"::"Credit Memo" then begin
                        TempApplyingCustLedgEntry."Sales (LCY)" := -TotalServLine."Amount Including VAT";
                        TempApplyingCustLedgEntry."Profit (LCY)" := -TotalServLine."Amount Including VAT";
                    end else begin
                        TempApplyingCustLedgEntry."Sales (LCY)" := TotalServLine."Amount Including VAT";
                        TempApplyingCustLedgEntry."Profit (LCY)" := TotalServLine."Amount Including VAT";
                    end;
                    CalcApplnAmount();
                end;
            CalcType::Direct:
                begin
                    if Rec."Applying Entry" then begin
                        if TempApplyingCustLedgEntry."Entry No." <> 0 then
                            CustLedgEntry := TempApplyingCustLedgEntry;
                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", Rec);
                        if Rec."Applies-to ID" = '' then
                            SetCustApplId(false);
                        Rec.CalcFields(Amount);
                        TempApplyingCustLedgEntry := Rec;
                        if CustLedgEntry."Entry No." <> 0 then begin
                            Rec := CustLedgEntry;
                            Rec."Applying Entry" := false;
                            SetCustApplId(false);
                        end;
                        Rec.SetFilter("Entry No.", '<> %1', TempApplyingCustLedgEntry."Entry No.");
                        ApplyingAmount := TempApplyingCustLedgEntry."Profit (LCY)";
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
                    TempApplyingCustLedgEntry."Sales (LCY)" := GenJnlLine.Amount;
                    TempApplyingCustLedgEntry."Profit (LCY)" := GenJnlLine.Amount;
                    CalcApplnAmount();
                end;
            CalcType::POSLine:
                begin
                    TempApplyingCustLedgEntry."Entry No." := 1;
                    TempApplyingCustLedgEntry."Posting Date" := SalePOS.Date;
                    TempApplyingCustLedgEntry."Document Type" := TempApplyingCustLedgEntry."Document Type"::" ";
                    TempApplyingCustLedgEntry."Document No." := SalePOS."Sales Ticket No.";
                    TempApplyingCustLedgEntry."Customer No." := SalePOS."Customer No.";
                    if Customer.Get(TempApplyingCustLedgEntry."Customer No.") then
                        TempApplyingCustLedgEntry.Description := Customer.Name;
                    TempApplyingCustLedgEntry."Currency Code" := '';
                    TempApplyingCustLedgEntry."Sales (LCY)" := SaleLinePOS."Amount Including VAT";
                    TempApplyingCustLedgEntry."Profit (LCY)" := SaleLinePOS."Amount Including VAT";
                    CalcApplnAmount();
                end;
        end;

        OnAfterSetApplyingCustLedgEntry(TempApplyingCustLedgEntry, GenJnlLine, SalesHeader);
    end;

    internal procedure SetCustApplId(CurrentRec: Boolean)
    begin
        CurrPage.SetSelectionFilter(CustLedgEntry);
        CheckCustLedgEntry(CustLedgEntry);

        OnSetCustApplIdAfterCheckAgainstApplnCurrency(Rec, CalcType, GenJnlLine, SalesHeader, ServHeader, TempApplyingCustLedgEntry);

        SetCustEntryApplID(CurrentRec);

        CalcApplnAmount();
    end;

    local procedure SetCustEntryApplID(CurrentRec: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetCustEntryApplID(Rec, CurrentRec, ApplyingAmount, TempApplyingCustLedgEntry, GetAppliesToID(), IsHandled, GenJnlLine);
        if IsHandled then
            exit;

        CustLedgEntry.Copy(Rec);
        if CurrentRec then begin
            CustLedgEntry.SetRecFilter();
            CustEntrySetApplID.SetApplId(CustLedgEntry, TempApplyingCustLedgEntry, Rec."Applies-to ID")
        end else begin
            CurrPage.SetSelectionFilter(CustLedgEntry);
            CustEntrySetApplID.SetApplId(CustLedgEntry, TempApplyingCustLedgEntry, GetAppliesToID())
        end;
    end;

    internal procedure CheckCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        RaiseError: Boolean;
    begin
        if CustLedgerEntry.FindSet() then
            repeat
                if CalcType = CalcType::GenJnlLine then begin
                    RaiseError := TempApplyingCustLedgEntry."Posting Date" < CustLedgerEntry."Posting Date";
                    OnBeforeEarlierPostingDateError(TempApplyingCustLedgEntry, CustLedgerEntry, RaiseError, CalcType);
                    if RaiseError then
                        Error(
                            EarlierPostingDateErr, TempApplyingCustLedgEntry."Document Type", TempApplyingCustLedgEntry."Document No.",
                            CustLedgerEntry."Document Type", CustLedgerEntry."Document No.");
                end;

                if TempApplyingCustLedgEntry."Entry No." <> 0 then
                    GenJnlApply.CheckAgainstApplnCurrency(
                        ApplnCurrencyCode, CustLedgerEntry."Currency Code", GenJnlLine."Account Type"::Customer, true);
            until CustLedgerEntry.Next() = 0;
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
            CalcType::POSLine:
                begin
                    case ApplnType of
                        ApplnType::"Applies-to Doc. No.":
                            AppliesToID := SaleLinePOS."Buffer Document No.";
                        ApplnType::"Applies-to ID":
                            AppliesToID := SaleLinePOS."Buffer ID";
                    end;
                end;
        end;
    end;

    internal procedure CalcApplnAmount()
    begin
        OnBeforeCalcApplnAmount(
            Rec, GenJnlLine, SalesHeader, AppliedCustLedgEntry, CalcType, ApplnType);

        AppliedAmount := 0;
        PmtDiscAmount := 0;
        DifferentCurrenciesInAppln := false;

        case CalcType of
            CalcType::Direct:
                begin
                    FindAmountRounding();
                    CustEntryApplID := CopyStr(UserId, 1, MaxStrLen(CustEntryApplID));
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

                    HandleChosenEntries(
                        CalcType::Direct, CustLedgEntry."Remaining Amount", CustLedgEntry."Currency Code", CustLedgEntry."Posting Date");
                end;
            CalcType::GenJnlLine:
                begin
                    FindAmountRounding();
                    if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Customer then
                        Codeunit.Run(Codeunit::"Exchange Acc. G/L Journal Line", GenJnlLine);

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

                                OnCalcApplnAmountOnCalcTypeGenJnlLineOnApplnTypeToDocNoOnBeforeSetAppliedAmount(Rec, ApplnDate, ApplnCurrencyCode);
                                if AppliedCustLedgEntry."Amount to Apply" <> 0 then
                                    AppliedAmount := Round(AppliedCustLedgEntry."Amount to Apply", AmountRoundingPrecision)
                                else
                                    AppliedAmount := Round(AppliedCustLedgEntry."Remaining Amount", AmountRoundingPrecision);
                                OnCalcApplnAmountOnCalcTypeGenJnlLineOnApplnTypeToDocNoOnAfterSetAppliedAmount(Rec, ApplnDate, ApplnCurrencyCode, AppliedAmount);

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

                                HandleChosenEntries(
                                    CalcType::GenJnlLine, GenJnlLine2.Amount, GenJnlLine2."Currency Code", GenJnlLine2."Posting Date");
                            end;
                    end;
                end;
            CalcType::SalesHeader, CalcType::ServHeader, CalcType::POSLine:
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

                                OnCalcApplnAmountOnCalcTypeSalesHeaderOnApplnTypeToDocNoOnBeforeSetAppliedAmount(Rec, ApplnDate, ApplnCurrencyCode);
                                AppliedAmount := Round(AppliedCustLedgEntry."Remaining Amount", AmountRoundingPrecision);

                                if not DifferentCurrenciesInAppln then
                                    DifferentCurrenciesInAppln := ApplnCurrencyCode <> AppliedCustLedgEntry."Currency Code";
                                CheckRounding();
                            end;
                        ApplnType::"Applies-to ID":
                            begin
                                AppliedCustLedgEntry.SetCurrentKey("Customer No.", Open, Positive);
                                case CalcType of
                                    CalcType::SalesHeader:
                                        AppliedCustLedgEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
                                    CalcType::ServHeader:
                                        AppliedCustLedgEntry.SetRange("Customer No.", ServHeader."Bill-to Customer No.");
                                    CalcType::POSLine:
                                        AppliedCustLedgEntry.SetRange("Customer No.", SalePOS."Customer No.");
                                end;
                                AppliedCustLedgEntry.SetRange(Open, true);
                                AppliedCustLedgEntry.SetRange("Applies-to ID", GetAppliesToID());

                                HandleChosenEntries(CalcType::SalesHeader, ApplyingAmount, ApplnCurrencyCode, ApplnDate);
                            end;
                    end;
                end;
        end;

        OnAfterCalcApplnAmount(Rec, AppliedAmount, ApplyingAmount, CalcType, AppliedCustLedgEntry);
    end;

    local procedure CalcApplnRemainingAmount(ParamAmount: Decimal): Decimal
    var
        ApplnRemainingAmount: Decimal;
    begin
        ValidExchRate := true;
        if ApplnCurrencyCode = Rec."Currency Code" then
            exit(ParamAmount);

        if ApplnDate = 0D then
            ApplnDate := Rec."Posting Date";
        ApplnRemainingAmount :=
          CurrExchRate.ApplnExchangeAmtFCYToFCY(
            ApplnDate, Rec."Currency Code", ApplnCurrencyCode, ParamAmount, ValidExchRate);

        OnAfterCalcApplnRemainingAmount(Rec, ApplnRemainingAmount);
        exit(ApplnRemainingAmount);
    end;

    local procedure CalcApplnAmountToApply(ParamAmountToApply: Decimal): Decimal
    var
        NewApplnAmountToApply: Decimal;
    begin
        ValidExchRate := true;

        if ApplnCurrencyCode = Rec."Currency Code" then
            exit(ParamAmountToApply);

        if ApplnDate = 0D then
            ApplnDate := Rec."Posting Date";
        NewApplnAmountToApply :=
          CurrExchRate.ApplnExchangeAmtFCYToFCY(
            ApplnDate, Rec."Currency Code", ApplnCurrencyCode, ParamAmountToApply, ValidExchRate);

        OnAfterCalcApplnAmountToApply(Rec, NewApplnAmountToApply);
        exit(NewApplnAmountToApply);
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
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckRounding(CalcType, ApplnRounding, IsHandled);
        if IsHandled then
            exit;

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

    internal procedure GetCustLedgEntry(var ParamCustLedgEntry: Record "Cust. Ledger Entry")
    begin
        ParamCustLedgEntry := Rec;
    end;

    local procedure FindApplyingEntry()
    begin
        if CalcType = CalcType::Direct then begin
            CustEntryApplID := CopyStr(UserId, 1, MaxStrLen(CustEntryApplID));
            if CustEntryApplID = '' then
                CustEntryApplID := '***';

            CustLedgEntry.SetCurrentKey("Customer No.", "Applies-to ID", Open);
            CustLedgEntry.SetRange("Customer No.", Rec."Customer No.");
            CustLedgEntry.SetRange("Applies-to ID", CustEntryApplID);
            CustLedgEntry.SetRange(Open, true);
            CustLedgEntry.SetRange("Applying Entry", true);
            OnFindFindApplyingEntryOnAfterCustLedgEntrySetFilters(Rec, CustLedgEntry);
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

    local procedure HandleChosenEntries(Type: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine; CurrentAmount: Decimal; CurrencyCode: Code[10]; PostingDate: Date)
    var
        TempAppliedCustLedgEntry: Record "Cust. Ledger Entry" temporary;
        PossiblePmtDisc: Decimal;
        OldPmtDisc: Decimal;
        CorrectionAmount: Decimal;
        RemainingAmountExclDiscounts: Decimal;
        CanUseDisc: Boolean;
        FromZeroGenJnl: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeHandledChosenEntries(Type, CurrentAmount, CurrencyCode, PostingDate, AppliedCustLedgEntry, IsHandled);
        if IsHandled then
            exit;

        if not AppliedCustLedgEntry.FindSet(false) then
            exit;

        repeat
            TempAppliedCustLedgEntry := AppliedCustLedgEntry;
            TempAppliedCustLedgEntry.Insert();
        until AppliedCustLedgEntry.Next() = 0;

        FromZeroGenJnl := (CurrentAmount = 0) and (Type = Type::GenJnlLine);

        repeat
            if not FromZeroGenJnl then
                TempAppliedCustLedgEntry.SetRange(Positive, CurrentAmount < 0);
            if TempAppliedCustLedgEntry.FindFirst() then begin
                ExchangeLedgerEntryAmounts(Type, CurrencyCode, TempAppliedCustLedgEntry, PostingDate);

                case Type of
                    Type::Direct:
                        CanUseDisc := PaymentToleranceMgt.CheckCalcPmtDiscCust(CustLedgEntry, TempAppliedCustLedgEntry, 0, false, false);
                    Type::GenJnlLine:
                        CanUseDisc := PaymentToleranceMgt.CheckCalcPmtDiscGenJnlCust(GenJnlLine2, TempAppliedCustLedgEntry, 0, false)
                    else
                        CanUseDisc := false;
                end;

                if CanUseDisc and
                   (Abs(TempAppliedCustLedgEntry."Amount to Apply") >=
                    Abs(TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible"))
                then
                    if (Abs(CurrentAmount) >
                        Abs(TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible"))
                    then begin
                        PmtDiscAmount += TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                        CurrentAmount += TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                    end else
                        if (Abs(CurrentAmount) =
                            Abs(TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible"))
                        then begin
                            PmtDiscAmount += TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                            CurrentAmount +=
                              TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                            AppliedAmount += CorrectionAmount;
                        end else
                            if FromZeroGenJnl then begin
                                PmtDiscAmount += TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                                CurrentAmount +=
                                  TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                            end else begin
                                PossiblePmtDisc := TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                                RemainingAmountExclDiscounts :=
                                  TempAppliedCustLedgEntry."Remaining Amount" - PossiblePmtDisc - TempAppliedCustLedgEntry."Max. Payment Tolerance";
                                if Abs(CurrentAmount) + Abs(CalcOppositeEntriesAmount(TempAppliedCustLedgEntry)) >=
                                   Abs(RemainingAmountExclDiscounts)
                                then begin
                                    PmtDiscAmount += PossiblePmtDisc;
                                    AppliedAmount += CorrectionAmount;
                                end;
                                CurrentAmount +=
                                  TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Remaining Pmt. Disc. Possible";
                            end
                else begin
                    if ((CurrentAmount + TempAppliedCustLedgEntry."Amount to Apply") * CurrentAmount) <= 0 then
                        AppliedAmount += CorrectionAmount;
                    CurrentAmount += TempAppliedCustLedgEntry."Amount to Apply";
                end
            end else begin
                TempAppliedCustLedgEntry.SetRange(Positive);
                TempAppliedCustLedgEntry.FindFirst();
                ExchangeLedgerEntryAmounts(Type, CurrencyCode, TempAppliedCustLedgEntry, PostingDate);
            end;

            if OldPmtDisc <> PmtDiscAmount then
                AppliedAmount += TempAppliedCustLedgEntry."Remaining Amount"
            else
                AppliedAmount += TempAppliedCustLedgEntry."Amount to Apply";
            OldPmtDisc := PmtDiscAmount;

            if PossiblePmtDisc <> 0 then
                CorrectionAmount := TempAppliedCustLedgEntry."Remaining Amount" - TempAppliedCustLedgEntry."Amount to Apply"
            else
                CorrectionAmount := 0;

            if not DifferentCurrenciesInAppln then
                DifferentCurrenciesInAppln := ApplnCurrencyCode <> TempAppliedCustLedgEntry."Currency Code";

            OnHandleChosenEntriesOnBeforeDeleteTempAppliedCustLedgEntry(Rec, TempAppliedCustLedgEntry, CurrencyCode);
            TempAppliedCustLedgEntry.Delete();
            TempAppliedCustLedgEntry.SetRange(Positive);

        until not TempAppliedCustLedgEntry.FindFirst();
        CheckRounding();
    end;

    local procedure AmountToApplyOnAfterValidate()
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

    procedure ExchangeLedgerEntryAmounts(Type: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine; CurrencyCode: Code[10]; var CalcCustLedgEntry: Record "Cust. Ledger Entry"; PostingDate: Date)
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
                CalcCustLedgEntry."Remaining Amount", CalcCustLedgEntry."Currency Code", CurrencyCode, PostingDate);
            CalcCustLedgEntry."Remaining Pmt. Disc. Possible" :=
              CurrExchRate.ExchangeAmount(
                CalcCustLedgEntry."Remaining Pmt. Disc. Possible", CalcCustLedgEntry."Currency Code", CurrencyCode, PostingDate);
            CalcCustLedgEntry."Amount to Apply" :=
              CurrExchRate.ExchangeAmount(
                CalcCustLedgEntry."Amount to Apply", CalcCustLedgEntry."Currency Code", CurrencyCode, PostingDate);
        end;

        OnAfterExchangeLedgerEntryAmounts(CalcCustLedgEntry, CustLedgEntry, CurrencyCode);
    end;

    internal procedure SetPOSSaleLine(SalePOSIn: Record "NPR POS Sale"; NewSaleLinePOS: Record "NPR POS Sale Line"; ApplnTypeSelect: Integer)
    begin
        SalePOS := SalePOSIn;
        SaleLinePOS := NewSaleLinePOS;

        ApplnDate := SaleLinePOS.Date;
        ApplnCurrencyCode := SaleLinePOS."Currency Code";
        CalcType := CalcType::POSLine;

        case ApplnTypeSelect of
            SaleLinePOS.FieldNo("Buffer Document No."):
                begin
                    ApplnType := ApplnType::"Applies-to Doc. No.";
                    CustEntryApplID := SaleLinePOS."Buffer Document No.";
                end;
            SaleLinePOS.FieldNo("Buffer ID"):
                begin
                    ApplnType := ApplnType::"Applies-to ID";
                    CustEntryApplID := SaleLinePOS."Buffer ID";
                end;
        end;
    end;

    procedure CalcOppositeEntriesAmount(var TempAppliedCustLedgerEntry: Record "Cust. Ledger Entry" temporary) Result: Decimal
    var
        SavedAppliedCustLedgerEntry: Record "Cust. Ledger Entry";
        CurrPosFilter: Text;
    begin
        CurrPosFilter := TempAppliedCustLedgerEntry.GetFilter(Positive);
        if CurrPosFilter <> '' then begin
            SavedAppliedCustLedgerEntry := TempAppliedCustLedgerEntry;
            TempAppliedCustLedgerEntry.SetRange(Positive, not TempAppliedCustLedgerEntry.Positive);
            if TempAppliedCustLedgerEntry.FindSet() then
                repeat
                    TempAppliedCustLedgerEntry.CalcFields("Remaining Amount");
                    Result += TempAppliedCustLedgerEntry."Remaining Amount";
                until TempAppliedCustLedgerEntry.Next() = 0;
            TempAppliedCustLedgerEntry.SetFilter(Positive, CurrPosFilter);
            TempAppliedCustLedgerEntry := SavedAppliedCustLedgerEntry;
        end;
    end;

    procedure GetApplnCurrencyCode(): Code[10]
    begin
        exit(ApplnCurrencyCode);
    end;

    procedure SetCalcType(NewCalcType: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine)
    begin
        CalcType := NewCalcType;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcApplnAmount(CustLedgerEntry: Record "Cust. Ledger Entry"; var AppliedAmount: Decimal; var ApplyingAmount: Decimal; var CalcType: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine; var AppliedCustLedgEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcApplnAmountToApply(CustLedgerEntry: Record "Cust. Ledger Entry"; var ApplnAmountToApply: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcApplnRemainingAmount(CustLedgerEntry: Record "Cust. Ledger Entry"; var ApplnRemainingAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExchangeLedgerEntryAmounts(var CalcCustLedgEntry: Record "Cust. Ledger Entry"; CustLedgerEntry: Record "Cust. Ledger Entry"; CurrencyCode: Code[10])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterOnOpenPage(var GenJnlLine: Record "Gen. Journal Line"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var ApplyingCustLedgEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterSetApplyingCustLedgEntry(var ApplyingCustLedgEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcApplnAmount(var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header"; var AppliedCustLedgerEntry: Record "Cust. Ledger Entry"; CalculationType: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine; ApplicationType: Option)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckRounding(CalcType: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine; var ApplnRounding: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnBeforeHandledChosenEntries(Type: Option Direct,GenJnlLine,SalesHeader; CurrentAmount: Decimal; CurrencyCode: Code[10]; PostingDate: Date; var AppliedCustLedgerEntry: Record "Cust. Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEarlierPostingDateError(ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; CustLedgerEntry: Record "Cust. Ledger Entry"; var RaiseError: Boolean; CalcType: Option)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSetApplyingCustLedgEntry(var ApplyingCustLedgEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header"; var CalcType: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine; ServHeader: Record "Service Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetCustEntryApplID(CustLedgerEntry: Record "Cust. Ledger Entry"; CurrentRec: Boolean; var ApplyingAmount: Decimal; var ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; AppliesToID: Code[50]; var IsHandled: Boolean; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcApplnAmountOnCalcTypeGenJnlLineOnApplnTypeToDocNoOnBeforeSetAppliedAmount(var AppliedCustLedgEntry: Record "Cust. Ledger Entry"; ApplnDate: Date; ApplnCurrencyCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcApplnAmountOnCalcTypeGenJnlLineOnApplnTypeToDocNoOnAfterSetAppliedAmount(var AppliedCustLedgEntry: Record "Cust. Ledger Entry"; ApplnDate: Date; ApplnCurrencyCode: Code[10]; var AppliedAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalcApplnAmountOnCalcTypeSalesHeaderOnApplnTypeToDocNoOnBeforeSetAppliedAmount(var AppliedCustLedgEntry: Record "Cust. Ledger Entry"; ApplnDate: Date; ApplnCurrencyCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindFindApplyingEntryOnAfterCustLedgEntrySetFilters(ApplyingCustLedgerEntry: Record "Cust. Ledger Entry"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleChosenEntriesOnBeforeDeleteTempAppliedCustLedgEntry(var AppliedCustLedgEntry: Record "Cust. Ledger Entry"; TempAppliedCustLedgEntry: Record "Cust. Ledger Entry" temporary; CurrencyCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetCustApplIdAfterCheckAgainstApplnCurrency(var CustLedgerEntry: Record "Cust. Ledger Entry"; CalcType: Option Direct,GenJnlLine,SalesHeader,ServHeader,POSLine; var GenJnlLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header"; ServHeader: Record "Service Header"; ApplyingCustLedgEntry: Record "Cust. Ledger Entry")
    begin
    end;
}
