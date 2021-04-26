codeunit 6060135 "NPR MM Member POS UI"
{
    procedure MemberSearchWithFacialRecognition(var MemberEntryNo: Integer) MemberFound: Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        Member: Record "NPR MM Member";
        RecRef: RecordRef;
        FRec: FieldRef;
        MCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
        PersonId: text[50];
    begin
        MemberEntryNo := 0;
        PersonId := MembershipManagement.FindPersonByFacialRecognition(Database::"NPR MM Member");

        if not (MCSPersonBusinessEntities.Get(PersonId, DATABASE::"NPR MM Member")) then
            exit(false);

        RecRef.Get(MCSPersonBusinessEntities.Key);
        FRec := RecRef.Field(1);
        Member.Get(FRec.Value);
        MemberEntryNo := Member."Entry No.";

        exit(true);
    end;
}

