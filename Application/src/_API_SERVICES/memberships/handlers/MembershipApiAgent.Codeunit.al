#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22   
codeunit 6185123 "NPR MembershipApiAgent"
{
    Access = Internal;

    internal procedure GetMembershipByNumber(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipNo: Code[20];
    begin

        if (not Request.QueryParams().ContainsKey('membershipNumber')) then
            exit(Response.RespondBadRequest('Membership number is required.'));

        MembershipNo := CopyStr(UpperCase(Request.QueryParams().Get('membershipNumber')), 1, MaxStrLen(MembershipNo));

        exit(GetMembershipByNumber(MembershipNo));
    end;

    // ************
    internal procedure GetMembershipByNumber(MembershipNumber: Code[20]) Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        Membership.SetCurrentKey("External Membership No.");
        Membership.SetFilter("External Membership No.", '=%1', MembershipNumber);
        if (not Membership.FindFirst()) then
            exit(Response.RespondResourceNotFound('Membership not found.'));

        ResponseJson.StartObject()
            .AddObject(MembershipDTO(ResponseJson, Membership))
        .EndObject();

        exit(Response.RespondOK(ResponseJson.Build()));
    end;

    internal procedure GetMembershipRenewalInfo(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";
        ResponseJson: Codeunit "NPR JSON Builder";
        MembershipID: Text;
        SubscriptionRequestFound: Boolean;
    begin
        MembershipID := Request.Paths().Get(2);
        if MembershipID = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: membershipId'));

        Membership.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Membership.GetBySystemId(MembershipID) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Membership %1', MembershipID)));

        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        if not Subscription.FindFirst() then begin
            Subscription.Init();
            Subscription."Membership Code" := Membership."Membership Code";
            Subscription."Membership Entry No." := Membership."Entry No.";
            MembershipMgt.GetConsecutiveTimeFrame(Membership."Entry No.", Today(), Subscription."Valid From Date", Subscription."Valid Until Date");
        end;

        if Subscription."Entry No." <> 0 then begin
            SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
            SubscriptionRequest.SetFilter("Processing Status", '%1|%2', SubscriptionRequest."Processing Status"::Pending, SubscriptionRequest."Processing Status"::Error);
            SubscriptionRequest.SetFilter(Status, '<>%1', SubscriptionRequest.Status::Cancelled);
            SubscriptionRequestFound := SubscriptionRequest.FindLast();
        end else
            SubscriptionRequestFound := false;

        if not SubscriptionRequestFound then begin
            if Subscription."Membership Ledger Entry No." = 0 then begin
                MembershipEntry.SetCurrentKey("Entry No.");
                MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
                MembershipEntry.SetRange(Blocked, false);
                MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
                MembershipEntry.SetLoadFields("Entry No.");
                if not MembershipEntry.FindLast() then
                    exit(Response.RespondResourceNotFound(StrSubstNo('The time entries for the membership %1 on which the calculation can be based were', MembershipID)));
                Subscription."Membership Ledger Entry No." := MembershipEntry."Entry No.";
            end;
            RequestSubscrRenewal.CalculateSubscriptionRenewal(Subscription, SubscriptionRequest);
        end;

        ResponseJson.StartObject()
            .StartObject('membership')
                .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
                .AddProperty('membershipNumber', Membership."External Membership No.")
                .AddProperty('expiryDate', Subscription."Valid Until Date")
                .AddProperty('newValidFromDate', SubscriptionRequest."New Valid From Date")
                .AddProperty('newValidUntilDate', SubscriptionRequest."New Valid Until Date")
                .AddProperty('amountInclVat', SubscriptionRequest.Amount)
            .EndObject()
        .EndObject();

        exit(Response.RespondOK(ResponseJson));
    end;

    local procedure MembershipDTO(ResponseJson: Codeunit "NPR JSON Builder"; Membership: Record "NPR MM Membership"): Codeunit "NPR JSON Builder"
    var
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        ValidFrom, ValidUntil : Date;
    begin

        MembershipMgt.GetConsecutiveTimeFrame(Membership."Entry No.", Today(), ValidFrom, ValidUntil);

        ResponseJson.StartObject('membership')
            .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
            .AddProperty('membershipNumber', Membership."External Membership No.")
            .AddProperty('communityCode', Membership."Community Code")
            .AddProperty('membershipCode', Membership."Membership Code")
            .AddProperty('issueDate', Membership."Issued Date")
            .AddProperty('blocked', Membership.Blocked)
            .AddProperty('validFromDate', ValidFrom)
            .AddProperty('validUntilDate', ValidUntil)
            .AddProperty('customerNumber', Membership."Customer No.")
        .EndObject();

        exit(ResponseJson);
    end;
}
#endif