codeunit 6184827 "NPR Adyen Fee Posting"
{
    Access = Internal;
    trigger OnRun()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line";

    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := Today();
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine."Account Type" := _AdyenMerchantSetup."Reconciled Payment Acc. Type";
        GenJnlLine."Account No." := _AdyenMerchantSetup."Reconciled Payment Acc. No.";
        case _GLAccountType of
            _GLAccountType::"Fee G/L Account":
                GenJnlLine."Bal. Account No." := _AdyenMerchantSetup."Fee G/L Account";
            _GLAccountType::"Invoice Deduction G/L Account":
                GenJnlLine."Bal. Account No." := _AdyenMerchantSetup."Invoice Deduction G/L Account";
            _GLAccountType::"Chargeback Fees G/L Account":
                GenJnlLine."Bal. Account No." := _AdyenMerchantSetup."Chargeback Fees G/L Account";
            _GLAccountType::"Merchant Payout G/L Account":
                GenJnlLine."Bal. Account No." := _AdyenMerchantSetup."Merchant Payout G/L Account";
            _GLAccountType::"Advancement External Commission G/L Account":
                GenJnlLine."Bal. Account No." := _AdyenMerchantSetup."Advancement EC G/L Account";
            _GLAccountType::"Refunded External Commission G/L Account":
                GenJnlLine."Bal. Account No." := _AdyenMerchantSetup."Refunded EC G/L Account";
            _GLAccountType::"Settled External Commission G/L Account":
                GenJnlLine."Bal. Account No." := _AdyenMerchantSetup."Settled EC G/L Account";
        end;
        GenJnlLine."Document No." := _ReconciliationLine."Document No.";
        GenJnlLine.Description := CopyStr(_ReconciliationLine."Modification Reference", 1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine."Currency Code" := _ReconciliationLine."Adyen Acc. Currency Code";
        if (GenJnlLine."Currency Code" <> '') then
            GenJnlLine."Currency Factor" := 1;
        GenJnlLine.Validate(Amount, -_ReconciliationLine."Amount(AAC)");
        GenJnlLine."Source Code" := _AdyenMerchantSetup."Posting Source Code";
        _GLEntryNo := GenJournalPostLine.RunWithCheck(GenJnlLine);
    end;

    procedure GLEntryExists(var GLEntry: Record "G/L Entry"; RecLine: Record "NPR Adyen Recon. Line") Exists: Boolean
    begin
        if _AdyenMerchantSetup.Get(RecLine."Merchant Account") then begin
            GLEntry.Reset();
            GLEntry.SetRange(Description, CopyStr(_ReconciliationLine."Modification Reference", 1, MaxStrLen(GLEntry.Description)));
            GLEntry.SetRange("Document Type", GLEntry."Document Type"::" ");
            GLEntry.SetRange("Source Code", _AdyenMerchantSetup."Posting Source Code");

            case _GLAccountType of
                _GLAccountType::"Fee G/L Account":
                    GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Fee G/L Account");
                _GLAccountType::"Invoice Deduction G/L Account":
                    GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Invoice Deduction G/L Account");
                _GLAccountType::"Chargeback Fees G/L Account":
                    GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Chargeback Fees G/L Account");
                _GLAccountType::"Merchant Payout G/L Account":
                    GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Merchant Payout G/L Account");
                _GLAccountType::"Advancement External Commission G/L Account":
                    GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Advancement EC G/L Account");
                _GLAccountType::"Refunded External Commission G/L Account":
                    GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Refunded EC G/L Account");
                _GLAccountType::"Settled External Commission G/L Account":
                    GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Settled EC G/L Account");
            end;
            if GLEntry.FindFirst() then begin
                _GLEntryNo := GLEntry."Entry No.";
                exit(true);
            end;
            exit(false);
        end;
    end;

    procedure PrepareRecords(var RecLine: Record "NPR Adyen Recon. Line"; GLAccountType: Enum "NPR Adyen Posting GL Accounts"): Boolean
    begin
        _GLAccountType := GLAccountType;
        if _AdyenMerchantSetup.Get(RecLine."Merchant Account") then begin
            case _GLAccountType of
                _GLAccountType::"Fee G/L Account":
                    _AdyenMerchantSetup.TestField("Fee G/L Account");
                _GLAccountType::"Invoice Deduction G/L Account":
                    _AdyenMerchantSetup.TestField("Invoice Deduction G/L Account");
                _GLAccountType::"Chargeback Fees G/L Account":
                    _AdyenMerchantSetup.TestField("Chargeback Fees G/L Account");
                _GLAccountType::"Merchant Payout G/L Account":
                    _AdyenMerchantSetup.TestField("Merchant Payout G/L Account");
                _GLAccountType::"Advancement External Commission G/L Account":
                    _AdyenMerchantSetup.TestField("Advancement EC G/L Account");
                _GLAccountType::"Refunded External Commission G/L Account":
                    _AdyenMerchantSetup.TestField("Refunded EC G/L Account");
                _GLAccountType::"Settled External Commission G/L Account":
                    _AdyenMerchantSetup.TestField("Settled EC G/L Account");
            end;
            _AdyenMerchantSetup.TestField("Reconciled Payment Acc. No.");
            _ReconciliationLine := RecLine;
            exit(true);
        end;
    end;

    procedure GetGlEntryNo(): Integer
    begin
        exit(_GLEntryNo);
    end;

    var
        _ReconciliationLine: Record "NPR Adyen Recon. Line";
        _AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
        _GLEntryNo: Integer;
        _GLAccountType: Enum "NPR Adyen Posting GL Accounts";
}
