codeunit 6184865 "NPR Adyen EFT Trans. Posting"
{
    Access = Internal;
    trigger OnRun()
    begin
        case _ReconciliationLine."Matching Table Name" of
            _ReconciliationLine."Matching Table Name"::"EFT Transaction":
                PostEFT();
            _ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                PostMagento();
            _ReconciliationLine."Matching Table Name"::"Subscription Payment":
                PostSubscription();
        end;
    end;

    [TryFunction]
    internal procedure PrepareRecords(RecLine: Record "NPR Adyen Recon. Line"; RecHeader: Record "NPR Adyen Reconciliation Hdr")
    begin
        _AdyenSetup.GetRecordOnce();
        _GLSetup.GetRecordOnce();
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
    end;

    local procedure GetOriginAccount()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSPostingSetup: Record "NPR POS Posting Setup";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
        CouldNotDeterminePOSPostingSetupLbl: Label 'The system was unable to locate the corresponding POS Posting Setup for the Sale: %1.';
    begin
        case _ReconciliationLine."Matching Table Name" of
            _ReconciliationLine."Matching Table Name"::"EFT Transaction":
                begin
                    EFTTransactionRequest.GetBySystemId(_ReconciliationLine."Matching Entry System ID");
                    POSPaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID");
                    if not POSPostEntries.GetPostingSetup(POSPaymentLine."POS Store Code", POSPaymentLine."POS Payment Method Code", POSPaymentLine."POS Payment Bin Code", POSPostingSetup) then
                        Error(CouldNotDeterminePOSPostingSetupLbl, EFTTransactionRequest."Sales Ticket No.");

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
            _ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                begin
                    MagentoPaymentLine.GetBySystemId(_ReconciliationLine."Matching Entry System ID");
                    case MagentoPaymentLine."Account Type" of
                        MagentoPaymentLine."Account Type"::"G/L Account":
                            _PaymentAccountType := _PaymentAccountType::"G/L Account";
                        MagentoPaymentLine."Account Type"::"Bank Account":
                            _PaymentAccountType := _PaymentAccountType::"Bank Account";
                    end;
                    _PaymentAccountNo := MagentoPaymentLine."Account No.";
                end;
            _ReconciliationLine."Matching Table Name"::"Subscription Payment":
                begin
                    SubscrPaymentRequest.GetBySystemId(_ReconciliationLine."Matching Entry System ID");
                    SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
                    SubscrPaymentIHandler.GetPaymentPostingAccount(_PaymentAccountType, _PaymentAccountNo);
                end;
        end;
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
        if DimensionSetID > 0 then begin
            GenJnlLine."Dimension Set ID" := DimensionSetID;
            DimensionManagement.UpdateGlobalDimFromDimSetID(GenJnlLine."Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");
        end;

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
        DimensionSetID: Integer;
        POSEntry: Record "NPR POS Entry";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ReverseEFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        EFTReversed: Boolean;
    begin
        EFTTransactionRequest.GetBySystemId(_ReconciliationLine."Matching Entry System ID");
        case _ReconciliationLine."Transaction Type" of
            _ReconciliationLine."Transaction Type"::Chargeback,
            _ReconciliationLine."Transaction Type"::SecondChargeback,
            _ReconciliationLine."Transaction Type"::RefundedReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                begin
                    POSPaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID");
                    CreateReverseEFTTransactionRequest(EFTTransactionRequest, ReverseEFTTransactionRequest, EFTReversed);

                    //TODO PostReversePOSPaymentLine

                    if EFTReversed then begin
                        EFTTransactionRequest."Reversed by Entry No." := ReverseEFTTransactionRequest."Entry No.";
                        EFTTransactionRequest.Reversed := true;
                        EFTTransactionRequest.Modify();
                        CreateReversePOSPaymentLine(POSPaymentLine);
                    end;

                    _NewReversedSystemId := ReverseEFTTransactionRequest.SystemId;
                end;
        end;

        POSEntry.Reset();
        POSEntry.SetRange("Document No.", EFTTransactionRequest."Sales Ticket No.");
        if not POSEntry.FindFirst() then
            Error(NoOriginalDocumentFound, EFTTransactionRequest."Sales Ticket No.");

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
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DimensionSetID: Integer;
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        ReverseMagentoPaymentLine: Record "NPR Magento Payment Line";
        MagentoReversed: Boolean;
    begin
        MagentoPaymentLine.GetBySystemId(_ReconciliationLine."Matching Entry System ID");
        case _ReconciliationLine."Transaction Type" of
            _ReconciliationLine."Transaction Type"::Chargeback,
            _ReconciliationLine."Transaction Type"::SecondChargeback,
            _ReconciliationLine."Transaction Type"::RefundedReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                begin
                    CreateReverseMagento(MagentoPaymentLine, ReverseMagentoPaymentLine, MagentoReversed);

                    //TODO PostReverseMagentoPaymentLine

                    if MagentoReversed then begin
                        MagentoPaymentLine."Reversed by Entry System ID" := ReverseMagentoPaymentLine.SystemId;
                        MagentoPaymentLine.Reversed := true;
                        MagentoPaymentLine.Modify();
                    end;

                    _NewReversedSystemId := ReverseMagentoPaymentLine.SystemId;
                end;
        end;

        SalesHeader.Reset();
        SalesHeader.SetRange("No.", MagentoPaymentLine."Document No.");
        SalesHeader.SetRange("Document Type", MagentoPaymentLine."Document Type");
        if not SalesHeader.FindFirst() then begin
            if not SalesInvHeader.Get(MagentoPaymentLine."Document No.") then begin
                if not SalesCrMemoHeader.Get(MagentoPaymentLine."Document No.") then
                    Error(NoOriginalSalesDocumentFound, MagentoPaymentLine."Document No.")
                else
                    SetDimensions(SalesCrMemoHeader, DimensionSetID);
            end else
                SetDimensions(SalesInvHeader, DimensionSetID);
        end else
            SetDimensions(SalesHeader, DimensionSetID);

        PostEntryToGL(DimensionSetID);
    end;

    local procedure PostSubscription()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        ReverseSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        case _ReconciliationLine."Transaction Type" of
            _ReconciliationLine."Transaction Type"::Chargeback,
            _ReconciliationLine."Transaction Type"::SecondChargeback,
            _ReconciliationLine."Transaction Type"::RefundedReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversed,
            _ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                begin
                    SubscrPaymentRequest.GetBySystemId(_ReconciliationLine."Matching Entry System ID");
                    CreateReverseSubscrPaymentRequest(SubscrPaymentRequest, ReverseSubscrPaymentRequest, _ReconciliationLine."Transaction Type");
                    _NewReversedSystemId := ReverseSubscrPaymentRequest.SystemId;
                end;
        end;
        PostEntryToGL(0);
    end;

    local procedure PostEntryToGL(DimensionSetID: Integer)
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        GLEntryNo: Integer;
    begin
        if (_ReconciliationLine."Amount (TCY)" <> 0) and (not _ReconciliationLine."Transaction Posted") then begin
            GLEntryNo := CreatePostGL(_ReconciliationLine."Amount (TCY)", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", _PaymentAccountType, _PaymentAccountNo, DimensionSetID, _ReconciliationLine."Transaction Currency Code", StrSubstNo(AdyenTransactionLabel, _ReconciliationLine."PSP Reference"), true);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", _AmountType::Transaction, _ReconciliationLine."Amount(AAC)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;
        if (_ReconciliationLine."Markup (LCY)" <> 0) and (not _ReconciliationLine."Markup Posted") then begin
            GLEntryNo := CreatePostGL(_ReconciliationLine."Markup (LCY)", _PaymentAccountType::"G/L Account", _AdyenMerchantSetup."Markup G/L Account", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", DimensionSetID, '', AdyenMarkupLabel, false);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", _AmountType::Markup, _ReconciliationLine."Markup (LCY)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;
        if (_ReconciliationLine."Other Commissions (LCY)" <> 0) and (not _ReconciliationLine."Commissions Posted") then begin
            GLEntryNo := CreatePostGL(_ReconciliationLine."Other Commissions (LCY)", _PaymentAccountType::"G/L Account", _AdyenMerchantSetup."Other commissions G/L Account", _AdyenMerchantSetup."Reconciled Payment Acc. Type", _AdyenMerchantSetup."Reconciled Payment Acc. No.", DimensionSetID, '', AdyenOtherCommissionsLabel, false);
            AdyenManagement.CreateGLEntryReconciliationLineRelation(GLEntryNo, _ReconciliationLine."Document No.", _ReconciliationLine."Line No.", _AmountType::"Other commissions", _ReconciliationLine."Other Commissions (LCY)", _ReconciliationLine."Posting Date", _ReconciliationLine."Posting No.");
        end;
        if (_ReconciliationLine."Realized Gains or Losses" <> 0) and (not (_ReconciliationLine."Realized Gains Posted" or _ReconciliationLine."Realized Losses Posted")) then begin
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

    local procedure SetDimensions(SalesCreditMemo: Record "Sales Cr.Memo Header"; var DimensionSetID: Integer)
    begin
        DimensionSetID := SalesCreditMemo."Dimension Set ID";
    end;

    local procedure CreateReverseEFTTransactionRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var ReverseEFTTransactionRequest: Record "NPR EFT Transaction Request"; var EFTReversed: Boolean)
    var
        ExistingReversedEFT: Record "NPR EFT Transaction Request";
    begin
        EFTReversed := false;
        ExistingReversedEFT.Reset();
        ExistingReversedEFT.SetRange("PSP Reference", EFTTransactionRequest."PSP Reference");
        ExistingReversedEFT.SetRange(Reversed, false);
        ExistingReversedEFT.SetRange(Reconciled, false);
        ExistingReversedEFT.SetRange("Result Amount", EFTTransactionRequest."Result Amount");
        if ExistingReversedEFT.FindFirst() then begin
            ReverseEFTTransactionRequest := ExistingReversedEFT;
            exit;
        end;

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
        EFTReversed := true;
    end;

    local procedure CreateReversePOSPaymentLine(POSPaymentLine: Record "NPR POS Entry Payment Line")
    var
        ReversePOSPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        ReversePOSPaymentLine := POSPaymentLine;
        POSPaymentLine.SetRange("POS Entry No.", POSPaymentLine."POS Entry No.");
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
    end;

    local procedure CreateReverseMagento(MagentoPaymentLine: Record "NPR Magento Payment Line"; var ReverseMagentoPaymentLine: Record "NPR Magento Payment Line"; var MagentoReversed: Boolean)
    var
        ExistingReverseMagento: Record "NPR Magento Payment Line";
    begin
        MagentoReversed := false;
        ReverseMagentoPaymentLine := MagentoPaymentLine;
        ExistingReverseMagento.SetRange("Transaction ID", MagentoPaymentLine."Transaction ID");
        ExistingReverseMagento.SetRange(Reversed, false);
        ExistingReverseMagento.SetRange(Reconciled, false);
        ExistingReverseMagento.SetRange(Amount, MagentoPaymentLine.Amount);
        if ExistingReverseMagento.FindFirst() then begin
            ReverseMagentoPaymentLine := ExistingReverseMagento;
            exit;
        end;

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
        MagentoReversed := true;
    end;

    local procedure CreateReverseSubscrPaymentRequest(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var ReverseSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; ReconciliationTransactionType: Enum "NPR Adyen Rec. Trans. Type")
    var
        ExistingReversedSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";

        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrReversalRequest: Record "NPR MM Subscr. Request";
        SubscrReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";

        PaymentRequestType: Enum "NPR MM Payment Request Type";
    begin
        ExistingReversedSubscrPaymentRequest.Reset();
        ExistingReversedSubscrPaymentRequest.SetRange("PSP Reference", SubscrPaymentRequest."PSP Reference");
        ExistingReversedSubscrPaymentRequest.SetRange(Reversed, false);
        ExistingReversedSubscrPaymentRequest.SetRange(Reconciled, false);
        ExistingReversedSubscrPaymentRequest.SetRange("Amount", SubscrPaymentRequest."Amount");
        if ExistingReversedSubscrPaymentRequest.FindFirst() then begin
            ReverseSubscrPaymentRequest := ExistingReversedSubscrPaymentRequest;
            exit;
        end;

        SubscrPaymentRequest.TestField("Subscr. Request Entry No.");

        case ReconciliationTransactionType of
            ReconciliationTransactionType::RefundedReversed:
                PaymentRequestType := PaymentRequestType::RefundRefersed;
            ReconciliationTransactionType::Chargeback,
            ReconciliationTransactionType::SecondChargeback:
                PaymentRequestType := PaymentRequestType::Chargeback;
            ReconciliationTransactionType::ChargebackReversed,
            ReconciliationTransactionType::ChargebackReversedExternallyWithInfo:
                PaymentRequestType := PaymentRequestType::ChargebackReversed;
        end;

        SubscriptionRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.");

        SubscrReversalMgt.InitReversalRequest(SubscriptionRequest, SubscrPaymentRequest, PaymentRequestType, SubscrReversalRequest, ReverseSubscrPaymentRequest);
        ReverseSubscrPaymentRequest.Status := ReverseSubscrPaymentRequest.Status::Captured;
        ReverseSubscrPaymentRequest."Status Change Date" := Today;
        ReverseSubscrPaymentRequest.PSP := SubscrPaymentRequest.PSP;
        ReverseSubscrPaymentRequest."PSP Reference" := SubscrPaymentRequest."PSP Reference";
        ReverseSubscrPaymentRequest."External Transaction ID" := SubscrPaymentRequest."External Transaction ID";
        SubscrReversalMgt.InsertReversalRequest(SubscriptionRequest, SubscrPaymentRequest, SubscrReversalRequest, ReverseSubscrPaymentRequest);
        SubscrReversalRequest.Status := SubscrReversalRequest.Status::Confirmed;
        SubscrReversalRequest.Modify();
    end;

    var
        _AdyenSetup: Record "NPR Adyen Setup";
        _GLSetup: Record "General Ledger Setup";
        _AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
        _ReconciliationLine: Record "NPR Adyen Recon. Line";
        _ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        _Currency: Record Currency;
        _PaymentAccountType: Enum "Gen. Journal Account Type";
        _AmountType: Enum "NPR Adyen Recon. Amount Type";
        _PaymentAccountNo: Code[20];
        _NewReversedSystemId: Guid;
        NoOriginalDocumentFound: Label 'No POS Entry was found with No. %1.';
        NoOriginalSalesDocumentFound: Label 'No Sales Document was found with No. %1.';
        AdyenTransactionLabel: Label 'NP Pay: Transaction %1', MaxLength = 100;
        AdyenMarkupLabel: Label 'NP Pay: Markup', MaxLength = 100;
        AdyenOtherCommissionsLabel: Label 'NP Pay: Other Commissions (Commission, Markup, Scheme Fees, Interchange)', MaxLength = 100;
        AdyenRealizedGainsLabel: Label 'NP Pay: Realized Gains', MaxLength = 100;
        AdyenRealizedLossesLabel: Label 'NP Pay: Realized Losses', MaxLength = 100;
        ChargebackPaymentLineDescription: Label 'NP Pay: Chargeback', MaxLength = 50;
        SecondChargebackPaymentLineDescription: Label 'NP Pay: Second Chargeback', MaxLength = 50;
        ReverseRefundPaymentLineDescription: Label 'NP Pay: Refund Reversed', MaxLength = 50;
        ReverseChargebackPaymentLineDescription: Label 'NP Pay: Chargeback Reversed', MaxLength = 50;
        ReversedExternalChargebackPaymentLineDescription: Label 'NP Pay: External Chargeback Reversed', MaxLength = 50;
}
