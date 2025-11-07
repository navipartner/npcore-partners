codeunit 6248655 "NPR MemberMergeHandler"
{

    Access = Public;

    internal procedure CompactMembersOnUniqueIdChange(MemberToKeep: Record "NPR MM Member"; var ConflictExists: Boolean; var ConflictingMembersMerged: Boolean; var ReasonText: Text): Boolean
    var
        Community: Record "NPR MM Member Community";
        MultipleCommunities: Label 'The member exist in multiple communities that employ different unique ID rules for the members. Merging members based on unique ID is not possible.';
        MembershipMgmt: Codeunit "NPR MM MembershipMgtInternal";
        Merge: Boolean;
    begin
        if (not (MembershipMgmt.CheckGetCommunityUniqueIdRules(MemberToKeep."Entry No.", Community))) then begin
            ReasonText := MultipleCommunities;
            exit(false);
        end;

        UpdateExplanation(Community, MemberToKeep, ConflictExists, Merge, ReasonText);

        ConflictingMembersMerged := (ConflictExists and Merge);

        if (ConflictExists and not Merge) then
            exit(false);

        if (not ConflictExists) then
            MembershipMgmt.UpdateMemberUniqueId(MemberToKeep, MemberToKeep."First Name", MemberToKeep."E-Mail Address", MemberToKeep."Phone No.", MemberToKeep."External Member No.");

        if (ConflictExists and Merge) then
            MembershipMgmt.MergeMemberUniqueId(MemberToKeep, MemberToKeep."First Name", MemberToKeep."E-Mail Address", MemberToKeep."Phone No.", MemberToKeep."External Member No.");

        exit(true);
    end;

    internal procedure UpdateExplanation(Community: Record "NPR MM Member Community"; MemberToKeep: Record "NPR MM Member"; var ConflictExists: Boolean; var Merge: Boolean; var Explanation: Text)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipMgmt: Codeunit "NPR MM MembershipMgtInternal";
        ConflictsWithMember: Record "NPR MM Member";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        ErrorMsg: Label 'A member with the same unique ID already exists. Rules do not allow duplicate unique IDs.';
        AcceptDuplicateMsg: Label 'A member with the same unique ID already exists. The unique ID will be accepted on both members.';
        MergeMsg: Label 'Current member %1 will be updated with new unique id and replace the other member with the same unique id in all membership relationships.';
    begin
        Merge := false;
        Explanation := 'No conflict found.';

        MemberInfoCapture."First Name" := MemberToKeep."First Name";
        MemberInfoCapture."E-Mail Address" := MemberToKeep."E-Mail Address";
        MemberInfoCapture."Phone No." := MemberToKeep."Phone No.";
        MemberInfoCapture."Member Entry No" := MemberToKeep."Entry No.";

        MembershipMgmt.SetMemberUniqueIdFilter(Community, MemberInfoCapture, ConflictsWithMember);
        ConflictExists := ConflictsWithMember.FindFirst();
        MembershipEvents.OnCheckMemberUniqueIdViolation(Community, MemberInfoCapture, ConflictsWithMember, ConflictExists);

        if (ConflictExists) then begin
            if (Community."Create Member UI Violation" = Community."Create Member UI Violation"::ERROR) then
                Explanation := ErrorMsg;

            if (Community."Create Member UI Violation" = Community."Create Member UI Violation"::CONFIRM) then
                Explanation := ErrorMsg;

            if (Community."Create Member UI Violation" = Community."Create Member UI Violation"::REUSE) then begin
                Explanation := AcceptDuplicateMsg;
                ConflictExists := false;
            end;

            if (Community."Create Member UI Violation" = Community."Create Member UI Violation"::MERGE_MEMBER) then begin
                Merge := true;
                Explanation := StrSubstNo(MergeMsg, MemberToKeep."External Member No.");
            end;
        end;
    end;
}