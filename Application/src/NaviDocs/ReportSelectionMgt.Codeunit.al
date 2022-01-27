codeunit 6059867 "NPR ReportSelectionMgt"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Report Selections", 'OnPrintDocumentsOnAfterSelectTempReportSelectionsToPrint', '', true, true)]

    local procedure OnPrintDocumentsOnAfterSelectTempReportSelectionsToPrint(RecordVariant: Variant; var TempReportSelections: Record "Report Selections" temporary; var TempNameValueBuffer: Record "Name/Value Buffer" temporary; WithCheck: Boolean; ReportUsage: Integer; TableNo: Integer)
    var
        FieldRec: Record Field;
        RecordReference: RecordRef;
        FieldReference: FieldRef;
        ReportUsageEnum: Enum "Report Selection Usage";
    begin
        if (ReportUsage in [ReportUsageEnum::"S.Quote".AsInteger(), ReportUsageEnum::"S.Order".AsInteger(), ReportUsageEnum::"S.Invoice".AsInteger(), ReportUsageEnum::"S.Cr.Memo".AsInteger()]) then begin

            RecordReference.GetTable(RecordVariant);
            FieldRec.setrange(TableNo, RecordReference.Number);
            FieldRec.SetRange(FieldName, 'Responsibility Center');
            if (FieldRec.FindFirst()) then begin
                FieldReference := RecordReference.Field(FieldRec."No.");
                if (Format(FieldReference.Value) <> '') then begin
                    TempReportSelections.SetRange("NPR Responsibility Center", FieldReference.Value);
                    if (TempReportSelections.Count = 0) then
                        TempReportSelections.SetFilter("NPR Responsibility Center", '=%1', '');
                end else
                    TempReportSelections.SetFilter("NPR Responsibility Center", '=%1', '');
            end;
        end;
    end;
}
