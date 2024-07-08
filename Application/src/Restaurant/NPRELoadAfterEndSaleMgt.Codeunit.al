codeunit 6184571 "NPR NPRE Load AfterEndSale Mgt"
{
    Access = Internal;

    var
        _WaiterPad: Code[20];

    trigger OnRun()
    begin
        LoadNextWaiterPad();
    end;

    internal procedure LoadNextWaiterPad()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        if _WaiterPad = '' then
            Error('');

        WaiterPad.Get(_WaiterPad);
        POSSession.StartTransaction();
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
    end;

    local procedure SetNextWaiterPad(WaiterPad: Code[20])
    begin
        _WaiterPad := WaiterPad;
    end;

    local procedure ClearNextWaiterPad()
    begin
        Clear(_WaiterPad);
    end;

    internal procedure NextWaiterPadSet(POSEntryNo: Integer): Boolean
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        WaiterPad: Code[20];
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        POSEntrySalesLine.SetFilter("NPRE Seating Code", '<>%1', '');
        if not POSEntrySalesLine.FindSet() then
            exit;

        repeat
            WaiterPad := GetWaiterPadForSeating(POSEntrySalesLine."NPRE Seating Code");
            if WaiterPad <> '' then begin
                WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad);
                WaiterPadLine.SetFilter("Sale Retail ID", '<>%1', GetNullGuid());
                if WaiterPadLine.IsEmpty() then begin
                    SetNextWaiterPad(WaiterPad);
                    exit(true);
                end;
            end;
        until (POSEntrySalesLine.Next() = 0);

        ClearNextWaiterPad();
    end;

    procedure GetNullGuid(): Guid
    var
        NullGuid: Guid;
    begin
        Clear(NullGuid);
        exit(NullGuid);
    end;

    internal procedure GetWaiterPadForSeating(SeatingCode: Code[20]): Code[20]
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatingWaiterPadLink.SetCurrentKey(Closed);
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        SeatingWaiterPadLink.SetRange(Closed, false);
        If SeatingWaiterPadLink.FindFirst() then
            exit(SeatingWaiterPadLink."Waiter Pad No.");
    end;
}
