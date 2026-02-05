codeunit 6060001 "NPR HL Upsert Member Batch"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    TableNo = "NPR HL HeyLoyalty Member";

    trigger OnRun()
    var
        HLMember: Record "NPR HL HeyLoyalty Member";
        HLMember2: Record "NPR HL HeyLoyalty Member";
        UpsertMember: Codeunit "NPR HL Upsert Member";
    begin
        UpsertMember.CheckIntegrationIsEnabled();
        HLMember.Copy(Rec);
        if HLMember.FindSet() then
            repeat
                HLMember2 := HLMember;
                UpsertOne(HLMember2);
            until HLMember.Next() = 0;
    end;

    procedure UpsertOne(var HLMember: Record "NPR HL HeyLoyalty Member")
    var
        Success: Boolean;
    begin
        ClearLastError();
        Success := Codeunit.Run(Codeunit::"NPR HL Upsert Member", HLMember);
        if HLMember.Find() then begin
            HLMember."Update from HL Error" := not Success;
            if HLMember."Update from HL Error" then
                HLMember.SetErrorMessage(GetLastErrorText());
            HLMember.Modify();
            Commit();
        end;
    end;
}