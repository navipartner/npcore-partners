codeunit 6184865 "NPR Adyen EFT Trans. Posting"
{
    Access = Internal;
    trigger OnRun()
    begin
        case _ReconciliationLine."Matching Table Name" of
            _ReconciliationLine."Matching Table Name"::"EFT Transaction":
                begin
                    PostEFT();
                end;
            _ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                begin
                    PostMagento();
                end;
        end;
    end;

    procedure LineIsPosted(Line: Record "NPR Adyen Reconciliation Line"): Boolean
    var
        GLEntry: Record "G/L Entry";
        BankAccountLE: Record "Bank Account Ledger Entry";
    begin
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", Line."PSP Reference");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::" ");
        GLEntry.SetRange("Source Code", _AdyenMerchantSetup."Posting Source Code");

        if Line."Amount(AAC)" <> 0 then begin
            case _PaymentAccountType of
                _PaymentAccountType::"Bank Account":
                    begin
                        BankAccountLE.Reset();
                        BankAccountLE.SetRange("Document No.", Line."PSP Reference");
                        BankAccountLE.SetRange("Document Type", BankAccountLE."Document Type"::" ");
                        BankAccountLE.SetRange("Source Code", _AdyenMerchantSetup."Posting Source Code");
                        BankAccountLE.SetRange("Bank Account No.", _PaymentAccountNo);
                        BankAccountLE.SetRange(Amount, Line."Amount(AAC)");
                        if BankAccountLE.IsEmpty() then
                            exit(false);
                    end;
                _PaymentAccountType::"G/L Account":
                    begin
                        GLEntry.SetRange("G/L Account No.", _PaymentAccountNo);
                        GLEntry.SetRange(Amount, Line."Amount(AAC)");
                        if not GLEntry.IsEmpty() then
                            _TransactionPosted := true;
                    end;
            end;
        end;

        GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Markup G/L Account");
        GLEntry.SetRange(Amount, Line."Markup (NC)");
        if ((Line."Markup (NC)" <> 0) and (not GLEntry.IsEmpty())) or (Line."Markup (NC)" = 0) then
            _MarkupPosted := true;
        GLEntry.SetRange("G/L Account No.", _AdyenMerchantSetup."Other commissions G/L Account");
        GLEntry.SetRange(Amount, Line."Other Commissions (NC)");
        if ((Line."Other Commissions (NC)" <> 0) and (not GLEntry.IsEmpty())) or (Line."Markup (NC)" = 0) then
            _CommissionsPosted := true;
        GLEntry.SetFilter("G/L Account No.", '%1|%2', _Currency."Realized Gains Acc.", _Currency."Realized Losses Acc.");
        GLEntry.SetRange(Amount, Line."Realized Gains or Losses");
        if ((Line."Realized Gains or Losses" <> 0) and (not GLEntry.IsEmpty())) or (Line."Realized Gains or Losses" = 0) then
            _RealizedGainsOrLossesPosted := true;
        if (_TransactionPosted and _MarkupPosted and _CommissionsPosted and _RealizedGainsOrLossesPosted) then
            exit(true);
    end;

    procedure PrepareRecords(var RecLine: Record "NPR Adyen Reconciliation Line"): Boolean
    begin
        _AdyenMerchantSetup.Get(RecLine."Merchant Account");
        _AdyenMerchantSetup.TestField("Markup G/L Account");
        _AdyenMerchantSetup.TestField("Other commissions G/L Account");
        _AdyenMerchantSetup.TestField("Reconciled Payment Acc. No.");

        if RecLine."Realized Gains or Losses" <> 0 then begin
            _Currency.Get(RecLine."Adyen Acc. Currency Code");
            _Currency.TestField("Realized Gains Acc.");
            _Currency.TestField("Realized Losses Acc.");
        end;
        _ReconciliationLine := RecLine;
        GetOriginAccount();
        exit(true);
    end;

    local procedure GetOriginAccount()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingSetup: Record "NPR POS Posting Setup";
    begin
        EFTTransactionRequest.Reset();
        EFTTransactionRequest.SetRange("PSP Reference", _ReconciliationLine."PSP Reference");
        EFTTransactionRequest.FindFirst();
        POSPaymentMethod.Get(EFTTransactionRequest."Original POS Payment Type Code");
        POSPostingSetup.Reset();
        POSPostingSetup.SetRange("POS Payment Method Code", POSPaymentMethod.Code);
        POSPostingSetup.FindFirst();
        case POSPostingSetup."Account Type" of
            POSPostingSetup."Account Type"::"G/L Account":
                _PaymentAccountType := _PaymentAccountType::"G/L Account";
            POSPostingSetup."Account Type"::"Bank Account":
                _PaymentAccountType := _PaymentAccountType::"Bank Account";
        end;
        _PaymentAccountNo := POSPostingSetup."Account No.";
    end;

    local procedure CreatePostGL(Amount: Decimal; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
                                                                   BalAccountType: Enum "Gen. Journal Account Type";
                                                                   BalAccountNo: Code[20];
                                                                   ShortcutDimension1Code: Code[20];
                                                                   ShortcutDimension2Code: Code[20];
                                                                   DimensionSetID: Integer)
    var
        GLEntry: Record "G/L Entry";
        GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", _ReconciliationLine."PSP Reference");
        GLEntry.SetRange("Document Type", GLEntry."Document Type"::" ");
        GLEntry.SetRange("Source Code", _AdyenMerchantSetup."Posting Source Code");
        GLEntry.SetRange("G/L Account No.", AccountNo);
        GLEntry.SetRange(Amount, Amount);
        if not GLEntry.IsEmpty() then
            exit;

        GenJnlLine.Init();
        GenJnlLine."Posting Date" := Today();
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Account Type" := AccountType;
        GenJnlLine."Account No." := AccountNo;
        GenJnlLine."Document No." := _ReconciliationLine."PSP Reference";
        GenJnlLine.Validate("Currency Code", _ReconciliationLine."Adyen Acc. Currency Code");
        if (GenJnlLine."Currency Code" <> '') then
            GenJnlLine."Currency Factor" := 1;
        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine."Shortcut Dimension 1 Code" := ShortcutDimension1Code;
        GenJnlLine."Shortcut Dimension 2 Code" := ShortcutDimension2Code;
        GenJnlLine."Dimension Set ID" := DimensionSetID;
        GenJnlLine."Bal. Account Type" := BalAccountType;
        GenJnlLine."Bal. Account No." := BalAccountNo;
        GenJnlLine."Source Code" := _AdyenMerchantSetup."Posting Source Code";
        GenJournalPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure PostEFT()
    var
        POSEntry: Record "NPR POS Entry";
        ShortcutDimension1Code: Code[20];
        ShortcutDimension2Code: Code[20];
        DimensionSetID: Integer;
        POSEntryToPost: Record "NPR POS Entry";
        AdyenGenericSetup: Record "NPR Adyen Setup";
        POSPostEntries: Codeunit "NPR POS Post Entries";

    // POSSalesLine: Record "NPR POS Entry Sales Line";
    // NewPOSSalesLine: Record "NPR POS Entry Sales Line";
    begin
        POSEntry.Reset();
        POSEntry.SetRange("Document No.", _ReconciliationLine."Merchant Reference");
        if not POSEntry.FindFirst() then
            Error(NoOriginalDocumentFound, _ReconciliationLine."Merchant Reference");

        SetDimensions(POSEntry, ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID);

        if (_ReconciliationLine."Transaction Type" in [_ReconciliationLine."Transaction Type"::RefundedReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]) and
            (not _TransactionPosted)
        then begin
            POSEntryToPost.Init();
            POSEntryToPost := POSEntry;
            POSEntryToPost."Entry No." := 0;
            POSEntryToPost."Amount Excl. Tax" *= -1;
            POSEntryToPost."Amount Incl. Tax" *= -1;
            POSEntryToPost."Tax Amount" *= -1;
            POSEntryToPost."Amount Incl. Tax & Round" *= -1;
            POSEntryToPost."Payment Amount" *= -1;
            POSEntryToPost.Insert();
            /*
            POSSalesLine.Reset();
            POSSalesLine.SetRange("POS Entry No.", POSEntryToPost."Entry No.");
            if POSSalesLine.FindSet() then begin
                repeat
                    NewPOSSalesLine := POSSalesLine;
                    NewPOSSalesLine."Amount Excl. VAT" *= -1;
                    NewPOSSalesLine."Amount Incl. VAT" *= -1;
                    NewPOSSalesLine."Amount Excl. VAT (LCY)" *= -1;
                    NewPOSSalesLine."Amount Incl. VAT (LCY)" *= -1;
                    NewPOSSalesLine."VAT Base Amount" *= -1;
                    NewPOSSalesLine.Insert(true);
                until POSSalesLine.Next() = 0;
            end;
            */
            if not AdyenGenericSetup."Post POS Entries Immediately" then begin
                if POSEntry."Post Item Entry Status" < POSEntry."Post Item Entry Status"::Posted then
                    POSPostEntries.SetPostItemEntries(true);
                if POSEntry."Post Entry Status" < POSEntry."Post Entry Status"::Posted then
                    POSPostEntries.SetPostPOSEntries(true);
                if (POSEntry."Post Sales Document Status" = POSEntry."Post Sales Document Status"::Unposted) or (POSEntry."Post Sales Document Status" = POSEntry."Post Sales Document Status"::"Error while Posting") then
                    POSPostEntries.SetPostSaleDocuments(true);
                POSPostEntries.SetStopOnError(true);
                POSPostEntries.SetPostCompressed(false);
                POSPostEntries.Run(POSEntryToPost);
            end;
        end;

        PostEntryToGL(ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID);
    end;

    local procedure PostMagento()
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        ShortcutDimension1Code: Code[20];
        ShortcutDimension2Code: Code[20];
        DimensionSetID: Integer;
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("No.", _ReconciliationLine."Merchant Reference");
        if not SalesHeader.FindFirst() then begin
            if not SalesInvHeader.Get(_ReconciliationLine."Merchant Reference") then
                Error(NoOriginalDocumentFound, _ReconciliationLine."Merchant Reference");
            SetDimensions(SalesInvHeader, ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID);
        end else
            SetDimensions(SalesHeader, ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID);
        PostEntryToGL(ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID);
    end;

    local procedure PostEntryToGL(ShortcutDimension1Code: Code[20]; ShortcutDimension2Code: Code[20]; DimensionSetID: Integer)
    begin
        if (_ReconciliationLine."Amount(AAC)" <> 0) and (not _TransactionPosted) then
            CreatePostGL(_ReconciliationLine."Amount(AAC)", _PaymentAccountType, _PaymentAccountNo, _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID);
        if (_ReconciliationLine."Markup (NC)" <> 0) and (not _MarkupPosted) then
            CreatePostGL(_ReconciliationLine."Markup (NC)", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", _PaymentAccountType::"G/L Account", _AdyenMerchantSetup."Markup G/L Account", ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID);
        if (_ReconciliationLine."Other Commissions (NC)" <> 0) and (not _CommissionsPosted) then
            CreatePostGL(_ReconciliationLine."Other Commissions (NC)", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", _PaymentAccountType::"G/L Account", _AdyenMerchantSetup."Other commissions G/L Account", ShortcutDimension1Code, ShortcutDimension2Code, DimensionSetID);
    end;

    local procedure SetDimensions(POSEntry: Record "NPR POS Entry"; var ShortcutDimension1Code: Code[20]; var ShortcutDimension2Code: Code[20]; var DimensionSetID: Integer)
    begin
        ShortcutDimension1Code := POSEntry."Shortcut Dimension 1 Code";
        ShortcutDimension2Code := POSEntry."Shortcut Dimension 2 Code";
        DimensionSetID := POSEntry."Dimension Set ID";
    end;

    local procedure SetDimensions(SalesHeader: Record "Sales Header"; var ShortcutDimension1Code: Code[20]; var ShortcutDimension2Code: Code[20]; var DimensionSetID: Integer)
    begin
        ShortcutDimension1Code := SalesHeader."Shortcut Dimension 1 Code";
        ShortcutDimension2Code := SalesHeader."Shortcut Dimension 2 Code";
        DimensionSetID := SalesHeader."Dimension Set ID";
    end;

    local procedure SetDimensions(SalesInvHeader: Record "Sales Invoice Header"; var ShortcutDimension1Code: Code[20]; var ShortcutDimension2Code: Code[20]; var DimensionSetID: Integer)
    begin
        ShortcutDimension1Code := SalesInvHeader."Shortcut Dimension 1 Code";
        ShortcutDimension2Code := SalesInvHeader."Shortcut Dimension 2 Code";
        DimensionSetID := SalesInvHeader."Dimension Set ID";
    end;

    var
        _AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
        _ReconciliationLine: Record "NPR Adyen Reconciliation Line";
        _Currency: Record Currency;
        _PaymentAccountType: Enum "Gen. Journal Account Type";
        _PaymentAccountNo: Code[20];
        _TransactionPosted: Boolean;
        _MarkupPosted: Boolean;
        _CommissionsPosted: Boolean;
        _RealizedGainsOrLossesPosted: Boolean;
        NoOriginalDocumentFound: Label 'No document was found with No. %1!';
}
