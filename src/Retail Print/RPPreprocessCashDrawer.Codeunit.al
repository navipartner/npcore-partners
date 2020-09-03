codeunit 6014535 "NPR RP Preprocess: Cash Drawer"
{
    // NPR5.40/MMV /20180326 CASE 300660 Deprecated object functionality. Not deleted yet as templates are expecting a call to this codeunit to not fail.

    TableNo = "NPR Audit Roll";

    trigger OnRun()
    begin
        //-NPR5.40 [300660]
        // PaymentTypePOS.SETCURRENTKEY("Processing Type");
        // PaymentTypePOS.SETFILTER("Processing Type", '%1|%2', PaymentTypePOS."Processing Type"::Cash, PaymentTypePOS."Processing Type"::"Foreign Currency");
        // IF NOT PaymentTypePOS.FINDSET THEN
        //  EXIT;
        //
        // REPEAT
        //  IF STRLEN(FilterString) <> 0 THEN
        //    FilterString += '|';
        //  FilterString += PaymentTypePOS."No.";
        // UNTIL PaymentTypePOS.NEXT = 0;
        //
        // AuditRoll.SETRANGE("Register No.", Rec."Register No.");
        // AuditRoll.SETRANGE("Sales Ticket No.", Rec."Sales Ticket No.");
        // AuditRoll.SETRANGE("Sale Type",AuditRoll."Sale Type"::Payment);
        // AuditRoll.SETRANGE(Type, AuditRoll.Type::Payment);
        // AuditRoll.SETFILTER("No.", FilterString);
        // IF AuditRoll.ISEMPTY THEN
        //  EXIT;
        //
        // LinePrintMgt.ProcessCodeunit(CODEUNIT::"Report - Open drawer IV", 0);
        //+NPR5.40 [300660]
    end;
}

