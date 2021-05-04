codeunit 6014634 "NPR POS Entry Tax Calc."
{

    procedure DeleteAllLines(EntryNo: Integer)
    var
        POSEntryTaxLine: record "NPR POS Entry Tax Line";
    begin
        FilterLines(EntryNo, POSEntryTaxLine);
        if not POSEntryTaxLine.IsEmpty() then
            POSEntryTaxLine.DeleteAll(true);
    end;

    procedure FilterLines(EntryNo: Integer; var POSEntryTaxLine: record "NPR POS Entry Tax Line")
    begin
        POSEntryTaxLine.Reset();
        POSEntryTaxLine.SetRange("POS Entry No.", EntryNo);
    end;

    procedure PostPOSTaxAmountCalculation(EntryNo: Integer; SystemId: Guid)
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        ITaxCalc: Interface "NPR POS ITaxCalc";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
    begin
        if not POSSaleTaxCalc.Find(POSSaleTax, SystemId) then
            exit;

        POSSaleTax.GetHandler(ITaxCalc);
        ITaxCalc.PostPOSTaxAmountCalculation(EntryNo, SystemId, POSSaleTax);
    end;
}