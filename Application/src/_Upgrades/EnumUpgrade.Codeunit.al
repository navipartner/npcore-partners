codeunit 6014657 "NPR Enum Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeEnums();
    end;

    local procedure UpgradeEnums()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enum Upgrade")) then begin
            LogMessageStopwatch.LogStart(CompanyName(), 'NPR Enum Upgrade.', 'UpgradeItemReferenceEnums');
            DoUpgradeItemReferenceEnums();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enum Upgrade"));
            LogMessageStopwatch.LogFinish();
        end;

        if not UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enum Upgrade", 'UpgradeNPREKitchenOrderStatusEnum')) then begin
            LogMessageStopwatch.LogStart(CompanyName(), 'NPR Enum Upgrade', 'UpgradeNPREKitchenOrderStatusEnum');
            UpgradeNPREKitchenOrderStatusEnum();
            UpgradeRestaurantSetupEnums();
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enum Upgrade", 'UpgradeNPREKitchenOrderStatusEnum'));
            LogMessageStopwatch.LogFinish();
        end;
    end;

    local procedure DoUpgradeItemReferenceEnums()
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetRange("Reference Type", 4);
        if ItemReference.FindSet(true) then
            repeat
                if not ItemReference.Get(ItemReference."Item No.", ItemReference."Variant Code", ItemReference."Unit of Measure", ItemReference."Reference Type"::"NPR Retail Serial No.", ItemReference."Reference Type No.", ItemReference."Reference No.") then
                    ItemReference.Rename(ItemReference."Item No.", ItemReference."Variant Code", ItemReference."Unit of Measure", ItemReference."Reference Type"::"NPR Retail Serial No.", ItemReference."Reference Type No.", ItemReference."Reference No.");
            until ItemReference.Next() = 0;
    end;

    local procedure UpgradeNPREKitchenOrderStatusEnum()
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        xKitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
    begin
        if KitchenOrder.FindSet(true) then
            repeat
                xKitchenOrder := KitchenOrder;
                KitchenOrderMgt.UpdateOrderStatus(KitchenOrder);
                if xKitchenOrder."Order Status" <> KitchenOrder."Order Status" then
                    KitchenOrder.Modify();
            until KitchenOrder.Next() = 0;
    end;

    local procedure UpgradeRestaurantSetupEnums()
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        if not RestaurantSetup.Get() then
            exit;
        RestaurantSetup."Auto-Send Kitchen Order" := Enum::"NPR NPRE Auto Send Kitch.Order".FromInteger(RestaurantSetup."Auto Send Kitchen Order" + 1);
        RestaurantSetup."Re-send All on New Lines" := Enum::"NPR NPRE Send All on New Lines".FromInteger(RestaurantSetup."Resend All On New Lines" + 1);
        RestaurantSetup."Kitchen Req. Handl. On Serving" := Enum::"NPR NPRE Req.Handl.on Serving".FromInteger(RestaurantSetup."Station Req. Handl. On Serving" + 1);
        RestaurantSetup."Order ID Assignment Method" := Enum::"NPR NPRE Ord.ID Assign. Method".FromInteger(RestaurantSetup."Order ID Assign. Method" + 1);
        RestaurantSetup.Modify();
    end;
}
