codeunit 6060135 "NPR MM Member POS UI"
{
    Access = Internal;
    procedure MemberSearchWithFacialRecognition(var MemberEntryNo: Integer) MemberFound: Boolean
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        Member: Record "NPR MM Member";
        RecRef: RecordRef;
        MCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
        PersonId: text[50];
        EntryNo: Integer;
    begin
        MemberEntryNo := 0;
        PersonId := MembershipManagement.FindPersonByFacialRecognition(Database::"NPR MM Member");

        if not (MCSPersonBusinessEntities.Get(PersonId, DATABASE::"NPR MM Member")) then
            exit(false);

        RecRef.Get(MCSPersonBusinessEntities.Key);
        Evaluate(EntryNo, Format(RecRef.Field(1).Value));
        Member.Get(EntryNo);
        MemberEntryNo := Member."Entry No.";

        exit(true);
    end;
}

