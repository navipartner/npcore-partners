codeunit 6151126 "NPR NPRE View Status Resolver"
{
    Access = Internal;

    // Resolves the statuses and colours the POS restaurant view paints its tables and waiter pads with.
    //
    // The per-record helpers on the tables ("NPR NPRE Seating".RGBColorCodeHex and the two on "NPR NPRE Waiter Pad")
    // re-read "NPR NPRE Flow Status", "NPR NPRE Color Table", the seating/waiter pad links and the pads themselves for
    // every single table on screen, so a refresh of a large restaurant costs thousands of round trips. This codeunit
    // loads each of those sets once and answers from memory instead.
    //
    // The resolution rules are reproduced from the table helpers rather than reinvented, because the front end paints
    // real colours from them: the "Available in Front-End" skip, the "Status Color Priority" comparison where an equal
    // priority only wins if nothing has been assigned yet, and the fall back to a blank colour when a status names a
    // colour that no longer exists.

    var
        // AA0073 wants a temporary record's name to start with Temp, and the house rule wants codeunit-lived state to
        // start with an underscore. These are both, and they are read from five procedures, so the underscore is the
        // one that earns its keep. Same resolution as "NPR TM ImportTicketWorker".
#pragma warning disable AA0073
        _TempColorTable: Record "NPR NPRE Color Table" temporary;
        _TempFlowStatus: Record "NPR NPRE Flow Status" temporary;
        _TempOpenWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink" temporary;
        _TempWaiterPad: Record "NPR NPRE Waiter Pad" temporary;
#pragma warning restore AA0073
        _Loaded: Boolean;

    internal procedure Load()
    begin
        if _Loaded then
            exit;
        _Loaded := true;
        LoadFlowStatuses();
        LoadOpenWaiterPads();
    end;

    /// <summary>
    /// The colour a seating is painted with, given its own status and the pads currently open on it.
    /// Mirrors "NPR NPRE Seating".RGBColorCodeHex.
    /// </summary>
    internal procedure SeatingColorHex(SeatingCode: Code[20]; SeatingStatus: Code[10]; IncludeHashMark: Boolean): Text
    var
        ColorHex: Code[6];
        CurrentColorPriority: Integer;
        HasBeenAssigned: Boolean;
    begin
        Load();

        if _TempFlowStatus.Get(SeatingStatus, _TempFlowStatus."Status Object"::Seating) then
            ApplyFlowStatusColor(CurrentColorPriority, HasBeenAssigned, ColorHex);

        // No "Closed" check on the pad here on purpose: the table helper only requires that the pad record exists, and a
        // link that is still open while its pad has been closed must keep colouring the table the way it does today.
        _TempOpenWaiterPadLink.Reset();
        _TempOpenWaiterPadLink.SetRange("Seating Code", SeatingCode);
        if _TempOpenWaiterPadLink.FindSet() then
            repeat
                if _TempWaiterPad.Get(_TempOpenWaiterPadLink."Waiter Pad No.") then begin
                    if _TempFlowStatus.Get(_TempWaiterPad."Serving Step Code", _TempFlowStatus."Status Object"::WaiterPadLineMealFlow) then
                        ApplyFlowStatusColor(CurrentColorPriority, HasBeenAssigned, ColorHex);
                    if _TempFlowStatus.Get(_TempWaiterPad.Status, _TempFlowStatus."Status Object"::WaiterPad) then
                        ApplyFlowStatusColor(CurrentColorPriority, HasBeenAssigned, ColorHex);
                end;
            until _TempOpenWaiterPadLink.Next() = 0;

        exit(FormatColorHex(ColorHex, IncludeHashMark));
    end;

    /// <summary>
    /// The numbers of the pads the view should list for a seating: linked, not closed, and still existing.
    /// </summary>
    internal procedure GetOpenWaiterPadNos(SeatingCode: Code[20]; var WaiterPadNos: List of [Code[20]])
    begin
        Load();

        Clear(WaiterPadNos);
        _TempOpenWaiterPadLink.Reset();
        _TempOpenWaiterPadLink.SetRange("Seating Code", SeatingCode);
        if _TempOpenWaiterPadLink.FindSet() then
            repeat
                if _TempWaiterPad.Get(_TempOpenWaiterPadLink."Waiter Pad No.") and not _TempWaiterPad.Closed then
                    WaiterPadNos.Add(_TempWaiterPad."No.");
            until _TempOpenWaiterPadLink.Next() = 0;
    end;

    /// <summary>
    /// Mirrors "NPR NPRE Waiter Pad".WaiterPadFrontEndStatus.
    /// </summary>
    internal procedure WaiterPadFrontEndStatus(WaiterPadNo: Code[20]) StatusCode: Code[10]
    var
        ServingStepFlowOrder: Integer;
    begin
        Load();

        if not _TempWaiterPad.Get(WaiterPadNo) then
            exit('');

        // The serving step contributes its flow order even when it is hidden from the front end, which is what makes a
        // hidden serving step outrank a visible pad status. Reproduced deliberately.
        if _TempFlowStatus.Get(_TempWaiterPad."Serving Step Code", _TempFlowStatus."Status Object"::WaiterPadLineMealFlow) then begin
            ServingStepFlowOrder := _TempFlowStatus."Flow Order";
            if _TempFlowStatus."Available in Front-End" then
                StatusCode := _TempFlowStatus.Code;
        end;

        if _TempFlowStatus.Get(_TempWaiterPad.Status, _TempFlowStatus."Status Object"::WaiterPad) then
            if _TempFlowStatus."Available in Front-End" then
                if (_TempFlowStatus."Flow Order" > ServingStepFlowOrder) or (StatusCode = '') then
                    StatusCode := _TempFlowStatus.Code;
    end;

    /// <summary>
    /// Mirrors "NPR NPRE Waiter Pad".RGBColorCodeHex.
    /// </summary>
    internal procedure WaiterPadColorHex(WaiterPadNo: Code[20]; IncludeHashMark: Boolean): Text
    var
        ColorHex: Code[6];
        CurrentColorPriority: Integer;
        HasBeenAssigned: Boolean;
    begin
        Load();

        if not _TempWaiterPad.Get(WaiterPadNo) then
            exit('');

        if _TempFlowStatus.Get(_TempWaiterPad."Serving Step Code", _TempFlowStatus."Status Object"::WaiterPadLineMealFlow) then
            ApplyFlowStatusColor(CurrentColorPriority, HasBeenAssigned, ColorHex);
        if _TempFlowStatus.Get(_TempWaiterPad.Status, _TempFlowStatus."Status Object"::WaiterPad) then
            ApplyFlowStatusColor(CurrentColorPriority, HasBeenAssigned, ColorHex);

        exit(FormatColorHex(ColorHex, IncludeHashMark));
    end;

    /// <summary>
    /// Mirrors "NPR NPRE Flow Status".GetColorTable against the cached setup, using the flow status currently
    /// positioned on _TempFlowStatus.
    /// </summary>
    local procedure ApplyFlowStatusColor(var CurrentColorPriority: Integer; var HasBeenAssigned: Boolean; var ColorHex: Code[6])
    begin
        if not _TempFlowStatus."Available in Front-End" then
            exit;
        if (CurrentColorPriority >= _TempFlowStatus."Status Color Priority") and HasBeenAssigned then
            exit;

        CurrentColorPriority := _TempFlowStatus."Status Color Priority";
        HasBeenAssigned := true;
        if _TempColorTable.Get(_TempFlowStatus.Color) then
            ColorHex := _TempColorTable."RGB Color Code (Hex)"
        else
            ColorHex := '';
    end;

    /// <summary>
    /// Mirrors "NPR NPRE Color Table".RGBHexCode.
    /// </summary>
    local procedure FormatColorHex(ColorHex: Code[6]; IncludeHashMark: Boolean): Text
    begin
        if IncludeHashMark and (ColorHex <> '') then
            exit('#' + ColorHex);
        exit(ColorHex);
    end;

    local procedure LoadFlowStatuses()
    var
        ColorTable: Record "NPR NPRE Color Table";
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        // Only the colours the statuses actually name are cached. "NPR NPRE Color Table" carries a few hundred rows of
        // named colours and a restaurant uses a handful of them.
        if FlowStatus.FindSet() then
            repeat
                _TempFlowStatus := FlowStatus;
                _TempFlowStatus.Insert();

                if not _TempColorTable.Get(FlowStatus.Color) then
                    if ColorTable.Get(FlowStatus.Color) then begin
                        _TempColorTable := ColorTable;
                        _TempColorTable.Insert();
                    end;
            until FlowStatus.Next() = 0;
    end;

    local procedure LoadOpenWaiterPads()
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // One read of every open link in the company rather than one read per seating. The open links are only as many
        // as there are occupied tables, and the per-seating reads this replaces already scanned the same index.
        SeatingWaiterPadLink.SetCurrentKey(Closed);
        SeatingWaiterPadLink.SetRange(Closed, false);
        if SeatingWaiterPadLink.FindSet() then
            repeat
                _TempOpenWaiterPadLink := SeatingWaiterPadLink;
                _TempOpenWaiterPadLink.Insert();

                if not _TempWaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.") then
                    if WaiterPad.Get(SeatingWaiterPadLink."Waiter Pad No.") then begin
                        _TempWaiterPad := WaiterPad;
                        _TempWaiterPad.Insert();
                    end;
            until SeatingWaiterPadLink.Next() = 0;
    end;
}
