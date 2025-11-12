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
}