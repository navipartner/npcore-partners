codeunit 6060135 "NPR MM Member POS UI"
{
    procedure MemberSearchWithFacialRecognition(var MemberEntryNo: Integer) MemberFound: Boolean
    var
        MCSWebcamAPI: Codeunit "NPR MCS Webcam API";
        Member: Record "NPR MM Member";
        RecRef: RecordRef;
        FRec: FieldRef;
        MCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
        MCSWebcamArgumentTable: Record "NPR MCS Webcam Arg. Table";
    begin

        MemberEntryNo := 0;

        if not (MCSWebcamAPI.CallIdentifyStart(Member, MCSWebcamArgumentTable, false)) then
            exit(false);

        if not (MCSPersonBusinessEntities.Get(MCSWebcamArgumentTable."Person Id", DATABASE::"NPR MM Member")) then
            exit(false);

        RecRef.Get(MCSWebcamArgumentTable.Key);
        FRec := RecRef.Field(1);
        Member.Get(FRec.Value);
        MemberEntryNo := Member."Entry No.";

        exit(true);
    end;
}

