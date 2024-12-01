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
        PostingDescription: Text;
    begin
        if SubscriptionRequest.Posted then
            exit(true);

        Membership.TestField("Customer No.");
        MembershipSetup.TestField("Recurring Payment Code");
        RecurringPaymentSetup.Get(MembershipSetup."Recurring Payment Code");
        RecurringPaymentSetup.TestField("Revenue Account");
        RecurringPaymentSetup.TestField("Source Code");

        if SubscriptionRequest."Posting Document No." = '' then
            SubscriptionRequest."Posting Document No." := GetPostingDocumentNo(RecurringPaymentSetup);
        PostingDescription := StrSubstNo(AUTORENEW_TEXT, Membership."External Membership No.", SubscriptionRequest."New Valid From Date", SubscriptionRequest."New Valid Until Date");

        //Revenue account
        InitGenJnlLine(GenJnlLine,
            GenJnlLine."Document Type"::Invoice, SubscriptionRequest."Posting Document No.",
            GenJnlLine."Account Type"::"G/L Account", RecurringPaymentSetup."Revenue Account",
            -SubscriptionRequest.Amount, SubscriptionRequest."Currency Code", true,
            0, RecurringPaymentSetup."Source Code", PostingDescription);
        SubscriptionRequest."G/L Entry No." := GenJnlPostLine.RunWithCheck(GenJnlLine);
        SubscriptionRequest."Posting Date" := GenJnlLine."Posting Date";
        SubscriptionRequest.Posted := SubscriptionRequest."G/L Entry No." <> 0;

        //Customer account
        InitGenJnlLine(GenJnlLine,
            GenJnlLine."Document Type"::Invoice, SubscriptionRequest."Posting Document No.",
            GenJnlLine."Account Type"::Customer, Membership."Customer No.",
            SubscriptionRequest.Amount, SubscriptionRequest."Currency Code", false,
            0, RecurringPaymentSetup."Source Code", PostingDescription);
        GenJnlPostLine.RunWithCheck(GenJnlLine);

        exit(SubscriptionRequest.Posted);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure PostPaymentsToGL(SubscriptionRequest: Record "NPR MM Subscr. Request")
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

        SubscriptionRequest.TestField("Posting Document No.");

        Subscription.Get(SubscriptionRequest."Subscription Entry No.");
        Membership.Get(Subscription."Membership Entry No.");
        Membership.TestField("Customer No.");
        MembershipSetup.Get(Membership."Membership Code");
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
                PostPayment(SubscriptionRequest, SubscrPaymentRequest, Membership, RecurringPaymentSetup);
            until SubscrPaymentRequest.Next() = 0;
    end;

    local procedure PostPayment(SubscriptionRequest: Record "NPR MM Subscr. Request"; SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; Membership: Record "NPR MM Membership"; RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup")
    var
        GenJnlLine: Record "Gen. Journal Line";
        SubscrPaymentIHandler: Interface "NPR MM Subscr.Payment IHandler";
        PaymentAccountType: Enum "Gen. Journal Account Type";
        PaymentAccountNo: Code[20];
        PostingDescription: Text;
    begin
        if SubscrPaymentRequest.Posted then
            exit;
        PostingDescription := StrSubstNo(AUTORENEW_TEXT, Membership."External Membership No.", SubscriptionRequest."New Valid From Date", SubscriptionRequest."New Valid Until Date");

        //Payment account
        SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
        SubscrPaymentIHandler.GetPaymentPostingAccount(PaymentAccountType, PaymentAccountNo);
        InitGenJnlLine(GenJnlLine,
            GenJnlLine."Document Type"::Payment, SubscriptionRequest."Posting Document No.",
            PaymentAccountType, PaymentAccountNo,
            SubscrPaymentRequest.Amount, SubscrPaymentRequest."Currency Code", false,
            0, RecurringPaymentSetup."Source Code", PostingDescription);
        SubscrPaymentRequest."G/L Entry No." := GenJnlPostLine.RunWithCheck(GenJnlLine);
        SubscrPaymentRequest."Posting Document No." := SubscriptionRequest."Posting Document No.";
        SubscrPaymentRequest.Posted := SubscrPaymentRequest."G/L Entry No." <> 0;
        SubscrPaymentRequest."Posting Date" := GenJnlLine."Posting Date";
        SubscrPaymentRequest.Modify();

        //Customer account
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Customer;
        GenJnlLine.Validate("Account No.", Membership."Customer No.");
        GenJnlLine.Validate(Amount, -GenJnlLine.Amount);
        GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
        GenJnlLine."Applies-to Doc. No." := SubscriptionRequest."Posting Document No.";
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure InitGenJnlLine(var GenJnlLine: Record "Gen. Journal Line";
                                   DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20];
                                   AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
                                   Amount: Decimal; CurrencyCode: Code[20]; UseVAT: Boolean;
                                   DimensionSetID: Integer; SourceCode: Code[10]; Description: Text)
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        GenJnlLine.Init();
        GenJnlLine.SetSuppressCommit(true);
        GenJnlLine."Posting Date" := Today();
        GenJnlLine."Document Date" := Today();
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

    local procedure GetPostingDocumentNo(RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup"): Code[20]
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
}