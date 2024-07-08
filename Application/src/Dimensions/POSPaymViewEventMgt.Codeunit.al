codeunit 6151053 "NPR POS Paym. View Event Mgt."
{
    Access = Internal;

    internal procedure DimensionIsRequired(SalePOS: Record "NPR POS Sale"; var POSPaymentViewEventSetup: Record "NPR POS Paym. View Event Setup"): Boolean
    var
        POSPaymentViewLogEntry: Record "NPR POS Paym. View Log Entry";
        POSSalesNo: Integer;
    begin
        if SkipPopup(SalePOS, POSPaymentViewEventSetup) then
            exit(false);

        POSPaymentViewLogEntry.SetCurrentKey("POS Unit", "Sales Ticket No.");
        POSPaymentViewLogEntry.SetRange("POS Unit", SalePOS."Register No.");
        POSPaymentViewLogEntry.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        POSPaymentViewLogEntry.SetLoadFields("Post Code Popup");
        if not POSPaymentViewLogEntry.FindFirst() then begin
            POSPaymentViewLogEntry.Reset();
            POSPaymentViewLogEntry.LockTable(true);
            case POSPaymentViewEventSetup."Popup per" of
                POSPaymentViewEventSetup."Popup per"::"POS Store":
                    begin
                        POSPaymentViewLogEntry.SetCurrentKey("POS Store", "POS Sales No.");
                        POSPaymentViewLogEntry.SetRange("POS Store", SalePOS."POS Store Code");
                    end;
                POSPaymentViewEventSetup."Popup per"::"POS Unit":
                    begin
                        POSPaymentViewLogEntry.SetCurrentKey("POS Unit", "POS Sales No.");
                        POSPaymentViewLogEntry.SetRange("POS Unit", SalePOS."Register No.");
                    end;
                else
                    POSPaymentViewLogEntry.SetCurrentKey("POS Sales No.");
            end;
            POSPaymentViewLogEntry.SetLoadFields("POS Sales No.");
            if not POSPaymentViewLogEntry.FindLast() then
                POSPaymentViewLogEntry."POS Sales No." := 0;
            POSSalesNo := POSPaymentViewLogEntry."POS Sales No." + 1;

            POSPaymentViewLogEntry.SetLoadFields();
            POSPaymentViewLogEntry.Init();
            POSPaymentViewLogEntry."Entry No." := 0;
            POSPaymentViewLogEntry."POS Store" := SalePOS."POS Store Code";
            POSPaymentViewLogEntry."POS Unit" := SalePOS."Register No.";
            POSPaymentViewLogEntry."Sales Ticket No." := SalePOS."Sales Ticket No.";
            POSPaymentViewLogEntry."POS Sales No." := POSSalesNo;
            if POSPaymentViewEventSetup."Popup every" > 0 then
                POSPaymentViewLogEntry."Post Code Popup" := (POSPaymentViewLogEntry."POS Sales No." mod POSPaymentViewEventSetup."Popup every" = 0);
            POSPaymentViewLogEntry."Log Date" := CurrentDateTime();
            POSPaymentViewLogEntry.Insert();
        end;

        exit(POSPaymentViewLogEntry."Post Code Popup");
    end;

    local procedure SkipPopup(SalePOS: Record "NPR POS Sale"; var POSPaymentViewEventSetup: Record "NPR POS Paym. View Event Setup"): Boolean
    var
        POSUnitFilter: Record "NPR Pop Up Dim POS Unit Filter";
    begin
        if not POSPaymentViewEventSetup.Get() then
            exit(true);

        if not POSPaymentViewEventSetup."Dimension Popup Enabled" then
            exit(true);

        if not ValidTime(Time, POSPaymentViewEventSetup."Popup Start Time", POSPaymentViewEventSetup."Popup End Time") then
            exit(true);

        if POSPaymentViewEventSetup."Dimension Code" = '' then
            exit(true);

        if POSPaymentViewEventSetup."Skip Popup on Dimension Value" then begin
            if HasDimValue(SalePOS, POSPaymentViewEventSetup."Dimension Code") then
                exit(true);
        end;

        if SkipOnItemFilter(SalePOS) then
            exit(true);

        if POSPaymentViewEventSetup."Enable Selected POS Units" then
            if not POSUnitFilter.Get(SalePOS."Register No.") then
                exit(true)
            else
                exit(not POSUnitFilter.Enable);

        exit(false);
    end;

    local procedure SkipOnItemFilter(SalePOS: Record "NPR POS Sale"): Boolean;
    var
        SalePOSLine: Record "NPR POS Sale Line";
        PopupDimFilter: Record "NPR Popup Dim. Filter";
    begin
        if PopupDimFilter.IsEmpty() then
            exit(false);
        SalePOSLine.SetRange("Register No.", SalePOS."Register No.");
        SalePOSLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SalePOSLine.SetRange("Line Type", SalePOSLine."Line Type"::Item);
        if not SalePOSLine.FindSet() then
            exit(true);
        repeat
            if PopupDimFilter.Get(PopupDimFilter.Type::Item, SalePOSLine."No.") or PopupDimFilter.Get(PopupDimFilter.Type::"Item Category", SalePOSLine."Item Category Code") then
                exit(false);
        until SalePOSLine.Next() = 0;

        exit(true);
    end;

    local procedure ValidTime(CheckTime: Time; StartTime: Time; EndTime: Time): Boolean
    begin
        if EndTime = 0T then
            exit(CheckTime >= StartTime);

        if StartTime = 0T then
            exit(CheckTime <= EndTime);

        if StartTime <= EndTime then
            exit((CheckTime >= StartTime) and (CheckTime <= EndTime));

        exit((CheckTime >= StartTime) or (CheckTime <= EndTime));
    end;

    local procedure HasDimValue(SalePOS: Record "NPR POS Sale"; DimensionCode: Code[20]): Boolean
    var
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        if SalePOS."Dimension Set ID" = 0 then
            exit(false);
        DimensionSetEntry.SetRange("Dimension Set ID", SalePOS."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", DimensionCode);
        if not DimensionSetEntry.FindFirst() then
            exit(false);

        exit(DimensionSetEntry."Dimension Value Code" <> '');
    end;
}
