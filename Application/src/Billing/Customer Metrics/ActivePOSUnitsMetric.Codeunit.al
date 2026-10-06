codeunit 6151258 "NPR Active POS Units Metric" implements "NPR ICustomer Metric"
{
    Access = Internal;

    procedure GetEventType(): Enum "NPR Billing Event Type"
    begin
        exit(Enum::"NPR Billing Event Type"::POS_ACTIVE_UNITS_7D_COUNT);
    end;

    procedure Calculate(BusinessDate: Date; var Metadata: JsonObject): Decimal
    var
        POSUnit: Record "NPR POS Unit";
        ActivePOSUnits: Integer;
    begin
        POSUnit.SetLoadFields("No.");
        if POSUnit.FindSet() then
            repeat
                if HasSaleInPeriod(POSUnit."No.", BusinessDate - 6, BusinessDate) then
                    ActivePOSUnits += 1;
            until POSUnit.Next() = 0;
        exit(ActivePOSUnits);
    end;

    local procedure HasSaleInPeriod(POSUnitNo: Code[10]; PeriodFrom: Date; PeriodTo: Date): Boolean
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetCurrentKey("POS Unit No.", "Entry Date");
        POSEntry.SetRange("POS Unit No.", POSUnitNo);
        POSEntry.SetRange("Entry Date", PeriodFrom, PeriodTo);
        POSEntry.SetRange("System Entry", false);
        POSEntry.SetFilter("Entry Type", '%1|%2', POSEntry."Entry Type"::"Direct Sale", POSEntry."Entry Type"::"Credit Sale");
        exit(not POSEntry.IsEmpty());
    end;
}
