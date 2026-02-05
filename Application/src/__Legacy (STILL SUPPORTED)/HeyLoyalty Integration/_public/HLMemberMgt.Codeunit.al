codeunit 6151399 "NPR HL Member Mgt."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Public;

    procedure FindMembershipRole(var FilteredMembershipRoles: Record "NPR MM Membership Role"; var MembershipRoleOut: Record "NPR MM Membership Role"): Boolean
    var
        MemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
    begin
        exit(MemberMgt.FindMembershipRole(FilteredMembershipRoles, MembershipRoleOut));
    end;

    procedure TouchMember(MembershipRole: Record "NPR MM Membership Role"; var TempMembershipRole: Record "NPR MM Membership Role")
    var
        MemberMgt: Codeunit "NPR HL Member Mgt. Impl.";
    begin
        MemberMgt.TouchMember(MembershipRole, TempMembershipRole);
    end;
}