codeunit 6151316 "NPR NPRE Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        RefreshKitchenOrderStatus();
        UpdatePrimarySeating();
        UpdateKitchenRequestSeatingAndWaiter();
        UpdateDefaultNumberOfGuests();
        SetPrintOnSaleCancel();
        UpdateKitchenRequestProductionStatuses();
    end;

    local procedure RefreshKitchenOrderStatus()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        xKitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        UpgradeStep := 'RefreshKitchenOrderStatus';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', UpgradeStep);

        if KitchenOrder.FindSet(true) then
            repeat
                xKitchenOrder := KitchenOrder;
                KitchenOrderMgt.UpdateOrderStatus(KitchenOrder);
                if xKitchenOrder."Order Status" <> KitchenOrder."Order Status" then
                    KitchenOrder.Modify();
            until KitchenOrder.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdatePrimarySeating()
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        UpgradeStep := 'UpdatePrimarySeating';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', UpgradeStep);

        SeatingWaiterPadLink2.SetCurrentKey("Waiter Pad No.", Primary);
        SeatingWaiterPadLink2.SetRange(Primary, true);

        SeatingWaiterPadLink.SetCurrentKey("Waiter Pad No.", Primary);
        if SeatingWaiterPadLink.FindSet(true) then
            repeat
                SeatingWaiterPadLink2.SetRange("Waiter Pad No.", SeatingWaiterPadLink."Waiter Pad No.");
                if SeatingWaiterPadLink2.IsEmpty() then begin
                    SeatingWaiterPadLink.Primary := true;
                    SeatingWaiterPadLink.Modify();
                end;
                SeatingWaiterPadLink.SetRange("Waiter Pad No.", SeatingWaiterPadLink."Waiter Pad No.");
                SeatingWaiterPadLink.FindLast();
                SeatingWaiterPadLink.SetRange("Waiter Pad No.");
            until SeatingWaiterPadLink.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateKitchenRequestSeatingAndWaiter()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        UpgradeStep := 'UpdateKitchenRequestSeatingAndWaiter';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', UpgradeStep);

        SeatingWaiterPadLink.SetCurrentKey("Waiter Pad No.", Primary);
        SeatingWaiterPadLink.SetRange(Primary, true);
        if WaiterPad.FindSet() then
            repeat
                SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
                if SeatingWaiterPadLink.FindFirst() then
                    KitchenOrderMgt.UpdateKitchenReqSourceSeating(Enum::"NPR NPRE K.Req.Source Doc.Type"::"Waiter Pad", 0, WaiterPad."No.", 0, SeatingWaiterPadLink."Seating Code");
                if WaiterPad."Assigned Waiter Code" <> '' then
                    WaiterPad.Validate("Assigned Waiter Code");
            until WaiterPad.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateDefaultNumberOfGuests()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        UpgradeStep := 'UpdateDefaultNumberOfGuests';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', UpgradeStep);

        if RestaurantSetup.Get() then
            if RestaurantSetup."Default Number of Guests" = RestaurantSetup."Default Number of Guests"::Default then begin
                RestaurantSetup."Default Number of Guests" := RestaurantSetup."Default Number of Guests"::One;
                RestaurantSetup.Modify();
            end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure SetPrintOnSaleCancel()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        UpgradeStep := 'SetPrintOnSaleCancel';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', UpgradeStep);

        if RestaurantSetup.Get() then begin
            RestaurantSetup."Print on POS Sale Cancel" := true;
            RestaurantSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateKitchenRequestProductionStatuses()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequest2: Record "NPR NPRE Kitchen Request";
        KitchenReqStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenReqStation2: Record "NPR NPRE Kitchen Req. Station";
    begin
        UpgradeStep := 'UpdateKitchenRequestProductionStatuses';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', UpgradeStep);

        KitchenRequest.SetRange("Production Status",
            KitchenRequest."Production Status"::"Started [Obsolete]", KitchenRequest."Production Status"::"Cancelled [Obsolete]");
        if KitchenRequest.FindSet(true) then
            repeat
                KitchenRequest2 := KitchenRequest;
                KitchenRequest2."Production Status" := "NPR NPRE K.Req.L. Prod.Status".FromInteger(KitchenRequest."Production Status".AsInteger() * 10);
                KitchenRequest2.Modify();
            until KitchenRequest.Next() = 0;

        KitchenReqStation.SetRange("Production Status",
            KitchenReqStation."Production Status"::"Started [Obsolete]", KitchenReqStation."Production Status"::"Cancelled [Obsolete]");
        if KitchenReqStation.FindSet(true) then
            repeat
                KitchenReqStation2 := KitchenReqStation;
                KitchenReqStation2."Production Status" := "NPR NPRE K.Req.L. Prod.Status".FromInteger(KitchenReqStation."Production Status".AsInteger() * 10);
                KitchenReqStation2.Modify();
            until KitchenReqStation.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}