codeunit 6151362 "NPR NPRE POS Action: SplitB.-B"
{
    Access = Internal;

    procedure GetPresetValues(Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup"; var RestaurantCode: Code[20]; var SeatingCode: Code[20]; var WaiterPadNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        if SeatingCode <> '' then
            if Seating.Get(SeatingCode) then
                SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code)
            else
                SeatingCode := '';

        if WaiterPadNo <> '' then
            if WaiterPad.Get(WaiterPadNo) then begin
                SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
                if not SeatingWaiterPadLink.IsEmpty() then begin
                    RestaurantCode := FindRestaurantCode(SeatingWaiterPadLink, Setup.RestaurantCode());
                    if RestaurantCode = '' then
                        RestaurantCode := FindRestaurantCode(SeatingWaiterPadLink, '');
                    if (RestaurantCode <> '') and (SeatingCode = '') then begin
                        SeatingCode := SeatingWaiterPadLink."Seating Code";
                        Seating.Get(SeatingCode);
                    end;
                end;
            end else
                WaiterPadNo := '';

        if RestaurantCode = '' then
            RestaurantCode := Setup.RestaurantCode();

        if (SeatingCode = '') or (WaiterPadNo = '') then begin
            Sale.GetCurrentSale(SalePOS);
            if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
                Seating.Get(SalePOS."NPRE Pre-Set Seating Code");
                SeatingCode := SalePOS."NPRE Pre-Set Seating Code";
            end;

            if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
                WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
                WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
                WaiterPadNo := SalePOS."NPRE Pre-Set Waiter Pad No.";
            end;
        end;

        if (Seating.Code <> '') and (WaiterPad."No." <> '') then
            if not SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.") then
                WaiterPadMgt.AddNewWaiterPadForSeating(Seating.Code, WaiterPad, SeatingWaiterPadLink);
    end;

    local procedure FindRestaurantCode(var SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink"; POSRestaurantCode: Code[20]) RestaurantCode: Code[20]
    begin
        RestaurantCode := FindRestaurantCode(SeatingWaiterPadLink, true, POSRestaurantCode);
        if RestaurantCode = '' then
            RestaurantCode := FindRestaurantCode(SeatingWaiterPadLink, false, POSRestaurantCode);
    end;

    local procedure FindRestaurantCode(var SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink"; PrimaryOnly: Boolean; POSRestaurantCode: Code[20]): Code[20]
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
    begin
        if PrimaryOnly then
            SeatingWaiterPadLink.SetRange(Primary, true)
        else
            SeatingWaiterPadLink.SetRange(Primary);

        if SeatingWaiterPadLink.Find('-') then
            repeat
                if Seating.Get(SeatingWaiterPadLink."Seating Code") and (Seating."Seating Location" <> '') then
                    if SeatingLocation.Get(Seating."Seating Location") and (SeatingLocation."Restaurant Code" <> '') and
                       ((SeatingLocation."Restaurant Code" = POSRestaurantCode) or (POSRestaurantCode = ''))
                    then
                        exit(SeatingLocation."Restaurant Code");
            until SeatingWaiterPadLink.Next() = 0;
        exit('');
    end;

    procedure GenerateSplitBillContext(WaiterPadNo: Code[20]; SeatingCode: Code[20]; var IncludeAllWPads: Option No,Yes,Ask; var WPadLineCollection: JsonArray; var BillCollection: JsonArray)
    var
        SeatingWPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        IncludeAllWPadsQ: Label 'There are multiple waiter pads assigned to the seating %1. Do you want them all to be included in the scope?';
    begin
        Clear(WPadLineCollection);
        Clear(BillCollection);

        if IncludeAllWPads IN [IncludeAllWPads::Yes, IncludeAllWPads::Ask] then begin
            if SeatingCode = '' then
                IncludeAllWPads := IncludeAllWPads::No
            else begin
                SeatingWPadLink.SetCurrentKey(Closed);
                SeatingWPadLink.SetRange("Seating Code", SeatingCode);
                SeatingWPadLink.SetFilter("Waiter Pad No.", '<>%1', WaiterPadNo);
                SeatingWPadLink.SetRange(Closed, false);
                if SeatingWPadLink.IsEmpty then
                    IncludeAllWPads := IncludeAllWPads::No;
            end;
            if IncludeAllWPads = IncludeAllWPads::Ask then
                if Confirm(IncludeAllWPadsQ, true, SeatingCode) then
                    IncludeAllWPads := IncludeAllWPads::Yes
                else
                    IncludeAllWPads := IncludeAllWPads::No;
        end;

        GetWaiterPadLines(WPadLineCollection, WaiterPadNo);

        if IncludeAllWPads = IncludeAllWPads::Yes then
            GetOtherWaiterPads(BillCollection, SeatingWPadLink);
    end;

    local procedure GetWaiterPadLines(var WPadLineCollection: JsonArray; WaiterPadCode: Code[20])
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WPadLineContent: JsonObject;
    begin
        Clear(WPadLineCollection);
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadCode);
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Item);
        if WaiterPadLine.FindSet() then
            repeat
                if WaiterPadLine.Quantity - WaiterPadLine."Billed Quantity" > 0 then begin
                    Clear(WPadLineContent);
                    WPadLineContent.Add('key', WaiterPadLine.GetPosition(false));
                    WPadLineContent.Add('no', WaiterPadLine."No.");
                    WPadLineContent.Add('caption', WaiterPadLine.Description + WaiterPadLine."Description 2");
                    WPadLineContent.Add('qty', WaiterPadLine.Quantity - WaiterPadLine."Billed Quantity");
                    WPadLineCollection.Add(WPadLineContent);
                end;
            until WaiterPadLine.Next() = 0;
    end;

    local procedure GetOtherWaiterPads(var BillCollection: JsonArray; var SeatingWPadLink: Record "NPR NPRE Seat.: WaiterPadLink")
    var
        BillContent: JsonObject;
        WPadLineCollection: JsonArray;
    begin
        if SeatingWPadLink.FindSet() then
            repeat
                GetWaiterPadLines(WPadLineCollection, SeatingWPadLink."Waiter Pad No.");
                if WPadLineCollection.Count() > 0 then begin
                    Clear(BillContent);
                    BillContent.Add('id', SeatingWPadLink."Waiter Pad No.");
                    BillContent.Add('items', WPadLineCollection);
                    BillCollection.Add(BillContent);
                end;
            until SeatingWPadLink.Next() = 0;
    end;

    procedure SaveChangesToWaiterPad(Sale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        Sale.GetCurrentSale(SalePOS);
        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
            Commit();
        end;
    end;

    procedure CleanupSale(SaleLine: Codeunit "NPR POS Sale Line")
    begin
        SaleLine.DeleteWPadSupportedLinesOnly();
    end;

    procedure ProcessWaiterPadSplit(var WaiterPadNo: Code[20]; Bills: JsonToken) ChangesFound: Boolean
    var
        CurrWaiterPad: Record "NPR NPRE Waiter Pad";
        FromWaiterPad: Record "NPR NPRE Waiter Pad";
        FromWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        ToWaiterPad: Record "NPR NPRE Waiter Pad";
        JsonHelper: Codeunit "NPR Json Helper";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        Bill: JsonToken;
        BillLine: JsonToken;
        BillLines: JsonToken;
        TouchedFromWaiterPadList: List of [Code[20]];
        TouchedToWaiterPadList: List of [Code[20]];
        TouchedWaiterPadNo: Code[20];
        MoveQty: Decimal;
    begin
        if not Bills.IsArray() then
            exit;
        CurrWaiterPad.Get(WaiterPadNo);
        foreach Bill in Bills.AsArray() do
            if Bill.SelectToken('items', BillLines) and BillLines.IsArray() then
                if BillLines.AsArray().Count > 0 then begin
                    ToWaiterPad."No." := CopyStr(JsonHelper.GetJCode(Bill, 'id', true), 1, MaxStrLen(ToWaiterPad."No."));
                    FindWaiterPad(CurrWaiterPad, ToWaiterPad);
                    foreach BillLine in BillLines.AsArray() do begin
                        MoveQty := JsonHelper.GetJDecimal(BillLine, 'qty', true);
                        if MoveQty > 0 then begin
                            FromWaiterPadLine.SetPosition(JsonHelper.GetJText(BillLine, 'key', true));
                            if FromWaiterPadLine."Waiter Pad No." <> ToWaiterPad."No." then begin
                                FromWaiterPad.Get(FromWaiterPadLine."Waiter Pad No.");
                                FromWaiterPadLine.Find();
                                WaiterPadPOSMgt.SplitWaiterPadLine(FromWaiterPad, FromWaiterPadLine, MoveQty, ToWaiterPad);
                                if not TouchedFromWaiterPadList.Contains(FromWaiterPad."No.") then
                                    TouchedFromWaiterPadList.Add(FromWaiterPad."No.");
                                if not TouchedToWaiterPadList.Contains(ToWaiterPad."No.") then
                                    TouchedToWaiterPadList.Add(ToWaiterPad."No.");
                                ChangesFound := true;
                            end;
                        end;
                    end;
                end;

        foreach TouchedWaiterPadNo in TouchedFromWaiterPadList do begin
            FromWaiterPad.Get(TouchedWaiterPadNo);
            if FromWaiterPad."Pre-receipt Printed" then
                RestaurantPrint.SetWaiterPadPreReceiptPrinted(FromWaiterPad, false, true);
            WaiterPadMgt.TryCloseWaiterPad(FromWaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Split/Merge Waiter Pad");
        end;

        CurrWaiterPad.Find();
        if not CurrWaiterPad.Closed then begin
            WaiterPadNo := CurrWaiterPad."No.";
            exit;
        end;
        foreach TouchedWaiterPadNo in TouchedToWaiterPadList do begin
            CurrWaiterPad.Get(TouchedWaiterPadNo);
            if not CurrWaiterPad.Closed then begin
                WaiterPadNo := CurrWaiterPad."No.";
                exit;
            end;
        end;
    end;

    local procedure FindWaiterPad(var CurrentWaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        WaiterPad.TestField("No.");
        if WaiterPad.Find() then
            exit;

        Clear(WaiterPad);
        WaiterPadMgt.DuplicateWaiterPadHdr(CurrentWaiterPad, WaiterPad);
        WaiterPadMgt.MoveNumberOfGuests(CurrentWaiterPad, WaiterPad, 1);
    end;

    procedure UpdateSaleAfterSplit(Sale: Codeunit "NPR POS Sale"; WaiterPadNo: Code[20]; var ReturnToDefaultView: Boolean; var CleanupMessageText: Text)
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        Sale.GetCurrentSale(SalePOS);
        WaiterPadPOSMgt.ClearSaleHdrNPREPresetFields(SalePOS, false);
        Sale.Refresh(SalePOS);
        Sale.Modify(true, false);

        if ReturnToDefaultView then
            if WaiterPadPOSMgt.UnsupportedSaleLinesExist(SalePOS) then begin
                CleanupMessageText := WaiterPadPOSMgt.UnableToCleanupSaleMsgText(false);
                ReturnToDefaultView := false;
            end;

        if not ReturnToDefaultView and (WaiterPadNo <> '') then begin
            WaiterPad.Get(WaiterPadNo);
            if not WaiterPad.Closed then
                WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        end;
    end;
}