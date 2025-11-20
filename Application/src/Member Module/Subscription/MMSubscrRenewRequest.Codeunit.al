codeunit 6185047 "NPR MM Subscr. Renew: Request"
{
    Access = Internal;
    TableNo = "NPR MM Subscription";

    var
        _RecurPaymentSetup: Record "NPR MM Recur. Paym. Setup";
        _RenewalSchedLine: Record "NPR MM Renewal Sched Line";
        _BatchNo: Integer;
        _SkipProcessSubscriptionCheck: Boolean;
        SubsPayReqUtils: Codeunit "NPR MM Subs Pay Request Utils";

    trigger OnRun()
    var
        Subscription: Record "NPR MM Subscription";
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        Subscription.ReadIsolation := IsolationLevel::UpdLock;
#else
        Subscription.LockTable();
#endif
        Subscription := Rec;
        Subscription.Find();
        CreateSubscriptionRenewalRequest(Subscription);
    end;

    local procedure CreateSubscriptionRenewalRequest(var Subscription: Record "NPR MM Subscription")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        RenewWithItemNo: Code[20];
        RenewDescrTxt: Label '%1 membership renewal: %2-%3', Comment = '%1 - membership code, %2 - from date, %3 - to date';
    begin
        GetRecurringPaymentSetup(Subscription."Membership Code");
        if _RecurPaymentSetup."Subscr. Auto-Renewal On" = _RecurPaymentSetup."Subscr. Auto-Renewal On"::Never then
            _RecurPaymentSetup.FieldError("Subscr. Auto-Renewal On");

        CheckSubscriptionCanBeProcessed(Subscription);
        GetRenewalScheduleLine(Subscription);
        CalculateSubscriptionRenewal(Subscription, SubscriptionRequest, RenewWithItemNo);

        if _RecurPaymentSetup."Subscr. Auto-Renewal On" = _RecurPaymentSetup."Subscr. Auto-Renewal On"::"Next Start Date" then
            if SubscriptionRequest."New Valid From Date" - _RecurPaymentSetup."First Attempt Offset (Days)" > Today() then begin
                Subscription."Postpone Renewal Attempt Until" := SubscriptionRequest."New Valid From Date" - _RecurPaymentSetup."First Attempt Offset (Days)";
                Subscription.Modify(true);
                exit;
            end;

        SubscriptionRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscriptionRequest."Membership Code" := Subscription."Membership Code";
        SubscriptionRequest.Type := SubscriptionRequest.Type::Renew;
        SubscriptionRequest."Item No." := RenewWithItemNo;
        SubscriptionRequest.Status := SubscriptionRequest.Status::New;
        if SubscriptionRequest.Description = '' then
            SubscriptionRequest.Description := CopyStr(StrSubstNo(RenewDescrTxt, Subscription."Membership Code", Format(SubscriptionRequest."New Valid From Date", 0, 7), Format(SubscriptionRequest."New Valid Until Date", 0, 7)), 1, MaxStrLen(SubscriptionRequest.Description));
        SubscriptionRequest."Entry No." := 0;
        SubscriptionRequest."Renew Schedule Date" := WorkDate();
        SubscriptionRequest."Renew Schedule Date Formula" := _RenewalSchedLine."Date Formula";
        SubscriptionRequest."Renew Schedule Id" := _RenewalSchedLine.SystemId;
        SubscriptionRequest.Insert();

        CreateSubscriptionPaymentRequest(Subscription, SubscriptionRequest, SubscrPaymentRequest);
        Commit();
    end;

    internal procedure CreateSubscriptionPaymentMethodCollectionRequest(var Subscription: Record "NPR MM Subscription"; PSP: Enum "NPR MM Subscription PSP"; var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; AutoRenewStatus: Boolean)
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionBlockedErrorLbl: Label 'Subscription no. %1 is blocked.', Comment = '%1 - subscription no.';
        PaymentMtdCollectDescrTxt: Label '%1 membership Payment Method Collection', Comment = '%1 - membership code';
    begin
        if Subscription.Blocked then
            Error(SubscriptionBlockedErrorLbl, Subscription."Entry No.");

        SubscriptionRequest.Init();
        SubscriptionRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscriptionRequest."Membership Code" := Subscription."Membership Code";
        SubscriptionRequest.Type := SubscriptionRequest.Type::"Payment Method Collection";
        SubscriptionRequest.Status := SubscriptionRequest.Status::New;
        SubscriptionRequest.Description := CopyStr(StrSubstNo(PaymentMtdCollectDescrTxt, Subscription."Membership Code"), 1, MaxStrLen(SubscriptionRequest.Description));
        SubscriptionRequest."Entry No." := 0;
        SubscriptionRequest.Insert();

        CreatePaymentMethodCollectionSubscPaymentRequest(Subscription, SubscriptionRequest, SubscrPaymentRequest, PSP, AutoRenewStatus);
        Commit();
    end;

    internal procedure CalculateSubscriptionRenewal(Subscription: Record "NPR MM Subscription"; var SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        RenewWithItemNo: Code[20];
    begin
        CalculateSubscriptionRenewal(Subscription, SubscriptionRequest, RenewWithItemNo);
    end;

    local procedure CalculateSubscriptionRenewal(Subscription: Record "NPR MM Subscription"; var SubscriptionRequest: Record "NPR MM Subscr. Request"; var RenewWithItemNo: Code[20])
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipLedger: Record "NPR MM Membership Entry";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        AlterationRuleSystemId: Guid;
        ReasonText: Text;
        RenewDescrTxt: Label '%1 -> %2 membership renewal: %3-%4', Comment = '%1 - old membership code, %2 - new membership code, %3 - from date, %4 - to date';
    begin
        MembershipLedger.Get(Subscription."Membership Ledger Entry No.");
        if not MembershipMgt.SelectAutoRenewRule(MembershipLedger, RenewWithItemNo, AlterationRuleSystemId, ReasonText) then
            Error(ReasonText);
        MembershipAlterationSetup.GetBySystemId(AlterationRuleSystemId);

        SubscriptionRequest.Init();

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        MemberInfoCapture."Membership Entry No." := Subscription."Membership Entry No.";
        MemberInfoCapture."Membership Code" := MembershipAlterationSetup."From Membership Code";
        MemberInfoCapture."Item No." := MembershipAlterationSetup."Sales Item No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::AUTORENEW;

        if not MembershipMgt.AutoRenewMembership(MemberInfoCapture, false, Subscription."Valid Until Date", SubscriptionRequest."New Valid From Date", SubscriptionRequest."New Valid Until Date", SubscriptionRequest.Amount, ReasonText) then
            Error(ReasonText);

        if Subscription."Membership Code" <> MemberInfoCapture."Membership Code" then
            SubscriptionRequest.Description := CopyStr(StrSubstNo(RenewDescrTxt, Subscription."Membership Code", MemberInfoCapture."Membership Code", Format(SubscriptionRequest."New Valid From Date", 0, 7), Format(SubscriptionRequest."New Valid Until Date", 0, 7)), 1, MaxStrLen(SubscriptionRequest.Description))
    end;

    Internal procedure CreateSubscriptionPaymentRequest(Subscription: Record "NPR MM Subscription"; SubscriptionRequest: Record "NPR MM Subscr. Request"; var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
    begin
        PaymentMethodMgt.TryGetMemberPaymentMethod(Subscription, true, MemberPaymentMethod);
        MemberPaymentMethod.TestField(PSP);
        MemberPaymentMethod.TestField("Payment Token");

        SubscrPaymentRequest.Init();
        SubscrPaymentRequest."Entry No." := 0;
        SubscrPaymentRequest."Batch No." := GetBatchNo();
        SubscrPaymentRequest."Subscr. Request Entry No." := SubscriptionRequest."Entry No.";
        SubscrPaymentRequest.Type := SubscrPaymentRequest.Type::Payment;
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::New;
        SubscrPaymentRequest.PSP := MemberPaymentMethod.PSP;
        SubscrPaymentRequest."Payment Method Entry No." := MemberPaymentMethod."Entry No.";
        SubscrPaymentRequest."Payment Token" := MemberPaymentMethod."Payment Token";
        SubscrPaymentRequest.Amount := SubscriptionRequest.Amount;
        SubscrPaymentRequest."Currency Code" := SubscriptionRequest."Currency Code";
        SubscrPaymentRequest.Description := SubscriptionRequest.Description;
        SubscrPaymentRequest."Subscription Payment Reference" := CopyStr(SubsPayReqUtils.GenerateSubscriptionPaymentReference(), 1, MaxStrLen(SubscrPaymentRequest."Subscription Payment Reference"));
        SubscrPaymentRequest.Insert();
    end;

    Internal procedure CreatePaymentMethodCollectionSubscPaymentRequest(Subscription: Record "NPR MM Subscription"; SubscriptionRequest: Record "NPR MM Subscr. Request"; var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; PSP: Enum "NPR MM Subscription PSP"; AutoRenew: Boolean)
    begin
        SubscrPaymentRequest.Init();
        SubscrPaymentRequest."Entry No." := 0;
        SubscrPaymentRequest."Batch No." := GetBatchNo();
        SubscrPaymentRequest."Subscr. Request Entry No." := SubscriptionRequest."Entry No.";
        SubscrPaymentRequest.Type := SubscrPaymentRequest.Type::PayByLink;
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::New;
        SubscrPaymentRequest.PSP := PSP;
        SubscrPaymentRequest.Amount := SubscriptionRequest.Amount;
        SubscrPaymentRequest."Currency Code" := SubscriptionRequest."Currency Code";
        SubscrPaymentRequest.Description := SubscriptionRequest.Description;
        SubscrPaymentRequest."Set Membership Auto-Renew" := AutoRenew;
        SubscrPaymentRequest."Subscription Payment Reference" := CopyStr(SubsPayReqUtils.GenerateSubscriptionPaymentReference(), 1, MaxStrLen(SubscrPaymentRequest."Subscription Payment Reference"));
        SubscrPaymentRequest.Insert();
    end;

    internal procedure GetBatchNo(): Integer
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        if _BatchNo = 0 then begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
            SubscrPaymentRequest.ReadIsolation := IsolationLevel::UpdLock;
#else
            SubscrPaymentRequest.LockTable();
#endif
            SubscrPaymentRequest.SetCurrentKey("Batch No.");
            if SubscrPaymentRequest.FindLast() then
                _BatchNo := SubscrPaymentRequest."Batch No." + 1
            else
                _BatchNo := 1;
        end;
        exit(_BatchNo);
    end;

    local procedure GetRecurringPaymentSetup(MembershipCode: Code[20])
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        if _RecurPaymentSetup.Code <> '' then
            exit;
        MembershipSetup.Get(MembershipCode);
        _RecurPaymentSetup.Get(MembershipSetup."Recurring Payment Code");
    end;

    internal procedure SetRecurringPaymentSetup(RecurPaymentSetupIn: Record "NPR MM Recur. Paym. Setup")
    begin
        _RecurPaymentSetup := RecurPaymentSetupIn;
    end;

    internal procedure SetRenewalSchedLine(RenewalSchedLine: Record "NPR MM Renewal Sched Line")
    begin
        _RenewalSchedLine := RenewalSchedLine;
    end;

    internal procedure SetSkipProcessSubscriptionCheck(SkipProcessSubscriptionCheck: Boolean)
    begin
        _SkipProcessSubscriptionCheck := SkipProcessSubscriptionCheck
    end;

    internal procedure GetSkipProcessSubscriptionCheck(SkipProcessSubscriptionCheck: Boolean)
    begin
        _SkipProcessSubscriptionCheck := SkipProcessSubscriptionCheck
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Subscr. Payment Request", 'OnBeforeModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Subscr. Payment Request", OnBeforeModifyEvent, '', false, false)]
#endif
    local procedure RefreshxRec(var Rec: Record "NPR MM Subscr. Payment Request"; var xRec: Record "NPR MM Subscr. Payment Request")
    begin
        if Rec.IsTemporary() then
            exit;

        if not xRec.Find() then
            Clear(xRec);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Subscr. Payment Request", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Subscr. Payment Request", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure UpdateSubscriptionRequestStatus(var Rec: Record "NPR MM Subscr. Payment Request"; var xRec: Record "NPR MM Subscr. Payment Request"; RunTrigger: Boolean)
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        xSubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        ProcessingStatusErrorLbl: Label 'Subscription request %1 has already been processed.', Comment = '%1 - subscription request no.';
    begin
        if Rec.IsTemporary() then
            exit;

        if not RunTrigger then
            exit;

        if Rec.Status in [xRec.Status, Rec.Status::New] then
            exit;

        SubscriptionRequest.Get(Rec."Subscr. Request Entry No.");
        if (SubscriptionRequest.Status <> SubscriptionRequest.Status::Cancelled) and (Rec.Status <> Rec.Status::Cancelled) then
            if SubscriptionRequest."Processing Status" = SubscriptionRequest."Processing Status"::Success then
                Error(ProcessingStatusErrorLbl, SubscriptionRequest."Entry No.");

        xSubscriptionRequest := SubscriptionRequest;

        case Rec.Status of
            Rec.Status::Requested,
            Rec.Status::Authorized:
                SubscriptionRequest.Status := SubscriptionRequest.Status::Requested;
            Rec.Status::Captured:
                SubscriptionRequest.Status := SubscriptionRequest.Status::Confirmed;
            Rec.Status::Rejected:
                SubscriptionRequest.Status := SubscriptionRequest.Status::Rejected;
            Rec.Status::Cancelled:
                SubscriptionRequest.Status := SubscriptionRequest.Status::Cancelled;
            Rec.Status::Error:
                SubscriptionRequest.Status := SubscriptionRequest.Status::"Request Error";
        end;
        if SubscriptionRequest.Status <> xSubscriptionRequest.Status then begin
            if (SubscriptionRequest.Status = SubscriptionRequest.Status::Cancelled) and (Rec.Status = Rec.Status::Cancelled) then begin
                SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
                SubscrPaymentRequest.SetFilter(Status, '<>%1', SubscrPaymentRequest.Status::Cancelled);
                SubscrPaymentRequest.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
                if SubscrPaymentRequest.IsEmpty() then
                    SubscriptionRequest.Validate("Processing Status", SubscriptionRequest."Processing Status"::Success)
                else
                    SubscriptionRequest.Validate("Processing Status", SubscriptionRequest."Processing Status"::Pending);
            end else
                SubscriptionRequest.Validate("Processing Status", SubscriptionRequest."Processing Status"::Pending);
            SubscriptionRequest."Process Try Count" := 0;
            SubscriptionRequest.Modify(true);

            if SubscriptionRequest.Status = SubscriptionRequest.Status::Cancelled then
                SubscrReversalMgt.CancelReversal(SubscriptionRequest);
        end;
    end;

    local procedure CheckSubscriptionCanBeProcessed(Subscription: Record "NPR MM Subscription")
    var
        ValidUntilDate: Date;
        SubscriptionBlockedErrorLbl: Label 'Subscription no. %1 is blocked.', Comment = '%1 - subscription no.';
        SubscriptionValidErrorLbl: Label 'Subscription no. %1 is valid until %2.', Comment = '%1 - subscription no., %2 - valid until';
        PostponedRenewalErrorLbl: Label 'Renewal of subscription no. %1 is postponed until %2.', Comment = '%1 - subscription no., %2 - postponed until date';
        SubscriptionRequestExistsErrorLbl: Label 'Subscription request for subscription no. %1 already exists.', Comment = '%1 - subscription no.';
        MemberhsipNotSetForAutoRenewErrorLbl: Label 'Membership %1 for subscription %2 is not set to auto renew.', Comment = '% - membership no., %2 - subscription no.';
    begin
        if _SkipProcessSubscriptionCheck then
            exit;

        if Subscription.Blocked then
            Error(SubscriptionBlockedErrorLbl, Subscription."Entry No.");

        if _RecurPaymentSetup."Subscr. Auto-Renewal On" in [_RecurPaymentSetup."Subscr. Auto-Renewal On"::"Next Start Date", _RecurPaymentSetup."Subscr. Auto-Renewal On"::"Expiry Date"] then begin
            ValidUntilDate := Today() + _RecurPaymentSetup."First Attempt Offset (Days)";
            if Subscription."Valid Until Date" > ValidUntilDate then
                Error(SubscriptionValidErrorLbl, Subscription."Entry No.", Subscription."Valid Until Date");
        end;
        if Subscription."Postpone Renewal Attempt Until" > Today() then
            Error(PostponedRenewalErrorLbl, Subscription."Entry No.", Subscription."Postpone Renewal Attempt Until");

        Subscription.SetFilter("Subscr. Request Type Filter", '<>%1', Subscription."Subscr. Request Type Filter"::"Payment Method Collection");
        Subscription.CalcFields("Outst. Subscr. Requests Exist");
        if Subscription."Outst. Subscr. Requests Exist" then
            Error(SubscriptionRequestExistsErrorLbl, Subscription."Entry No.");

        if Subscription."Auto-Renew" <> Subscription."Auto-Renew"::YES_INTERNAL then
            Error(MemberhsipNotSetForAutoRenewErrorLbl, Subscription."Membership Entry No.", Subscription."Entry No.");
    end;

    local procedure GetRenewalScheduleLine(Subscription: Record "NPR MM Subscription")
    var
        CurrRenewalSchedLine: Record "NPR MM Renewal Sched Line";
        RenewalDate: Date;
        RenewalDateValid: Boolean;
        SubscriptionScheduleValidErrorLbl: Label 'Subscription no. %1 is outside of its renewal schedule.', Comment = '%1 - subscription no.';
    begin
        if _RenewalSchedLine."Schedule Code" <> '' then
            exit;

        if _RecurPaymentSetup."Subscr. Auto-Renewal On" <> _RecurPaymentSetup."Subscr. Auto-Renewal On"::Schedule then
            exit;

        _RecurPaymentSetup.TestField("Subscr Auto-Renewal Sched Code");

        CurrRenewalSchedLine.Reset();
        CurrRenewalSchedLine.SetRange("Schedule Code", _RecurPaymentSetup."Subscr Auto-Renewal Sched Code");
        CurrRenewalSchedLine.SetCurrentKey("Schedule Code", "Date Formula Duration (Days)");
        if CurrRenewalSchedLine.FindSet() then
            repeat
                RenewalDate := WorkDate() - CurrRenewalSchedLine."Date Formula Duration (Days)";
                RenewalDateValid := RenewalDate = Subscription."Valid Until Date";
                if RenewalDateValid then
                    _RenewalSchedLine := CurrRenewalSchedLine;
            until (CurrRenewalSchedLine.Next() = 0) or RenewalDateValid;

        if not RenewalDateValid then
            Error(SubscriptionScheduleValidErrorLbl, Subscription."Entry No.");
    end;
}