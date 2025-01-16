#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248228 "NPR MembershipMiscApiAgent"
{
    Access = Internal;

    internal procedure resolveIdentifier(Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        IdentifierText: Text[100];
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        Card: Record "NPR MM Member Card";
    begin

        if (not Request.QueryParams().ContainsKey('identifier')) then
            exit(Response.RespondBadRequest('Identifier parameter resolve is missing'));

        IdentifierText := CopyStr(Request.QueryParams().Get('identifier'), 1, MaxStrLen(IdentifierText));
        if (IdentifierText = '') then
            exit(Response.RespondBadRequest('Identifier to resolve is blank'));

        if (CheckMembershipNumber(IdentifierText, Membership)) then
            exit(Response.RespondOk(StartMembershipDTO(Membership).Build()));

        if (CheckMemberNumber(IdentifierText, Member)) then
            exit(Response.RespondOk(StartMemberDTO(Member).Build()));

        if (CheckCardNumber(IdentifierText, Card)) then
            exit(Response.RespondOk(StartCardDTO(Card).Build()));

        exit(Response.RespondResourceNotFound('Identifier not found'));
    end;

    local procedure CheckMembershipNumber(MembershipNumber: Text[100]; var Membership: Record "NPR MM Membership"): Boolean
    begin
        Membership.Reset();
        Membership.SetCurrentKey("External Membership No.");
        Membership.SetFilter("External Membership No.", '=%1', CopyStr(MembershipNumber, 1, MaxStrLen(Membership."External Membership No.")));
        exit(Membership.FindFirst());
    end;

    local procedure StartMembershipDTO(Membership: Record "NPR MM Membership") ResponseJson: Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartObject()
            .AddProperty('type', 'membership')
            .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
            .EndObject();

        exit(ResponseJson);
    end;

    local procedure CheckMemberNumber(MemberNumber: Text[100]; var Member: Record "NPR MM Member"): Boolean
    begin
        Member.Reset();
        Member.SetCurrentKey("External Member No.");
        Member.SetFilter("External Member No.", '=%1', CopyStr(MemberNumber, 1, MaxStrLen(Member."External Member No.")));
        exit(Member.FindFirst());
    end;

    local procedure StartMemberDTO(Member: Record "NPR MM Member") ResponseJson: Codeunit "NPR Json Builder"
    begin
        ResponseJson.StartObject()
            .AddProperty('type', 'member')
            .AddProperty('memberId', Format(Member.SystemId, 0, 4).ToLower())
            .EndObject();

        exit(ResponseJson);
    end;

    local procedure CheckCardNumber(CardNumber: Text[100]; var Card: Record "NPR MM Member Card"): Boolean
    begin
        Card.Reset();
        Card.SetCurrentKey("External Card No.");
        Card.SetFilter("External Card No.", '=%1', CopyStr(CardNumber, 1, MaxStrLen(Card."External Card No.")));
        exit(Card.FindFirst());
    end;

    local procedure StartCardDTO(Card: Record "NPR MM Member Card") ResponseJson: Codeunit "NPR Json Builder"
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
    begin
        if (not Membership.Get(Card."Membership Entry No.")) then
            Membership.Init();

        if (not Member.Get(Card."Member Entry No.")) then
            Member.Init();

        ResponseJson.StartObject()
            .AddProperty('type', 'card')
            .AddProperty('cardId', Format(Card.SystemId, 0, 4).ToLower())
            .AddProperty('membershipId', Format(Membership.SystemId, 0, 4).ToLower())
            .AddProperty('memberId', Format(Member.SystemId, 0, 4).ToLower())
            .EndObject();

        exit(ResponseJson);
    end;
}
#endif