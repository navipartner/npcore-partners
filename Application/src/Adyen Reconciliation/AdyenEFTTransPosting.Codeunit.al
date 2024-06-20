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

    internal procedure LineIsPosted(Line: Record "NPR Adyen Recon. Line"): Boolean
    begin
        _TransactionPosted := _ReconRelation.Get(Line."Document No.", Line."Line No.", _AmountType::Transaction);
        _MarkupPosted := _ReconRelation.Get(Line."Document No.", Line."Line No.", _AmountType::Markup);
        _CommissionsPosted := _ReconRelation.Get(Line."Document No.", Line."Line No.", _AmountType::"Other commissions");
        _RealizedGainsOrLossesPosted := _ReconRelation.Get(Line."Document No.", Line."Line No.", _AmountType::"Realized Gains") or _ReconRelation.Get(Line."Document No.", Line."Line No.", _AmountType::"Realized Losses");

        if (_TransactionPosted and _MarkupPosted and _CommissionsPosted and _RealizedGainsOrLossesPosted) then
            exit(true);
    end;


    internal procedure PrepareRecords(var RecLine: Record "NPR Adyen Recon. Line"; RecHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    begin
        _AdyenSetup.Get();
        _GLSetup.Get();
        _AdyenMerchantSetup.Get(RecLine."Merchant Account");
        _AdyenMerchantSetup.TestField("Markup G/L Account");
        _AdyenMerchantSetup.TestField("Other commissions G/L Account");
        _AdyenMerchantSetup.TestField("Reconciled Payment Acc. No.");

        if (RecLine."Realized Gains or Losses" <> 0) and (RecLine."Transaction Currency Code" <> '') then begin
            _Currency.Get(RecLine."Transaction Currency Code");
            _Currency.TestField("Realized Gains Acc.");
            _Currency.TestField("Realized Losses Acc.");
        end;
        _ReconciliationLine := RecLine;
        _ReconciliationHeader := RecHeader;
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
            POSPostingSetup."Account Type"::Customer:
                _PaymentAccountType := _PaymentAccountType::Customer;
        end;
        _PaymentAccountNo := POSPostingSetup."Account No.";
    end;

    local procedure CreatePostGL(Amount: Decimal; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
                                                                   BalAccountType: Enum "Gen. Journal Account Type";
                                                                   BalAccountNo: Code[20];
                                                                   DimensionSetID: Integer;
                                                                   CurrencyCode: Code[20];
                                                                   Description: Text[100];
                                                                   ReturnBalancingAccountNo: Boolean): Integer;
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line";
        DimensionManagement: Codeunit DimensionManagement;
        GLEntryNo: Integer;
        BalancingGLEntryNo: Integer;
    begin
        GenJnlLine.Init();
        GenJnlLine.SetSuppressCommit(true);
        if _AdyenSetup."Post with Transaction Date" then
            GenJnlLine."Posting Date" := DT2Date(_ReconciliationLine."Transaction Date")
        else
            GenJnlLine."Posting Date" := _ReconciliationHeader."Posting Date";
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::" ";
        GenJnlLine."Account Type" := AccountType;
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;
        GenJnlLine.Validate("Account No.", AccountNo);
        GenJnlLine."Document No." := _ReconciliationLine."Posting No.";
        if (CurrencyCode <> '') and (CurrencyCode <> _GLSetup."LCY Code") then
            GenJnlLine.Validate("Currency Code", CurrencyCode);

        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine.Description := Description;
        GenJnlLine."Dimension Set ID" := DimensionSetID;
        DimensionManagement.UpdateGlobalDimFromDimSetID(
          GenJnlLine."Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");


        GenJnlLine."Source Code" := _AdyenMerchantSetup."Posting Source Code";
        GLEntryNo := PostGenJnlLine(GenJnlLine, GenJournalPostLine);

        GenJnlLine."Account Type" := BalAccountType;
        GenJnlLine.Validate("Account No.", BalAccountNo);
        GenJnlLine.Validate(Amount, -GenJnlLine.Amount);
        BalancingGLEntryNo := PostGenJnlLine(GenJnlLine, GenJournalPostLine);

        if ReturnBalancingAccountNo then
            exit(BalancingGLEntryNo)
        else
            exit(GLEntryNo);
    end;

    internal procedure PostGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; GenJournalPostLine: Codeunit "Gen. Jnl.-Post Line") GLEntryNo: Integer
    begin
        GLEntryNo := GenJournalPostLine.RunWithCheck(GenJnlLine);

        if GLEntryNo = 0 then
            GLEntryNo := GenJournalPostLine.GetNextEntryNo() - 1;
    end;

    local procedure PostEFT()
    var
        POSEntry: Record "NPR POS Entry";
        DimensionSetID: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ReverseEFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        ReversePOSPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        case _ReconciliationLine."Transaction Type" of
            _ReconciliationLine."Transaction Type"::Chargeback,
            _ReconciliationLine."Transaction Type"::SecondChargeback,
            _ReconciliationLine."Transaction Type"::RefundedReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                begin
                    EFTTransactionRequest.GetBySystemId(_ReconciliationLine."Matching Entry System ID");
                    POSPaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID");

                    ReversePOSPaymentLine := POSPaymentLine;
                    POSPaymentLine.SetRange("POS Entry No.", ReversePOSPaymentLine."POS Entry No.");
                    POSPaymentLine.FindLast();

                    ReversePOSPaymentLine."Line No." := POSPaymentLine."Line No." + 10000;
                    if _AdyenSetup."Post with Transaction Date" then
                        ReversePOSPaymentLine."Entry Date" := DT2Date(_ReconciliationLine."Transaction Date")
                    else
                        ReversePOSPaymentLine."Entry Date" := _ReconciliationHeader."Posting Date";

                    ReversePOSPaymentLine.Amount *= -1;
                    ReversePOSPaymentLine."Amount (LCY)" *= -1;
                    ReversePOSPaymentLine."Payment Amount" *= -1;
                    ReversePOSPaymentLine."Amount (Sales Currency)" *= -1;
                    ReversePOSPaymentLine."VAT Base Amount (LCY)" *= -1;
                    case _ReconciliationLine."Transaction Type" of
                        _ReconciliationLine."Transaction Type"::Chargeback:
                            ReversePOSPaymentLine.Description := ChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::SecondChargeback:
                            ReversePOSPaymentLine.Description := SecondChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::RefundedReversed:
                            ReversePOSPaymentLine.Description := ReverseRefundPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::ChargebackReversed:
                            ReversePOSPaymentLine.Description := ReverseChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                            ReversePOSPaymentLine.Description := ReversedExternalChargebackPaymentLineDescription;
                    end;
                    ReversePOSPaymentLine."Created by Reconciliation" := true;
                    ReversePOSPaymentLine."Created by Recon. Posting No." := _ReconciliationLine."Posting No.";
                    ReversePOSPaymentLine.Insert();
                    // PostReversePOSPaymentLine.Run

                    ReverseEFTTransactionRequest := EFTTransactionRequest;
                    ReverseEFTTransactionRequest."Entry No." := 0;
                    ReverseEFTTransactionRequest."Result Amount" *= -1;
                    ReverseEFTTransactionRequest."Amount Input" *= -1;
                    ReverseEFTTransactionRequest."Amount Output" *= -1;
                    ReverseEFTTransactionRequest."Transaction Date" := DT2Date(_ReconciliationLine."Transaction Date");
                    if _AdyenSetup."Post with Transaction Date" then
                        ReverseEFTTransactionRequest."Reconciliation Date" := DT2Date(_ReconciliationLine."Transaction Date")
                    else
                        ReverseEFTTransactionRequest."Reconciliation Date" := _ReconciliationHeader."Posting Date";
                    case _ReconciliationLine."Transaction Type" of
                        _ReconciliationLine."Transaction Type"::Chargeback:
                            ReverseEFTTransactionRequest."Auxiliary Operation Desc." := ChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::SecondChargeback:
                            ReverseEFTTransactionRequest."Auxiliary Operation Desc." := SecondChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::RefundedReversed:
                            ReverseEFTTransactionRequest."Auxiliary Operation Desc." := ReverseRefundPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::ChargebackReversed:
                            ReverseEFTTransactionRequest."Auxiliary Operation Desc." := ReverseChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                            ReverseEFTTransactionRequest."Auxiliary Operation Desc." := ReversedExternalChargebackPaymentLineDescription;
                    end;
                    ReverseEFTTransactionRequest."Created by Reconciliation" := true;
                    ReverseEFTTransactionRequest."Created by Recon. Posting No." := _ReconciliationLine."Posting No.";
                    ReverseEFTTransactionRequest.Insert();
                    _NewReversedSystemId := ReverseEFTTransactionRequest.SystemId;
                    EFTTransactionRequest."Reversed by Entry No." := ReverseEFTTransactionRequest."Entry No.";
                    EFTTransactionRequest.Reversed := true;
                    EFTTransactionRequest.Modify();
                end;
        end;

        POSEntry.Reset();
        POSEntry.SetRange("Document No.", _ReconciliationLine."Merchant Reference");
        if not POSEntry.FindFirst() then
            Error(NoOriginalDocumentFound, _ReconciliationLine."Merchant Reference");

        SetDimensions(POSEntry, DimensionSetID);

        PostEntryToGL(DimensionSetID);
    end;

    internal procedure GetNewReversedSystemId(): Guid
    begin
        exit(_NewReversedSystemId);
    end;

    local procedure PostMagento()
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        DimensionSetID: Integer;
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        ReverseMagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        case _ReconciliationLine."Transaction Type" of
            _ReconciliationLine."Transaction Type"::Chargeback,
            _ReconciliationLine."Transaction Type"::SecondChargeback,
            _ReconciliationLine."Transaction Type"::RefundedReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                begin
                    MagentoPaymentLine.GetBySystemId(_ReconciliationLine."Matching Entry System ID");

                    ReverseMagentoPaymentLine := MagentoPaymentLine;
                    MagentoPaymentLine.SetRange("Document Table No.", ReverseMagentoPaymentLine."Document Table No.");
                    MagentoPaymentLine.SetRange("Document No.", ReverseMagentoPaymentLine."Document No.");
                    MagentoPaymentLine.SetRange("Document Type", ReverseMagentoPaymentLine."Document Type");
                    MagentoPaymentLine.FindLast();

                    ReverseMagentoPaymentLine."Line No." := MagentoPaymentLine."Line No." + 10000;

                    ReverseMagentoPaymentLine.Amount *= -1;
                    ReverseMagentoPaymentLine."Last Amount" *= -1;

                    ReverseMagentoPaymentLine."Date Captured" := DT2Date(_ReconciliationLine."Transaction Date");

                    if _AdyenSetup."Post with Transaction Date" then
                        ReverseMagentoPaymentLine."Reconciliation Date" := DT2Date(_ReconciliationLine."Transaction Date")
                    else
                        ReverseMagentoPaymentLine."Reconciliation Date" := _ReconciliationHeader."Posting Date";

                    ReverseMagentoPaymentLine."Posting Date" := ReverseMagentoPaymentLine."Reconciliation Date";

                    ReverseMagentoPaymentLine."Created by Reconciliation" := true;
                    ReverseMagentoPaymentLine."Created by Recon. Posting No." := _ReconciliationLine."Posting No.";
                    case _ReconciliationLine."Transaction Type" of
                        _ReconciliationLine."Transaction Type"::Chargeback:
                            ReverseMagentoPaymentLine.Description := ChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::RefundedReversed:
                            ReverseMagentoPaymentLine.Description := ReverseRefundPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::ChargebackReversed:
                            ReverseMagentoPaymentLine.Description := ReverseChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::SecondChargeback:
                            ReverseMagentoPaymentLine.Description := SecondChargebackPaymentLineDescription;
                        _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                            ReverseMagentoPaymentLine.Description := ReversedExternalChargebackPaymentLineDescription;
                    end;
                    ReverseMagentoPaymentLine.Insert();

                    // PostReverseMagentoPaymentLine

                    MagentoPaymentLine.GetBySystemId(_ReconciliationLine."Matching Entry System ID");
                    MagentoPaymentLine."Reversed by Entry System ID" := ReverseMagentoPaymentLine.SystemId;
                    MagentoPaymentLine.Reversed := true;
                    MagentoPaymentLine.Modify();

                    _NewReversedSystemId := ReverseMagentoPaymentLine.SystemId;
                end;
        end;

        SalesHeader.Reset();
        SalesHeader.SetRange("No.", ReverseMagentoPaymentLine."Document No.");
        SalesHeader.SetRange("Document Type", ReverseMagentoPaymentLine."Document Type");
        if not SalesHeader.FindFirst() then begin
            if not SalesInvHeader.Get(ReverseMagentoPaymentLine."Document No.") then
                Error(NoOriginalDocumentFound, _ReconciliationLine."Merchant Reference");
            SetDimensions(SalesInvHeader, DimensionSetID);
        end else
            SetDimensions(SalesHeader, DimensionSetID);

        PostEntryToGL(DimensionSetID);
    end;

    local procedure PostEntryToGL(DimensionSetID: Integer)
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        GLEntryNo: Integer;
    begin
        if (_ReconciliationLine."Amount (TCY)" <> 0) and (not _TransactionPosted) then begin
            GLEntryNo := CreatePostGL(_ReconciliationLine."Amount (TCY)", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", _PaymentAccountType, _PaymentAccountNo, DimensionSetID, _ReconciliationLine."Transaction Currency Code", AdyenTransactionLabel, true);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", _AmountType::Transaction, _ReconciliationLine."Amount(AAC)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;
        if (_ReconciliationLine."Markup (LCY)" <> 0) and (not _MarkupPosted) then begin
            GLEntryNo := CreatePostGL(_ReconciliationLine."Markup (LCY)", _PaymentAccountType::"G/L Account", _AdyenMerchantSetup."Markup G/L Account", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", DimensionSetID, '', AdyenMarkupLabel, false);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", _AmountType::Markup, _ReconciliationLine."Markup (LCY)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;
        if (_ReconciliationLine."Other Commissions (LCY)" <> 0) and (not _CommissionsPosted) then begin
            GLEntryNo := CreatePostGL(_ReconciliationLine."Other Commissions (LCY)", _PaymentAccountType::"G/L Account", _AdyenMerchantSetup."Other commissions G/L Account", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", DimensionSetID, '', AdyenOtherCommissionsLabel, false);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", _AmountType::"Other commissions", _ReconciliationLine."Other Commissions (LCY)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;
        if (_ReconciliationLine."Realized Gains or Losses" <> 0) and (not _RealizedGainsOrLossesPosted) then begin
            if _ReconciliationLine."Realized Gains or Losses" < 0 then begin
                GLEntryNo := CreatePostGL(_ReconciliationLine."Realized Gains or Losses", _PaymentAccountType::"G/L Account", _Currency."Realized Gains Acc.", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", DimensionSetID, '', AdyenRealizedGainsLabel, false);
                AdyenManagement.CreateGLEntryReconciliationLineRelation(GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", _AmountType::"Realized Gains", _ReconciliationLine."Realized Gains or Losses", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
            end else begin
                GLEntryNo := CreatePostGL(_ReconciliationLine."Realized Gains or Losses", _PaymentAccountType::"G/L Account", _Currency."Realized Losses Acc.", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", DimensionSetID, '', AdyenRealizedLossesLabel, false);
                AdyenManagement.CreateGLEntryReconciliationLineRelation(GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", _AmountType::"Realized Losses", _ReconciliationLine."Realized Gains or Losses", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
            end;
        end;
    end;

    local procedure SetDimensions(POSEntry: Record "NPR POS Entry"; var DimensionSetID: Integer)
    begin
        DimensionSetID := POSEntry."Dimension Set ID";
    end;

    local procedure SetDimensions(SalesHeader: Record "Sales Header"; var DimensionSetID: Integer)
    begin
        DimensionSetID := SalesHeader."Dimension Set ID";
    end;

    local procedure SetDimensions(SalesInvHeader: Record "Sales Invoice Header"; var DimensionSetID: Integer)
    begin
        DimensionSetID := SalesInvHeader."Dimension Set ID";
    end;

    var
        _AdyenSetup: Record "NPR Adyen Setup";
        _GLSetup: Record "General Ledger Setup";
        _AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
        _ReconciliationLine: Record "NPR Adyen Recon. Line";
        _ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        _Currency: Record Currency;
        _ReconRelation: Record "NPR Adyen Recon. Line Relation";
        _PaymentAccountType: Enum "Gen. Journal Account Type";
        _AmountType: Enum "NPR Adyen Recon. Amount Type";
        _PaymentAccountNo: Code[20];
        _TransactionPosted: Boolean;
        _MarkupPosted: Boolean;
        _CommissionsPosted: Boolean;
        _RealizedGainsOrLossesPosted: Boolean;
        _NewReversedSystemId: Guid;
        NoOriginalDocumentFound: Label 'No document was found with No. %1.';
        AdyenTransactionLabel: Label 'Adyen: Transaction', MaxLength = 100;
        AdyenMarkupLabel: Label 'Adyen: Markup', MaxLength = 100;
        AdyenOtherCommissionsLabel: Label 'Adyen: Other Commissions (Commission, Markup, Scheme Fees, Interchange)', MaxLength = 100;
        AdyenRealizedGainsLabel: Label 'Adyen: Realized Gains', MaxLength = 100;
        AdyenRealizedLossesLabel: Label 'Adyen: Realized Losses', MaxLength = 100;
        ChargebackPaymentLineDescription: Label 'Adyen: Chargeback', MaxLength = 50;
        SecondChargebackPaymentLineDescription: Label 'Adyen: Second Chargeback', MaxLength = 50;
        ReverseRefundPaymentLineDescription: Label 'Adyen: Refund Reversed', MaxLength = 50;
        ReverseChargebackPaymentLineDescription: Label 'Adyen: Chargeback Reversed', MaxLength = 50;
        ReversedExternalChargebackPaymentLineDescription: Label 'Adyen: External Chargeback Reversed', MaxLength = 50;
}
