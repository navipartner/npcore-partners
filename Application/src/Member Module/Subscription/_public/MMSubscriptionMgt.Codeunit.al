codeunit 6185029 "NPR MM Subscription Mgt."
{
    Access = Public;

    procedure PaymentRequestStatusesUpdated(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    begin

    end;

    /// <summary>
    /// Finds the membership related to a Subscription Payment Request
    /// </summary>
    /// <param name="SubscrPaymentRequest"></param>
    /// <returns>The Entry No. for the related Membership. Returns 0 if no Membership is found</returns>
    procedure GetMembershipForSubscriptionPaymentRequest(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") MembershipEntryNo: Integer
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
        Subscription: Record "NPR MM Subscription";
    begin
        SubscrRequest.SetLoadFields("Subscription Entry No.");
        Subscription.SetLoadFields("Membership Entry No.");
        if SubscrRequest.Get(SubscrPaymentRequest."Subscr. Request Entry No.") then
            if Subscription.Get(SubscrRequest."Subscription Entry No.") then
                exit(Subscription."Membership Entry No.");
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    /// <summary>
    /// Finds the memberships which are using a given PSP payment token
    /// </summary>
    /// <param name="PSP">The Payment Service Provider</param>
    /// <param name="PaymentToken">The Payment Token</param>
    /// <returns>A list of Membership Entry Nos</returns>
    procedure GetMembershipsForPSPToken(PSP: Enum "NPR MM Subscription PSP"; PaymentToken: Text[64]) ListOfMembershipEntryNo: List of [Integer]
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
    begin
        MemberPaymentMethod.SetRange(PSP, PSP);
        MemberPaymentMethod.SetRange("Payment Token", PaymentToken);
        MemberPaymentMethod.SetRange(Status, "NPR MM Payment Method Status"::Active);
        MemberPaymentMethod.SetLoadFields(SystemId);
        if MemberPaymentMethod.FindSet() then
            repeat
                MembershipPmtMethodMap.SetRange(PaymentMethodId, MemberPaymentMethod.SystemId);
                if MembershipPmtMethodMap.FindSet() then
                    repeat
                        if IsDefaultForRenewal(MembershipPmtMethodMap) then
                            AddToList(MembershipPmtMethodMap.MembershipId, ListOfMembershipEntryNo);
                    until MembershipPmtMethodMap.Next() = 0;
            until MemberPaymentMethod.Next() = 0;
    end;
#endif

    /// <summary>
    /// Set the status to Archived for all Membership Payment Methods related to a given PSP Payment Token
    /// </summary>
    /// <param name="PSP">The Payment Service Provider</param>
    /// <param name="PaymentToken">The Payment Token</param>
    procedure ArchivePSPPaymentToken(PSP: Enum "NPR MM Subscription PSP"; PaymentToken: Text[64])
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
    begin
        MemberPaymentMethod.SetRange(PSP, PSP);
        MemberPaymentMethod.SetRange("Payment Token", PaymentToken);
        if MemberPaymentMethod.FindSet(true) then
            repeat
                if MemberPaymentMethod.Status <> "NPR MM Payment Method Status"::Archived then begin
                    MemberPaymentMethod.Validate(Status, "NPR MM Payment Method Status"::Archived);
                    MemberPaymentMethod.Modify(true);
                end;
            until MemberPaymentMethod.Next() = 0;
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    local procedure IsDefaultForRenewal(MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap"): Boolean
    var
        DefaultMembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";

    begin
        if MembershipPmtMethodMap.Status <> "NPR MM Payment Method Status"::Active then
            exit(false);
        if MembershipPmtMethodMap.Default then
            exit(true);
        if PaymentMethodMgt.GetMembershipPaymentMethodMap(MembershipPmtMethodMap.MembershipId, true, DefaultMembershipPmtMethodMap) then
            exit(MembershipPmtMethodMap.PaymentMethodId = DefaultMembershipPmtMethodMap.PaymentMethodId);
    end;

    local procedure AddToList(MembershipId: Guid; var ListOfMembershipEntryNo: List of [Integer])
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.SetLoadFields("Entry No.");
        if not Membership.GetBySystemId(MembershipId) then
            exit;
        if not ListOfMembershipEntryNo.Contains(Membership."Entry No.") then
            ListOfMembershipEntryNo.Add(Membership."Entry No.");
    end;
#endif

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    /// <summary>
    /// Requests termination of a subscription for a given membership
    /// </summary>
    /// <param name="Membership">The membership record to terminate</param>
    /// <param name="RequestedDate">The requested termination date</param>
    /// <param name="Reason">The reason for termination</param>
    /// <param name="Refund">If true, a refund will be processed for the remaining period</param>
    /// <param name="RefundItemNo">The item number to use for the refund (required if Refund is true)</param>
    /// <param name="RefundPrice">The refund price to use (required if Refund is true, must be negative)</param>
    /// <returns>True if termination request was successful, false otherwise</returns>
    procedure RequestSubscriptionTermination(var Membership: Record "NPR MM Membership"; RequestedDate: Date; Reason: Enum "NPR MM Subs Termination Reason"; Refund: Boolean; RefundItemNo: Code[20]; RefundPrice: Decimal): Boolean
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        SubscrReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        Subscription: Record "NPR MM Subscription";
        TerminationRequest: Record "NPR MM Subscr. Request";
        RefundItemNoMissingErr: Label 'Refund item number is required when Refund is set to true.';
    begin
        // Validate refund parameters
        if Refund and (RefundItemNo = '') then
            Error(RefundItemNoMissingErr);

        // Request termination first
        if not SubscriptionMgtImpl.RequestTermination(Membership, RequestedDate, Reason, TerminationRequest) then
            exit(false);

        // If refund is requested, process the partial refund
        if Refund then begin
            // Get the subscription record
            if not SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription) then
                exit(false);

            SubscrReversalMgt.RequestPartialRefund(Subscription, Membership, RefundItemNo, RequestedDate, RefundPrice, TerminationRequest);
        end;

        exit(true);
    end;

    /// <summary>
    /// Calculates and returns the refund item details for a subscription
    /// </summary>
    /// <param name="Membership">The membership record</param>
    /// <param name="RequestedDate">The date from which the refund applies</param>
    /// <param name="RefundItemNo">Output: The suggested item number to use for the refund</param>
    /// <param name="RefundPrice">Output: The calculated refund price (negative value)</param>
    /// <returns>True if refund item was calculated successfully, false otherwise</returns>
    procedure CalculateTerminationRefundItem(Membership: Record "NPR MM Membership"; RequestedDate: Date; var RefundItemNo: Code[20]; var RefundPrice: Decimal): Boolean
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        StartDate, EndDate : Date;
        RefundAvailable: Boolean;
    begin
        // Find suggested refund item from alteration setup
        AlterationSetup.SetRange("Alteration Type", AlterationSetup."Alteration Type"::CANCEL);
        AlterationSetup.SetRange("From Membership Code", Membership."Membership Code");
        AlterationSetup.SetRange("Alteration Activate From", AlterationSetup."Alteration Activate From"::ASAP);

        if AlterationSetup.FindSet() then
            repeat
                RefundItemNo := AlterationSetup."Sales Item No.";

                // Initialize member info capture for cancellation
                TempMemberInfoCapture.Init();
                TempMemberInfoCapture."Membership Entry No." := Membership."Entry No.";
                TempMemberInfoCapture."Item No." := RefundItemNo;
                TempMemberInfoCapture."Information Context" := TempMemberInfoCapture."Information Context"::CANCEL;
                TempMemberInfoCapture."Document Date" := RequestedDate;

                // Try to calculate refund price with this item
                RefundAvailable := MembershipMgt.CancelMembership(TempMemberInfoCapture, false, false, StartDate, EndDate, RefundPrice);
            until (AlterationSetup.Next() = 0) or RefundAvailable;

        if not RefundAvailable then begin
            Clear(RefundItemNo);
            Clear(RefundPrice);
            exit(false);
        end;

        exit(true);
    end;
#endif
}