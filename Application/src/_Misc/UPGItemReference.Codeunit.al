codeunit 6150920 "NPR UPG Item Reference"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        UpgItemRefTagDef: Codeunit "NPR UPG ItemRef Tag Def.";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgItemRefTagDef.GetItemRefUpgradeTag()) then
            exit;

        // Run upgrade code
        UpgradeItemCrossReference2ItemReference();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgItemRefTagDef.GetItemRefUpgradeTag());
    end;

    local procedure UpgradeItemCrossReference2ItemReference()
    begin
        UpgradeItemReference();
    end;

    local procedure UpgradeItemReference()
    var
        ItemCrossReference: Record "Item Cross Reference";
        ItemReference: Record "Item Reference";
    begin
        if not ItemCrossReference.FindSet() then
            exit;

        repeat
            if ItemCrossReference."NPR Is Retail Serial No." then begin
                ItemReference."Reference Type" := ItemReference."Reference Type"::"Retail Serial No.";
            end else begin
                ItemReference."Reference Type" := "Item Reference Type".FromInteger(ItemCrossReference."Cross-Reference Type");
            end;
            ItemReference."Item No." := ItemCrossReference."Item No.";
            ItemReference."Variant Code" := ItemCrossReference."Variant Code";
            ItemReference."Unit of Measure" := ItemCrossReference."Unit of Measure";
            ItemReference."Reference Type No." := ItemCrossReference."Cross-Reference Type No.";
            ItemReference."Reference No." := ItemCrossReference."Cross-Reference No.";
            if not ItemReference.Find() then begin
                ItemReference.Init();
                ItemReference.Description := ItemCrossReference.Description;
                ItemReference."Description 2" := ItemCrossReference."Description 2";
                ItemReference."Discontinue Bar Code" := ItemCrossReference."Discontinue Bar Code";
                ItemReference.Insert();
            end;
        until ItemCrossReference.Next() = 0;
    end;

}