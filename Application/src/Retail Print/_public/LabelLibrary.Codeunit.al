codeunit 6014413 "NPR Label Library"
{
    procedure ResolveVariantAndPrintItem(var Item: Record Item; ReportType: Integer): Decimal
    var
        LabelManagement: Codeunit "NPR Label Management";
    begin
        exit(LabelManagement.ResolveVariantAndPrintItem(Item, ReportType));
    end;

    procedure PrintLabel(VarRec: Variant; ReportType: Option)
    var
        LabelManagement: Codeunit "NPR Label Management";
    begin
        LabelManagement.PrintLabel(VarRec, ReportType);
    end;

    procedure FlushJournalToPrinter(RetailJournalCode: Code[40]; ReportType: Integer)
    var
        LabelManagement: Codeunit "NPR Label Management";
    begin
        LabelManagement.FlushJournalToPrinter(RetailJournalCode, ReportType);
    end;

    procedure ChooseLabel(VarRec: Variant)
    var
        LabelManagement: Codeunit "NPR Label Management";
    begin
        LabelManagement.ChooseLabel(VarRec);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnApplyFilter(var FilteredLineRecRef: RecordRef; Rec: Variant; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforePrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer; var Skip: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterPrintRetailJournal(var JournalLine: Record "NPR Retail Journal Line"; ReportType: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunPrintPage(var RecRef: RecordRef; RetailJournalMgt: Codeunit "NPR Retail Journal Code"; RetailJnlCode: Code[40]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnPrintSelection(var SelectionBuffer: RecordRef; ReportType: Integer)
    begin
    end;
}
