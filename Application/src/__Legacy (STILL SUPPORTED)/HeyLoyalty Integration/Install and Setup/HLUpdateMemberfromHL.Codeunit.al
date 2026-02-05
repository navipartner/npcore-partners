codeunit 6248355 "NPR HL Update Member from HL"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    TableNo = "NPR HL HeyLoyalty Member";

    trigger OnRun()
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        HLSendMembers: Codeunit "NPR HL Send Members";
        HLMemberMgtImpl: Codeunit "NPR HL Member Mgt. Impl.";
        HLWSMgt: Codeunit "NPR HL Member Webhook Handler";
    begin
        //Update from HeyLoyalty
        if Rec."HeyLoyalty Id" = '' then
            Rec."HeyLoyalty Id" := HLSendMembers.GetHeyLoyaltyMemberID(Rec, false);
        HLWSMgt.UpsertMember(Rec."HeyLoyalty Id");
        Commit();

        //Update to HeyLoyalty
        Rec.Find();
        if Member.Get(Rec."Member Entry No.") then begin
            if not HLMemberMgtImpl.FindMembershipRole(Member, MembershipRole) then
                Clear(MembershipRole);
            if HLMemberMgtImpl.ProcessMember(Member, MembershipRole, false, false) then
                Commit();
        end;
    end;

    internal procedure UpdateMembersFromHL(var HLMember: Record "NPR HL HeyLoyalty Member")
    var
#if not (BC17 or BC18 or BC19)
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorMessageMgt: Codeunit "Error Message Management";
#endif
        Window: Dialog;
        RecNo: Integer;
        TotalRecNo: Integer;
#if not (BC17 or BC18 or BC19)
        CounterProcessed: Integer;
        BatchProcessingTxt: Label 'Resyncing members from HeyLoyalty.';
#endif
        DialogTxt01Lbl: Label 'Fetching HeyLoyalty data...\\';
        DialogTxt02Lbl: Label '@1@@@@@@@@@@@@@@@@@@@@@@@@@';
        NoRecordsToProcessErr: Label 'No records to process.';
    begin
        if HLMember.IsEmpty() then
            Error(NoRecordsToProcessErr);
#if not (BC17 or BC18 or BC19)
        if ErrorMessageMgt.Activate(ErrorMessageHandler) then
            ErrorMessageMgt.PushContext(ErrorContextElement, Database::"NPR HL HeyLoyalty Member", 0, BatchProcessingTxt);
#endif
        Window.Open(
            DialogTxt01Lbl +
            DialogTxt02Lbl);
        RecNo := 0;
        TotalRecNo := HLMember.Count();

        HLMember.FindSet();
        repeat
            RecNo += 1;
            Window.Update(1, Round(RecNo / TotalRecNo * 10000, 1));
#if (BC17 or BC18 or BC19)
            UpdateOneMemberFromHL(HLMember);
#else
            if UpdateOneMemberFromHL(HLMember) then
                CounterProcessed += 1;
#endif
        until HLMember.Next() = 0;

#if not (BC17 or BC18 or BC19)
        if CounterProcessed <> TotalRecNo then begin
            ErrorMessageHandler.InformAboutErrors(Enum::"Error Handling Options"::"Show Notification");
            ErrorMessageMgt.PopContext(ErrorContextElement);
        end;
#endif
    end;

    local procedure UpdateOneMemberFromHL(HLMember: Record "NPR HL HeyLoyalty Member") Success: Boolean
    var
#if not (BC17 or BC18 or BC19)
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessage: Text;
        DefaultErrorMsg: Label 'An error occurred. No further information has been provided.';
        ProcessingMsg: Label 'Processing HeyLoyalty Member %1.', Comment = '%1 - HeyLoyalty member number';
#endif
    begin
#if not (BC17 or BC18 or BC19)
        ErrorMessageMgt.PushContext(ErrorContextElement, HLMember.RecordId(), 0, StrSubstNo(ProcessingMsg, HLMember."Entry No."));
#endif
        Success := Codeunit.Run(Codeunit::"NPR HL Update Member from HL", HLMember);
#if not (BC17 or BC18 or BC19)
        if not Success then begin
            ErrorMessage := GetLastErrorText();
            if ErrorMessage = '' then
                ErrorMessage := DefaultErrorMsg;
            ErrorMessageMgt.LogError(HLMember, ErrorMessage, '');
            ErrorMessageMgt.PopContext(ErrorContextElement);
        end;
#endif
        ClearLastError();
    end;
}