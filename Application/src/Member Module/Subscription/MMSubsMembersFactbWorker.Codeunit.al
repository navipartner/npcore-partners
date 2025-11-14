codeunit 6150805 "NPR MM SubsMembersFactbWorker"
{
    Access = Internal;
    trigger OnRun()
    begin
        FindMembers();
    end;

    local procedure FindMembers()
    var
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        Parameters: Dictionary of [Text, Text];
        Result: Dictionary of [Text, Text];
        MemberPaymentMethodId: Guid;
    begin
        Parameters := Page.GetBackgroundParameters();
        if not Evaluate(MemberPaymentMethodId, Parameters.Get('systemId')) then
            exit;
        MembershipPmtMethodMap.SetLoadFields(MembershipId);
        Membership.SetLoadFields("Entry No.");
        Membership.SetRange(Blocked, false);
        MembershipRole.SetLoadFields("Membership Entry No.", "Member Entry No.");
        MembershipRole.SetRange(Blocked, false);
        Member.SetLoadFields("Display Name");
        MembershipPmtMethodMap.SetRange(PaymentMethodId, MemberPaymentMethodId);
        MembershipPmtMethodMap.SetRange(Default, true);
        MembershipPmtMethodMap.SetRange(Status, "NPR MM Payment Method Status"::Active);
        if MembershipPmtMethodMap.FindSet() then
            repeat
                if Membership.GetBySystemId(MembershipPmtMethodMap.MembershipId) then begin
                    MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
                    if MembershipRole.FindSet() then
                        repeat
                            if Member.Get(MembershipRole."Member Entry No.") then
                                if not Result.ContainsKey(Format(Member."Entry No.")) then
                                    Result.Add(Format(Member."Entry No."), Member."Display Name");
                        until MembershipRole.Next() = 0;
                end;
            until MembershipPmtMethodMap.Next() = 0;
        Page.SetBackgroundTaskResult(Result);
    end;

}
