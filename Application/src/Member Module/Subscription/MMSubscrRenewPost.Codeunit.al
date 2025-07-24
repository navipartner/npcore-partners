codeunit 6185121 "NPR MM Subscr. Renew: Post"
{
    Access = Internal;

    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AUTORENEW_TEXT: Label 'Renewal of %1 for %2 - %3.';

    internal procedure PostInvoiceToGL(var SubscriptionRequest: Record "NPR MM Subscr. Request"; Membership: Record "NPR MM Membership"; MembershipSetup: Record "NPR MM Membership Setup"): Boolean
    var
        GenJnlLine: Record "Gen. Journal Line";
        RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup";
        AppliesToDocType: Enum "Gen. Journal Document Type";
        AppliesToDocNo: Code[20];
        PostingDescription: Text;
    begin
        if SubscriptionRequest.Posted then
            exit(true);
        SubscriptionRequest.TestField(Type);

        Membership.TestField("Customer No.");
        MembershipSetup.TestField("Recurring Payment Code");
        RecurringPaymentSetup.Get(MembershipSetup."Recurring Payment Code");
        RecurringPaymentSetup.TestField("Revenue Account");
        RecurringPaymentSetup.TestField("Source Code");

        if SubscriptionRequest."Posting Document No." = '' then
            SubscriptionRequest."Posting Document No." := GetPostingDocumentNo(RecurringPaymentSetup);
        PostingDescription := StrSubstNo(AUTORENEW_TEXT, Membership."External Membership No.", SubscriptionRequest."New Valid From Date", SubscriptionRequest."New Valid Until Date");
        if SubscriptionRequest.Type = SubscriptionRequest.Type::Renew then
            SubscriptionRequest."Posting Document Type" := SubscriptionRequest."Posting Document Type"::Invoice
        else
            SubscriptionRequest."Posting Document Type" := SubscriptionRequest."Posting Document Type"::"Credit Memo";
        SubscriptionRequest."Posting Date" := Today();

        if (SubscriptionRequest.Type <> SubscriptionRequest.Type::"Partial Regret") then
            SetAppliesToDoc(SubscriptionRequest, AppliesToDocType, AppliesToDocNo);

        //Revenue account
        InitGenJnlLine(GenJnlLine,
            SubscriptionRequest."Posting Document Type", SubscriptionRequest."Posting Document No.", SubscriptionRequest."Posting Date",
            GenJnlLine."Account Type"::"G/L Account", RecurringPaymentSetup."Revenue Account",
            -SubscriptionRequest.Amount, SubscriptionRequest."Currency Code", true,
            0, RecurringPaymentSetup."Source Code", PostingDescription);
        SubscriptionRequest."G/L Entry No." := GenJnlPostLine.RunWithCheck(GenJnlLine);
        SubscriptionRequest.Posted := SubscriptionRequest."G/L Entry No." <> 0;

        //Customer account
        InitGenJnlLine(GenJnlLine,
            SubscriptionRequest."Posting Document Type", SubscriptionRequest."Posting Document No.", SubscriptionRequest."Posting Date",
            GenJnlLine."Account Type"::Customer, Membership."Customer No.",
            SubscriptionRequest.Amount, SubscriptionRequest."Currency Code", false,
            0, RecurringPaymentSetup."Source Code", PostingDescription);
        if AppliesToDocNo <> '' then begin
            GenJnlLine."Applies-to Doc. Type" := AppliesToDocType;
            GenJnlLine."Applies-to Doc. No." := AppliesToDocNo;
        end;
        GenJnlPostLine.RunWithCheck(GenJnlLine);
        SubscriptionRequest."Cust. Ledger Entry No." := GetLastPostedGLEntryNo();

        exit(SubscriptionRequest.Posted);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure PostPaymentsToGL(SubscriptionRequest: Record "NPR MM Subscr. Request"; PostingDocumentNo: Code[20])
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup";
        Subscription: Record "NPR MM Subscription";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::Captured);
        SubscrPaymentRequest.SetRange(Posted, false);
        if SubscrPaymentRequest.IsEmpty() then
            exit;

        if PostingDocumentNo = '' then begin
            SubscriptionRequest.TestField("Posting Document No.");
            PostingDocumentNo := SubscriptionRequest."Posting Document No.";
        end;

        Subscription.Get(SubscriptionRequest."Subscription Entry No.");
        Membership.Get(Subscription."Membership Entry No.");
        Membership.TestField("Customer No.");
        MembershipSetup.Get(SubscriptionRequest."Membership Code");
        MembershipSetup.TestField("Recurring Payment Code");
        RecurringPaymentSetup.Get(MembershipSetup."Recurring Payment Code");
        RecurringPaymentSetup.TestField("Source Code");

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        SubscrPaymentRequest.ReadIsolation := IsolationLevel::UpdLock;
#else
        SubscrPaymentRequest.LockTable();
