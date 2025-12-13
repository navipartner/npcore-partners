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
        DeferralCode: Code[10];
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
        RecurringPaymentSetup.CheckSourceCodeIsValid();
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
        TestFieldAccountDeferralCode(RecurringPaymentSetup."Revenue Account");

        //Revenue account
        InitGenJnlLine(GenJnlLine,
            SubscriptionRequest."Posting Document Type", SubscriptionRequest."Posting Document No.", SubscriptionRequest."Posting Date",
            GenJnlLine."Account Type"::"G/L Account", RecurringPaymentSetup."Revenue Account",
            -SubscriptionRequest.Amount, SubscriptionRequest."Currency Code", true,
            0, RecurringPaymentSetup."Source Code", PostingDescription);
        AssignAndCalculateDeferralSchedule(SubscriptionRequest, GenJnlLine, DeferralCode);
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

        if SubscriptionRequest.Posted then
            MoveDeferralScheduleToPosted(SubscriptionRequest, DeferralCode);

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

    local procedure AssignAndCalculateDeferralSchedule(SubscriptionRequest: Record "NPR MM Subscr. Request"; var GenJnlLine: Record "Gen. Journal Line"; var DeferralCode: Code[10])
    var
        DeferralHeader: Record "Deferral Header";
        DeferralTemplate: Record "Deferral Template";
        Item: Record Item;
        DeferralUtilities: Codeunit "Deferral Utilities";
        AmtToDefer: Decimal;
        AmtToDeferLCY: Decimal;
    begin
        AmtToDefer := -(GenJnlLine.Amount - GenJnlLine."VAT Amount");
        if AmtToDefer = 0 then
            exit;
        if DeferralHeader.Get(Enum::"Deferral Document Type"::"G/L", '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0) then
            exit;
        if Item.Get(SubscriptionRequest."Item No.") then
            DeferralCode := Item."Default Deferral Template Code";
        if DeferralCode = '' then
            exit;

        AmtToDeferLCY := -(GenJnlLine."Amount (LCY)" - GenJnlLine."VAT Amount (LCY)");
        DeferralTemplate.Get(DeferralCode);
        DeferralUtilities.CreateDeferralSchedule(
            DeferralTemplate."Deferral Code", Enum::"Deferral Document Type"::"G/L".AsInteger(), '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0,
            AmtToDefer, DeferralTemplate."Calc. Method", GetDeferralStartingDate(SubscriptionRequest), GetDeferralNoOfPeriods(SubscriptionRequest, DeferralTemplate), false,
            DeferralTemplate.Description, false, GenJnlLine."Currency Code");

        if DeferralHeader.Get(Enum::"Deferral Document Type"::"G/L", '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0) then
            DeferralUtilities.RoundDeferralAmount(DeferralHeader, GenJnlLine."Currency Code", GenJnlLine."Currency Factor", GenJnlLine."Posting Date", AmtToDefer, AmtToDeferLCY);
        CreateDeferralBuffer(SubscriptionRequest, GenJnlLine, DeferralCode);
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Deferral Code" := DeferralCode;
    end;

    local procedure GetDeferralStartingDate(SubscriptionRequest: Record "NPR MM Subscr. Request") StartDate: Date
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipEntryLink: Record "NPR MM Membership Entry Link";
    begin
        StartDate := SubscriptionRequest."Posting Date";

        MembershipEntry.SetCurrentKey("Receipt No.", "Line No.");
        MembershipEntry.SetLoadFields("Valid From Date");
        if MembershipEntry.Get(SubscriptionRequest."Posted M/ship Ledg. Entry No.") then begin
            if MembershipEntry."Valid From Date" <> 0D then
                StartDate := MembershipEntry."Valid From Date";
        end else begin
            MembershipEntryLink.SetCurrentKey("Document Type", "Document No.");
            MembershipEntryLink.SetRange("Document Type", Database::"NPR MM Subscr. Request");
            MembershipEntryLink.SetRange("Document No.", Format(SubscriptionRequest."Entry No."));
            MembershipEntryLink.SetLoadFields(Context, "Context Period Starting Date");
            if not MembershipEntryLink.FindFirst() then
                exit;
            if MembershipEntryLink."Context Period Starting Date" <> 0D then
                if MembershipEntryLink.Context = MembershipEntryLink.Context::CANCEL then
                    StartDate := CalcDate('<+1D>', MembershipEntryLink."Context Period Starting Date")
                else
                    StartDate := MembershipEntryLink."Context Period Starting Date";
        end;
    end;

    local procedure GetDeferralNoOfPeriods(SubscriptionRequest: Record "NPR MM Subscr. Request"; DeferralTemplate: Record "Deferral Template") NoOfPeriods: Integer
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipEntryLink: Record "NPR MM Membership Entry Link";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        POSPostEntries: Codeunit "NPR POS Post Entries";
        InitialValidUntilDate: Date;
    begin
        NoOfPeriods := DeferralTemplate."No. of Periods";

        MembershipEntry.SetCurrentKey("Receipt No.", "Line No.");
        MembershipEntry.SetLoadFields("Entry No.", Context, "Valid From Date");
        if MembershipEntry.Get(SubscriptionRequest."Posted M/ship Ledg. Entry No.") then begin
            case MembershipEntry.Context of
                MembershipEntry.Context::UPGRADE:
                    begin
                        InitialValidUntilDate := MembershipMgtInternal.GetUpgradeInitialValidUntilDate(MembershipEntry."Entry No.");
                        if (MembershipEntry."Valid From Date" <> 0D) and (InitialValidUntilDate >= MembershipEntry."Valid From Date") then
                            NoOfPeriods := POSPostEntries.CountDefNoOfPeriodsBetweenDates(MembershipEntry."Valid From Date", InitialValidUntilDate);
                    end;
            end;
        end else begin
            MembershipEntryLink.SetCurrentKey("Document Type", "Document No.");
            MembershipEntryLink.SetRange("Document Type", Database::"NPR MM Subscr. Request");
            MembershipEntryLink.SetRange("Document No.", Format(SubscriptionRequest."Entry No."));
            MembershipEntryLink.SetLoadFields(Context, "Context Period Starting Date", "Context Period Ending Date");
            if not MembershipEntryLink.FindFirst() then
                exit;
            if (MembershipEntryLink."Context Period Starting Date" <> 0D) and (MembershipEntryLink."Context Period Ending Date" >= MembershipEntryLink."Context Period Starting Date") then
                if MembershipEntryLink.Context = MembershipEntryLink.Context::CANCEL then
                    NoOfPeriods := POSPostEntries.CountDefNoOfPeriodsBetweenDates(CalcDate('<+1D>', MembershipEntryLink."Context Period Starting Date"), MembershipEntryLink."Context Period Ending Date")
                else
                    NoOfPeriods := POSPostEntries.CountDefNoOfPeriodsBetweenDates(MembershipEntryLink."Context Period Starting Date", MembershipEntryLink."Context Period Ending Date");
        end;
    end;

    local procedure MoveDeferralScheduleToPosted(SubscriptionRequest: Record "NPR MM Subscr. Request"; DeferralCode: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DeferralTemplate: Record "Deferral Template";
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
        PostedDeferralHeader: Record "Posted Deferral Header";
        PostedDeferralLine: Record "Posted Deferral Line";
        DeferralUtilities: Codeunit "Deferral Utilities";
        CustomerNo: Code[20];
        DeferralAccount: Code[20];
    begin
        if DeferralCode = '' then
            exit;

        if DeferralHeader.Get(Enum::"Deferral Document Type"::"G/L", '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0) then begin
            DeferralTemplate.Get(DeferralCode);
            DeferralAccount := DeferralTemplate."Deferral Account";

            if CustLedgerEntry.Get(SubscriptionRequest."Cust. Ledger Entry No.") then
                CustomerNo := CustLedgerEntry."Customer No.";
            PostedDeferralHeader.InitFromDeferralHeader(
                DeferralHeader, '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0, DeferralAccount, CustomerNo, SubscriptionRequest."Posting Date");

            DeferralUtilities.FilterDeferralLines(
                DeferralLine, Enum::"Deferral Document Type"::"G/L".AsInteger(), '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0);
            if DeferralLine.FindSet() then
                repeat
                    PostedDeferralLine.InitFromDeferralLine(
                        DeferralLine, '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0, DeferralAccount);
                until DeferralLine.Next() = 0;
            DeferralHeader.Delete(true);
        end;
    end;

    internal procedure CreateDeferralBuffer(SubscriptionRequest: Record "NPR MM Subscr. Request"; GenJnlLine: Record "Gen. Journal Line"; DeferralCode: Code[10])
    var
        DeferralTemplate: Record "Deferral Template";
        DeferralPostingBuffer: Record "Deferral Posting Buffer";
        DeferralHeader: Record "Deferral Header";
        DeferralLine: Record "Deferral Line";
#if BC17 or BC18 or BC19 or BC21 or BC22 or BC23 or BC24
        TempInvoicePostingBuffer: Record "Invoice Post. Buffer" temporary;
#endif
        DeferralUtilities: Codeunit "Deferral Utilities";
        AmtToDeferACY: Decimal;
        AmtToDeferLCY: Decimal;
        NoDeferralScheduleErr: Label 'You must create a deferral schedule because you have specified the deferral code %2 in line %1.', Comment = '%1=The item number of the POS entry sales transaction line, %2=The Deferral Template Code';
        ZeroDeferralAmtErr: Label 'Deferral amounts cannot be 0. Line: %1, Deferral Template: %2.', Comment = '%1=The item number of the POS entry sales transaction line, %2=The Deferral Template Code';
    begin
        if DeferralCode = '' then
            exit;

        if not DeferralHeader.Get(Enum::"Deferral Document Type"::"G/L", '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0) then
            exit;
        DeferralTemplate.Get(DeferralCode);
        DeferralTemplate.TestField("Deferral Account");
        DeferralUtilities.FilterDeferralLines(
            DeferralLine, Enum::"Deferral Document Type"::"G/L".AsInteger(), '', '', Database::"NPR MM Subscr. Request", Format(SubscriptionRequest."Entry No."), 0);

        PrepareDeferralPostingBuffer(DeferralPostingBuffer, GenJnlLine, DeferralCode);
        DeferralPostingBuffer."Posting Date" := GenJnlLine."Posting Date";
        DeferralPostingBuffer.Description := GenJnlLine.Description;
        DeferralPostingBuffer."Period Description" := DeferralTemplate."Period Description";
        DeferralPostingBuffer."Deferral Line No." := 0;

        AmtToDeferACY := -(GenJnlLine.Amount - GenJnlLine."VAT Amount");
        AmtToDeferLCY := -(GenJnlLine."Amount (LCY)" - GenJnlLine."VAT Amount (LCY)");
#if BC17 or BC18 or BC19 or BC21 or BC22 or BC23 or BC24
        TempInvoicePostingBuffer.Amount := AmtToDeferLCY;
        TempInvoicePostingBuffer."Amount (ACY)" := AmtToDeferACY;
        DeferralPostingBuffer.PrepareInitialPair(TempInvoicePostingBuffer, TempInvoicePostingBuffer.Amount, TempInvoicePostingBuffer."Amount (ACY)", GenJnlLine."Account No.", DeferralTemplate."Deferral Account");
        DeferralPostingBuffer.ReverseAmounts();
        DeferralPostingBuffer.Update(DeferralPostingBuffer, TempInvoicePostingBuffer);
#else
        DeferralPostingBuffer.PrepareInitialAmounts(
            AmtToDeferLCY, AmtToDeferACY, AmtToDeferLCY, AmtToDeferACY, GenJnlLine."Account No.", DeferralTemplate."Deferral Account", 0, 0);
        DeferralPostingBuffer.ReverseAmounts();
        DeferralPostingBuffer.Update(DeferralPostingBuffer);
#endif
        if not DeferralLine.FindSet() then
            Error(NoDeferralScheduleErr, GenJnlLine."Document No.", DeferralCode);
        repeat
            if (DeferralLine."Amount (LCY)" <> 0) or (DeferralLine.Amount <> 0) then begin
                PrepareDeferralPostingBuffer(DeferralPostingBuffer, GenJnlLine, DeferralCode);
                DeferralPostingBuffer.InitFromDeferralLine(DeferralLine);
                DeferralPostingBuffer.ReverseAmounts();
                DeferralPostingBuffer."G/L Account" := GenJnlLine."Account No.";
                DeferralPostingBuffer."Deferral Account" := DeferralTemplate."Deferral Account";
                DeferralPostingBuffer."Period Description" := DeferralTemplate."Period Description";
                DeferralPostingBuffer."Deferral Line No." := 0;
#if BC17 or BC18 or BC19 or BC21 or BC22 or BC23 or BC24
                DeferralPostingBuffer.Update(DeferralPostingBuffer, TempInvoicePostingBuffer);
#else
                DeferralPostingBuffer.Update(DeferralPostingBuffer);
#endif
            end else
                Error(ZeroDeferralAmtErr, GenJnlLine."Document No.", DeferralCode);
        until DeferralLine.Next() = 0
    end;

    local procedure PrepareDeferralPostingBuffer(var DeferralPostingBuffer: Record "Deferral Posting Buffer"; GenJnlLine: Record "Gen. Journal Line"; DeferralCode: Code[10])
    begin
        Clear(DeferralPostingBuffer);
        DeferralPostingBuffer.Type := DeferralPostingBuffer.Type::Item;
        DeferralPostingBuffer."System-Created Entry" := true;
        DeferralPostingBuffer."Deferral Code" := DeferralCode;
        DeferralPostingBuffer."Deferral Doc. Type" := Enum::"Deferral Document Type"::Sales;
        DeferralPostingBuffer."Document No." := GenJnlLine."Document No.";
        DeferralPostingBuffer.SetRange("Deferral Doc. Type", DeferralPostingBuffer."Deferral Doc. Type");
        DeferralPostingBuffer.SetRange("Document No.", DeferralPostingBuffer."Document No.");
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

    local procedure TestFieldAccountDeferralCode(RevenueAccount: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(RevenueAccount);
        GLAccount.TestField("Default Deferral Template Code", '');
    end;
}
