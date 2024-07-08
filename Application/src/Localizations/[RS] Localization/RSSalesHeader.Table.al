table 6060025 "NPR RS Sales Header"
{
    Caption = 'RS Sales Header';
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table SystemId"; Guid)
        {
            Caption = 'Table SystemId';
            DataClassification = CustomerContent;
        }
        field(6151436; "Applies-to Bank Entry"; Integer)
        {
            Caption = 'Applies-to Bank Entry';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                xRSSalesHeader: Record "NPR RS Sales Header";
            begin
                xRSSalesHeader.Read(Rec."Table SystemId");
                if xRSSalesHeader."Applies-to Bank Entry" <> Rec."Applies-to Bank Entry" then begin
#if not (BC17 or BC18 or BC19)
                    PrepaymentMgt.AutoPopulatePrepaymentPercentageOnSalesHeader(Rec);
#endif
                    CalculateBankPrepaymentAmount();
                end;
            end;
        }
        field(6151437; "Bank Prepayment Amount"; Decimal)
        {
            Caption = 'Bank Prepayment Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6151438; "Prepayment Posting Type"; Option)
        {
            Caption = 'Prepayment Posting Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Invoice,Credit Memo';
            OptionMembers = Invoice,"Credit Memo";
        }
        field(6151439; "Prepmt. Amount Incl. VAT"; Decimal)
        {
            Caption = 'Prepayment Amount Incl. VAT';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
            begin
                SalesHeader.GetBySystemId(Rec."Table SystemId");
#if not (BC17 or BC18 or BC19)
                PrepaymentMgt.PreventChangingPrepaymentFieldsIfBankAccountIsSelected(SalesHeader, Rec.FieldNo("Prepmt. Amount Incl. VAT"));
                PrepaymentMgt.UpdatePaymentPercentageOnSalesHeader(Rec, SalesHeader);
#endif
            end;
        }
    }

    keys
    {
        key(Key1; "Table SystemId")
        {
            Clustered = true;
        }
    }

    var
#if not (BC17 or BC18 or BC19)
        PrepaymentMgt: Codeunit "NPR Prepayment Mgt.";
#endif
    internal procedure Save()
    begin
        if not Insert() then
            Modify();
    end;

    internal procedure Read(IncSystemId: Guid)
    var
        RSLocalisationMgt: Codeunit "NPR RS Localisation Mgt.";
    begin
        if not RSLocalisationMgt.GetLocalisationSetupEnabled() then
            exit;
        if not Rec.Get(IncSystemId) then begin
            Rec.Init();
            Rec."Table SystemId" := IncSystemId;
        end;
    end;

    internal procedure CheckValidatedBankEntry(SalesHeader: Record "Sales Header")
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        RSBankAccLedgerEntry: Record "NPR RS Bank Acc. Ledger Entry";
        WrongRecordErr: Label 'Wrong %1 is selected. Please use Drill Down to select proper one.', Comment = '%1=Bank Account Ledger Entry Caption';
    begin
        if "Applies-to Bank Entry" = 0 then
            exit;
        BankAccountLedgerEntry.Get("Applies-to Bank Entry");
        if BankAccountLedgerEntry."Remaining Amount" = 0 then
            Error(WrongRecordErr, BankAccountLedgerEntry.TableCaption());
        RSBankAccLedgerEntry.SetRange(Prepayment, true);
        RSBankAccLedgerEntry.SetRange("Document Type", RSBankAccLedgerEntry."Document Type"::Payment);
        RSBankAccLedgerEntry.SetRange("Bal. Account Type", RSBankAccLedgerEntry."Bal. Account Type"::Customer);
        RSBankAccLedgerEntry.SetRange("Bal. Account No.", SalesHeader."Sell-to Customer No.");
        RSBankAccLedgerEntry.SetRange("Table SystemId", BankAccountLedgerEntry.SystemId);
        if RSBankAccLedgerEntry.IsEmpty() then
            Error(WrongRecordErr, BankAccountLedgerEntry.TableCaption());
    end;

    internal procedure DrillDownAppliesToBankEntry(SalesHeader: Record "Sales Header"): Integer
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        RSBankAccLedgerEntry: Record "NPR RS Bank Acc. Ledger Entry";
        BankAccountLedgerEntries: Page "Bank Account Ledger Entries";
    begin
        RSBankAccLedgerEntry.SetRange(Prepayment, true);
        RSBankAccLedgerEntry.SetRange("Document Type", RSBankAccLedgerEntry."Document Type"::Payment);
        RSBankAccLedgerEntry.SetRange("Bal. Account Type", RSBankAccLedgerEntry."Bal. Account Type"::Customer);
        RSBankAccLedgerEntry.SetRange("Bal. Account No.", SalesHeader."Sell-to Customer No.");
        if RSBankAccLedgerEntry.FindSet() then
            repeat
                if BankAccountLedgerEntry.GetBySystemId(RSBankAccLedgerEntry."Table SystemId") then
                    if BankAccountLedgerEntry."Remaining Amount" > 0 then
                        BankAccountLedgerEntry.Mark(true);
            until RSBankAccLedgerEntry.Next() = 0;

        BankAccountLedgerEntry.MarkedOnly(true);
        BankAccountLedgerEntries.SetTableView(BankAccountLedgerEntry);
        BankAccountLedgerEntries.LookupMode(true);
        if BankAccountLedgerEntries.RunModal() = Action::LookupOK then begin
            BankAccountLedgerEntries.GetRecord(BankAccountLedgerEntry);
            exit(BankAccountLedgerEntry."Entry No.");
        end;
    end;

    local procedure CalculateBankPrepaymentAmount()
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        "Bank Prepayment Amount" := 0;
        if BankAccountLedgerEntry.Get(Rec."Applies-to Bank Entry") then
            "Bank Prepayment Amount" := BankAccountLedgerEntry."Remaining Amount";
    end;
}