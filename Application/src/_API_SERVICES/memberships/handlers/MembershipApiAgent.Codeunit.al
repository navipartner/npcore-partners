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