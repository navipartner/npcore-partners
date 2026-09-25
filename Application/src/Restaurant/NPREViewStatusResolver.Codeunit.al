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
        _StatusSetupLastModifiedAt: DateTime;
        _RestaurantCode: Code[20];
        _SeatingFilter: Text;
        _Loaded: Boolean;
        _StatusSetupRowCount: Integer;
        FilterAfterLoadErr: Label 'The seating scope of a restaurant view status resolver cannot be narrowed after it has loaded. This is a programming bug.', Locked = true;

    /// <summary>
    /// Narrows the open links this resolver loads to the seatings the caller is going to ask about. Must be called
    /// before the first query, and the caller must then ask about nothing outside the filter: a seating outside it has
    /// no cached links and would resolve to a blank colour rather than its real one.
    /// </summary>
    internal procedure SetSeatingFilter(SeatingFilter: Text)
    begin
        if _Loaded then
            Error(FilterAfterLoadErr);
        _SeatingFilter := SeatingFilter;
    end;

    /// <summary>
    /// Narrows the open links this resolver loads to one restaurant. Same rule as the seating filter: set it before the
    /// first query, and ask about nothing outside it.
    /// </summary>
    internal procedure SetRestaurantScope(RestaurantCode: Code[20])
    begin
        if _Loaded then
            Error(FilterAfterLoadErr);
        _RestaurantCode := RestaurantCode;
    end;

    local procedure Load()
    begin
        if _Loaded then
            exit;
        LoadFlowStatuses();
        LoadOpenWaiterPads();
        // Set last, so an error part way through leaves the instance unloaded rather than quietly answering from a
        // half-built cache.
        _Loaded := true;
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

        // The serving step's flow order is captured even when the step itself is hidden from the front end, but that
        // does not let a hidden step win: a hidden step leaves StatusCode blank, and the blank test below then lets the
        // visible pad status through whatever the orders are. The captured order only decides anything when the step is
        // visible, where it stops a lower-ordered pad status from replacing it.
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

    /// <summary>
    /// How many status and colour rows the view is built from and when the newest of them last changed. Enough to tell
    /// whether the status catalogue in a layout payload has gone out of date.
    /// </summary>
    internal procedure GetStatusSetupFingerprint(var RowCount: Integer; var LastModifiedAt: DateTime)
    begin
        Load();
        RowCount := _StatusSetupRowCount;
        LastModifiedAt := _StatusSetupLastModifiedAt;
    end;

    local procedure LoadFlowStatuses()
    var
        ColorTable: Record "NPR NPRE Color Table";
        FlowStatus: Record "NPR NPRE Flow Status";
    begin
        // Only the colours the statuses actually name are cached. "NPR NPRE Color Table" carries a few hundred rows of
        // named colours and a restaurant uses a handful of them. That also keeps the fingerprint honest: a colour no
        // status names cannot change what the front end is shown, so it has no business invalidating anything.
        //
        // The fingerprint is accumulated while loading simply because the rows are in hand here; a temporary copy would
        // have served equally, since Learn is explicit that a record copied into a temporary table keeps its data audit
        // field values and the server does not restamp them on insert.
        if FlowStatus.FindSet() then
            repeat
                _TempFlowStatus := FlowStatus;
                _TempFlowStatus.Insert();
                CountTowardsStatusSetup(FlowStatus.SystemModifiedAt);

                if not _TempColorTable.Get(FlowStatus.Color) then
                    if ColorTable.Get(FlowStatus.Color) then begin
                        _TempColorTable := ColorTable;
                        _TempColorTable.Insert();
                        CountTowardsStatusSetup(ColorTable.SystemModifiedAt);
                    end;
            until FlowStatus.Next() = 0;
    end;

    local procedure CountTowardsStatusSetup(ModifiedAt: DateTime)
    begin
        _StatusSetupRowCount += 1;
        if ModifiedAt > _StatusSetupLastModifiedAt then
            _StatusSetupLastModifiedAt := ModifiedAt;
    end;

    local procedure LoadOpenWaiterPads()
    var
        OpenWaiterPadLinks: Query "NPR NPRE Open W/Pad Links";
    begin
        // One read for the whole refresh rather than one per seating on screen, and the pad fields come back with it
        // rather than costing a lookup per open pad.
        //
        // Scoped to the restaurant, and to the seatings, when the caller has said which it will ask about. Without that
        // a caller refreshing a single table after a status tap would read every open link in the company to answer for
        // one of them, which is slower than the per-seating primary key seek this replaces.
        if _RestaurantCode <> '' then
            OpenWaiterPadLinks.SetRange(RestaurantCode, _RestaurantCode);
        if _SeatingFilter <> '' then
            OpenWaiterPadLinks.SetFilter(SeatingCode, _SeatingFilter);

        OpenWaiterPadLinks.Open();
        while OpenWaiterPadLinks.Read() do begin
            _TempOpenWaiterPadLink.Init();
            _TempOpenWaiterPadLink."Seating Code" := OpenWaiterPadLinks.SeatingCode;
            _TempOpenWaiterPadLink."Waiter Pad No." := OpenWaiterPadLinks.WaiterPadNo;
            _TempOpenWaiterPadLink.Insert();

            // Only the four fields the resolution rules read are carried over. Anything else on the cached pad is
            // blank, so a later reader wanting another field must widen the query rather than assume a full copy.
            if not _TempWaiterPad.Get(OpenWaiterPadLinks.WaiterPadNo) then begin
                _TempWaiterPad.Init();
                _TempWaiterPad."No." := OpenWaiterPadLinks.WaiterPadNo;
                _TempWaiterPad.Status := OpenWaiterPadLinks.PadStatus;
                _TempWaiterPad."Serving Step Code" := OpenWaiterPadLinks.PadServingStepCode;
                _TempWaiterPad.Closed := OpenWaiterPadLinks.PadClosed;
                _TempWaiterPad.Insert();
            end;
        end;
        OpenWaiterPadLinks.Close();
    end;
}
