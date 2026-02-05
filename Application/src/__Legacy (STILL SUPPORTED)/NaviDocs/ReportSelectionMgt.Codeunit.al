codeunit 6059867 "NPR ReportSelectionMgt"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnFindReportSelections', '', false, false)]
    local procedure OnFindReportSelections(var FilterReportSelections: Record "Report Selections"; var IsHandled: Boolean; var ReturnReportSelections: Record "Report Selections"; AccountNo: Code[20]; TableNo: Integer)
    begin
        FilterReportSelectionsRespCenter(RespCenter, ReturnReportSelections);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeSetReportLayout', '', false, false)]
    local procedure OnBeforeSetReportLayout(RecordVariant: Variant; ReportUsage: Integer)
    var
        RecordReference: RecordRef;
        ReportUsageEnum: Enum "Report Selection Usage";
    begin
        if (ReportUsage in [ReportUsageEnum::"S.Quote".AsInteger(), ReportUsageEnum::"S.Order".AsInteger(), ReportUsageEnum::"S.Invoice".AsInteger(), ReportUsageEnum::"S.Cr.Memo".AsInteger()]) then begin
            RecordReference.GetTable(RecordVariant);
            RespCenter := GetRespCenter(RecordReference);
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsert(var Rec: Record "Report Selections"; RunTrigger: Boolean)
    begin
        FormatSequence(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRename(var Rec: Record "Report Selections"; RunTrigger: Boolean)
    begin
        FormatSequence(Rec);
    end;

    local procedure FormatSequence(var Rec: Record "Report Selections")
    begin
        if not Rec.IsTemporary() then
            exit;
        if StrLen(Rec.Sequence) < 3 then
            Rec.Sequence := CopyStr(Format(Rec.Sequence).PadLeft(3, '0'), 1, MaxStrLen(Rec.Sequence));
    end;

    local procedure FilterReportSelectionsRespCenter(ResponsibilityCenter: Code[20]; var ReportSelections: Record "Report Selections")
    begin
        ReportSelections.FilterGroup(81);
        ReportSelections.SetRange("NPR Responsibility Center");
        if (ResponsibilityCenter <> '') then begin
            ReportSelections.SetRange("NPR Responsibility Center", ResponsibilityCenter);
            if (ReportSelections.Count = 0) then
                ReportSelections.SetFilter("NPR Responsibility Center", '=%1', '');
        end else
            ReportSelections.SetFilter("NPR Responsibility Center", '=%1', '');
        ReportSelections.FilterGroup(0);
    end;

    local procedure GetRespCenter(RecordReference: RecordRef): Code[20]
    var
        FieldRec: Record Field;
        FieldReference: FieldRef;
    begin
        FieldRec.SetRange(TableNo, RecordReference.Number);
        FieldRec.SetRange(FieldName, 'Responsibility Center');
        if (FieldRec.FindFirst()) then begin
            FieldReference := RecordReference.Field(FieldRec."No.");
            exit(Format(FieldReference.Value));
        end;
    end;

    var
        RespCenter: Code[20];
}