codeunit 6014581 "NPR Retail Report Select. Mgt."
{
    Access = Internal;

    var
        RegisterNo: Code[10];
        ReqWindow: Boolean;
        SystemPrinter: Boolean;
        MatrixPrintIterationFieldNo: Integer;

    procedure RunObjects(var RecRef: RecordRef; ReportType: Integer)
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        ReportSelectionRetail.SetRange("Report Type", ReportType);

        if RegisterNo <> '' then
            ReportSelectionRetail.SetRange("Register No.", RegisterNo);

        if ReportSelectionRetail.IsEmpty then
            ReportSelectionRetail.SetRange("Register No.", '');

        ReportSelectionRetail.SetRange(Optional, false);
        RunSelection(ReportSelectionRetail, RecRef);

        ReportSelectionRetail.SetRange(Optional, true);
        RunOptionalSelection(ReportSelectionRetail, RecRef);
    end;

    procedure SetRegisterNo(RegisterNoIn: Code[10])
    begin
        RegisterNo := RegisterNoIn;
    end;

    procedure SetRequestWindow(ReqWindowIn: Boolean)
    begin
        ReqWindow := ReqWindowIn;
    end;

    procedure SetUseSystemPrinter(SystemPrinterIn: Boolean)
    begin
        SystemPrinter := SystemPrinterIn;
    end;

    procedure SetMatrixPrintIterationFieldNo(FieldNo: Integer)
    begin
        MatrixPrintIterationFieldNo := FieldNo;
    end;

    local procedure RunOptionalSelection(var ReportSelection: Record "NPR Report Selection Retail"; var RecRefIn: RecordRef)
    var
        OptionString: Text;
        Itt: Integer;
        Option: Integer;
    begin
        if not GuiAllowed() then
            exit;
        ReportSelection.SetCurrentKey("Report Type", Sequence);
        ReportSelection.SetAutoCalcFields("Report Name", "Codeunit Name");
        if ReportSelection.FindSet() then
            repeat
                case true of
                    ReportSelection."Print Template" <> '':
                        OptionString += DelChr(ReportSelection."Print Template", '=', ',') + ',';
                    ReportSelection."Report Name" <> '':
                        OptionString += DelChr(ReportSelection."Report Name", '=', ',') + ',';
                    ReportSelection."Codeunit Name" <> '':
                        OptionString += DelChr(ReportSelection."Codeunit Name", '=', ',') + ',';
                end;
            until ReportSelection.Next() = 0;

        if OptionString = '' then
            exit;

        Option := StrMenu(OptionString);

        if Option > 0 then begin
            ReportSelection.FindSet();
            Itt := 1;
            repeat
                if Itt = Option then begin
                    ReportSelection.SetRecFilter();
                    RunSelection(ReportSelection, RecRefIn);
                end;
                Itt += 1;
            until ReportSelection.Next() = 0;
        end;
    end;

    local procedure RunSelection(var ReportSelection: Record "NPR Report Selection Retail"; var RecRefIn: RecordRef)
    var
        Variant: Variant;
        RecRef: RecordRef;
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        POSEntryOutputLogMgt: Codeunit "NPR POS Entry Output Log Mgt.";
        LogHandled: Boolean;
    begin
        if ReportSelection.FindSet() then begin
            OnBeforeRunReportSelectionType(ReportSelection, RecRefIn);
            Commit();

            repeat
                if RecRefIn.IsTemporary() then begin
                    RecRef.Open(RecRefIn.Number, true);
                    RecRef.Copy(RecRefIn, true);
                end else begin
                    RecRef := RecRefIn.Duplicate();
                end;

                if not RecRef.IsEmpty() then begin
                    Variant := RecRef;
                    case true of
                        StrLen(ReportSelection."Print Template") > 0:
                            TemplateMgt.PrintTemplate(ReportSelection."Print Template", RecRef, MatrixPrintIterationFieldNo);

                        ReportSelection."Report ID" > 0:
                            Report.Run(ReportSelection."Report ID", ReqWindow, SystemPrinter, Variant);

                        ReportSelection."Codeunit ID" > 0:
                            Codeunit.Run(ReportSelection."Codeunit ID", Variant);
                    end;

                    OnAfterRunReportSelectionRecord(ReportSelection, RecRefIn);
                end;

                RecRef.Close();
            until ReportSelection.Next() = 0;

            OnBeforeLogOutput(ReportSelection, RecRefIn, LogHandled);
            if not LogHandled then
                POSEntryOutputLogMgt.LogOutput(RecRefIn, ReportSelection);
            Commit();

            OnAfterRunReportSelectionType(ReportSelection, RecRefIn);
        end
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunReportSelectionRecord(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunReportSelectionType(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunReportSelectionType(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLogOutput(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef; var Handled: Boolean)
    begin
    end;
}