#endif
        if SubscrPaymentRequest.FindSet() then
            repeat
                PostPayment(SubscriptionRequest, SubscrPaymentRequest, Membership, RecurringPaymentSetup, PostingDocumentNo);
            until SubscrPaymentRequest.Next() = 0;
    end;

    local procedure PostPayment(SubscriptionRequest: Record "NPR MM Subscr. Request"; SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; Membership: Record "NPR MM Membership"; RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup"; PostingDocumentNo: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
        AppliesToDocType: Enum "Gen. Journal Document Type";
        PaymentAccountType: Enum "Gen. Journal Account Type";
        AppliesToDocNo: Code[20];
        PaymentAccountNo: Code[20];
        PostingDescription: Text;
    begin
        if SubscrPaymentRequest.Posted then
            exit;
        PostingDescription := StrSubstNo(AUTORENEW_TEXT, Membership."External Membership No.", SubscriptionRequest."New Valid From Date", SubscriptionRequest."New Valid Until Date");
        if (SubscrPaymentRequest.Type = SubscrPaymentRequest.Type::Payment) or (SubscrPaymentRequest.Type = SubscrPaymentRequest.Type::PayByLink) then
            SubscrPaymentRequest."Posting Document Type" := SubscrPaymentRequest."Posting Document Type"::Payment
        else
            SubscrPaymentRequest."Posting Document Type" := SubscrPaymentRequest."Posting Document Type"::Refund;
        SubscrPaymentRequest."Posting Document No." := PostingDocumentNo;
        SubscrPaymentRequest."Posting Date" := Today();
        SetAppliesToDoc(SubscriptionRequest, SubscrPaymentRequest, AppliesToDocType, AppliesToDocNo);

        //Payment account
        SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
        SubscrPaymentIHandler.GetPaymentPostingAccount(PaymentAccountType, PaymentAccountNo);
        InitGenJnlLine(GenJnlLine,
            SubscrPaymentRequest."Posting Document Type", SubscrPaymentRequest."Posting Document No.", SubscrPaymentRequest."Posting Date",
            PaymentAccountType, PaymentAccountNo,
            SubscrPaymentRequest.Amount, SubscrPaymentRequest."Currency Code", false,
            0, RecurringPaymentSetup."Source Code", PostingDescription);
        SubscrPaymentRequest."G/L Entry No." := GenJnlPostLine.RunWithCheck(GenJnlLine);
        SubscrPaymentRequest.Posted := SubscrPaymentRequest."G/L Entry No." <> 0;

        //Customer account
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", Membership."Customer No.");
        GenJnlLine.Validate(Amount, -GenJnlLine.Amount);
        GenJnlLine."Applies-to Doc. Type" := AppliesToDocType;
        GenJnlLine."Applies-to Doc. No." := AppliesToDocNo;
        GenJnlPostLine.RunWithCheck(GenJnlLine);
        SubscrPaymentRequest."Cust. Ledger Entry No." := GetLastPostedGLEntryNo();
        SubscrPaymentRequest.Modify();
    end;

    local procedure InitGenJnlLine(var GenJnlLine: Record "Gen. Journal Line";
                                   DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; PostingDate: Date;
                                   AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
                                   Amount: Decimal; CurrencyCode: Code[20]; UseVAT: Boolean;
                                   DimensionSetID: Integer; SourceCode: Code[10]; Description: Text)
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        GenJnlLine.Init();
        GenJnlLine.SetSuppressCommit(true);
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document Date" := PostingDate;
        GenJnlLine."Document Type" := DocumentType;
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := AccountType;
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := UseVAT;
        GenJnlLine.Validate("Account No.", AccountNo);
        if CurrencyCode <> '' then
            GenJnlLine.Validate("Currency Code", CurrencyCode);
        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine.Description := CopyStr(Description, 1, MaxStrLen(GenJnlLine.Description));
        if DimensionSetID <> 0 then begin
            GenJnlLine."Dimension Set ID" := DimensionSetID;
            DimMgt.UpdateGlobalDimFromDimSetID(GenJnlLine."Dimension Set ID", GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");
        end;
        GenJnlLine."Source Code" := SourceCode;
    end;

    internal procedure GetPostingDocumentNo(RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup"): Code[20]
    var
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
        NoSeriesManagement: Codeunit NoSeriesManagement;
#else
        NoSeries: Codeunit "No. Series";
#endif
    begin
        RecurringPaymentSetup.TestField("Document No. Series");
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23
        exit(NoSeriesManagement.GetNextNo(RecurringPaymentSetup."Document No. Series", Today(), true));
#else
        exit(NoSeries.GetNextNo(RecurringPaymentSetup."Document No. Series", Today()));
#endif
    end;

    internal procedure CalcRevenueVAT(MembershipEntryNo: Integer): Decimal
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup";
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Membership.SetLoadFields("Membership Code");
        Membership.Get(MembershipEntryNo);

        MembershipSetup.SetLoadFields("Recurring Payment Code");
        MembershipSetup.Get(Membership."Membership Code");
        MembershipSetup.TestField("Recurring Payment Code");

        RecurringPaymentSetup.SetLoadFields("Revenue Account");
        RecurringPaymentSetup.Get(MembershipSetup."Recurring Payment Code");
        RecurringPaymentSetup.TestField("Revenue Account");

        GLAccount.SetLoadFields("VAT Bus. Posting Group", "VAT Prod. Posting Group");
        GLAccount.Get(RecurringPaymentSetup."Revenue Account");

        VATPostingSetup.SetLoadFields("VAT %");
        VATPostingSetup.Get(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
        exit(VATPostingSetup."VAT %");
    end;

    local procedure SetAppliesToDoc(SubscriptionRequest: Record "NPR MM Subscr. Request"; var AppliesToDocType: Enum "Gen. Journal Document Type"; var AppliesToDocNo: Code[20])
    begin
        if SubscriptionRequest."Posting Document Type" = SubscriptionRequest."Posting Document Type"::"Credit Memo" then begin
            SubscriptionRequest.SetRange("Reversed by Entry No.", SubscriptionRequest."Entry No.");
            SubscriptionRequest.SetFilter("Entry No.", '<>%1', SubscriptionRequest."Entry No.");
            if SubscriptionRequest.FindLast() and (SubscriptionRequest."Cust. Ledger Entry No." <> 0) then
                if UnapplyCustomerLedgerEntry(SubscriptionRequest."Cust. Ledger Entry No.", SubscriptionRequest."Posting Document No.", SubscriptionRequest."Posting Date") then begin
                    AppliesToDocType := SubscriptionRequest."Posting Document Type";
                    AppliesToDocNo := SubscriptionRequest."Posting Document No.";
                end;
        end;
    end;

    local procedure SetAppliesToDoc(SubscriptionRequest: Record "NPR MM Subscr. Request"; SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var AppliesToDocType: Enum "Gen. Journal Document Type"; var AppliesToDocNo: Code[20])
    begin
        if SubscrPaymentRequest."Posting Document Type" = SubscrPaymentRequest."Posting Document Type"::Refund then begin
            SubscrPaymentRequest.SetRange("Reversed by Entry No.", SubscrPaymentRequest."Entry No.");
            SubscrPaymentRequest.SetFilter("Entry No.", '<>%1', SubscrPaymentRequest."Entry No.");
            if SubscrPaymentRequest.FindLast() and (SubscrPaymentRequest."Cust. Ledger Entry No." <> 0) then
                if UnapplyCustomerLedgerEntry(SubscrPaymentRequest."Cust. Ledger Entry No.", SubscrPaymentRequest."Posting Document No.", SubscrPaymentRequest."Posting Date") then begin
                    AppliesToDocType := SubscrPaymentRequest."Posting Document Type";
                    AppliesToDocNo := SubscrPaymentRequest."Posting Document No.";
                    exit;
                end;
        end;
        AppliesToDocType := SubscriptionRequest."Posting Document Type";
        AppliesToDocNo := SubscriptionRequest."Posting Document No.";
    end;

    local procedure UnapplyCustomerLedgerEntry(CustLedgEntryNo: Integer; PostingDocNo: Code[20]; PostingDate: Date): Boolean
    var
#if not (BC17 or BC18 or BC19)
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
#endif
        CustLedgEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        CustEntryUnapplyModifier: Codeunit "NPR CustEntry-Unapply Modifier";
        ApplicationEntryNo: Integer;
    begin
        CustLedgEntry.Get(CustLedgEntryNo);
        if CustLedgEntry.Reversed then
            exit(false);
        ApplicationEntryNo := CustEntryApplyPostedEntries.FindLastApplEntry(CustLedgEntryNo);
        if ApplicationEntryNo = 0 then
            exit(true);
        DetailedCustLedgEntry.Get(ApplicationEntryNo);
        BindSubscription(CustEntryUnapplyModifier);
#if not (BC17 or BC18 or BC19)        
        ApplyUnapplyParameters."Document No." := PostingDocNo;
        ApplyUnapplyParameters."Posting Date" := PostingDate;
        CustEntryApplyPostedEntries.PostUnApplyCustomerCommit(DetailedCustLedgEntry, ApplyUnapplyParameters, false);
#else
        CustEntryApplyPostedEntries.PostUnApplyCustomerCommit(DetailedCustLedgEntry, PostingDocNo, PostingDate, false);
#endif
        UnbindSubscription(CustEntryUnapplyModifier);
        exit(true);
    end;

    local procedure GetLastPostedGLEntryNo(): Integer
    var
        GLReg: Record "G/L Register";
    begin
        GenJnlPostLine.GetGLReg(GLReg);
        exit(GLReg."To Entry No.");
    end;
}