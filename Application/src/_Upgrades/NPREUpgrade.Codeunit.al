codeunit 6151316 "NPR NPRE Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";


    trigger OnUpgradePerCompany()
    begin
        RefreshKitchenOrderStatus();
        UpdatePrimarySeating();
        UpdateKitchenRequestSeatingAndWaiter();
        UpdateDefaultNumberOfGuests();
    end;

    local procedure RefreshKitchenOrderStatus()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        xKitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'RefreshKitchenOrderStatus')) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', 'RefreshKitchenOrderStatus');

        if KitchenOrder.FindSet(true) then
            repeat
                xKitchenOrder := KitchenOrder;
                KitchenOrderMgt.UpdateOrderStatus(KitchenOrder);
                if xKitchenOrder."Order Status" <> KitchenOrder."Order Status" then
                    KitchenOrder.Modify();
            until KitchenOrder.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'RefreshKitchenOrderStatus'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdatePrimarySeating()
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SeatingWaiterPadLink2: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdatePrimarySeating')) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', 'UpdatePrimarySeating');

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

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdatePrimarySeating'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateKitchenRequestSeatingAndWaiter()
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateKitchenRequestSeatingAndWaiter')) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', 'UpdateKitchenRequestSeatingAndWaiter');

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

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateKitchenRequestSeatingAndWaiter'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateDefaultNumberOfGuests()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateDefaultNumberOfGuests')) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR NPRE Upgrade', 'UpdateDefaultNumberOfGuests');

        if RestaurantSetup.Get() then
            if RestaurantSetup."Default Number of Guests" = RestaurantSetup."Default Number of Guests"::Default then begin
                RestaurantSetup."Default Number of Guests" := RestaurantSetup."Default Number of Guests"::One;
                RestaurantSetup.Modify();
            end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR NPRE Upgrade", 'UpdateDefaultNumberOfGuests'));
        LogMessageStopwatch.LogFinish();
    end;
}