codeunit 6014502 "NPR Enable Item Ref. Upgr."
{
    Access = Internal;
    Subtype = Upgrade;
#if BC17 or BC18

    trigger OnUpgradePerCompany()
    begin
        AutoEnableItemReference();
    end;

    procedure AutoEnableItemReference()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        ItemReferenceMgt: Codeunit "Item Reference Management";
        FeatureKey: Record "Feature Key";
        FeatureUpdateDataStautus: Record "Feature Data Update Status";
        ItemReference: Record "Item Reference";
        ItemCrossReference: Record "Item Cross Reference";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Enable Item Ref. Upgr.', 'AutoEnableItemReference');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enable Item Ref. Upgr.")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        //If item reference is enabled, add tag and skip update
        if ItemReferenceMgt.IsEnabled() then begin
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enable Item Ref. Upgr."));
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        //Transfer all item reference in cross reference, data update will return it back
        if ItemReference.FindSet() then
            repeat
                TransferFromItemReferenceToItemCrossReference(ItemReference, ItemCrossReference);
                if not ItemCrossReference.Insert(false) then
                    ItemCrossReference.Modify(false);
            until ItemReference.Next() = 0;
        ItemReference.DeleteAll();

        if not FeatureKey.Get(ItemReferenceMgt.GetFeatureKey()) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        FeatureKey.Validate(Enabled, FeatureKey.Enabled::"All Users");
        FeatureKey.Modify();

        if not FeatureUpdateDataStautus.Get(ItemReferenceMgt.GetFeatureKey(), CompanyName) then begin
            FeatureUpdateDataStautus.Init();
            FeatureUpdateDataStautus."Feature Key" := FeatureKey.ID;
            FeatureUpdateDataStautus."Company Name" := CopyStr(CompanyName, 1, MaxStrLen(FeatureUpdateDataStautus."Company Name"));
            FeatureUpdateDataStautus."Data Update Required" := FeatureKey."Data Update Required";
            case FeatureKey.Enabled of
                FeatureKey.Enabled::None:
                    FeatureUpdateDataStautus."Feature Status" := FeatureUpdateDataStautus."Feature Status"::Disabled;
                FeatureKey.Enabled::"All Users":
                    if FeatureUpdateDataStautus."Data Update Required" then
                        FeatureUpdateDataStautus."Feature Status" := FeatureUpdateDataStautus."Feature Status"::Pending
                    else
                        FeatureUpdateDataStautus."Feature Status" := FeatureUpdateDataStautus."Feature Status"::Enabled;
            end;
            FeatureUpdateDataStautus.Insert();
        end;

        Codeunit.Run(Codeunit::"Update Feature Data", FeatureUpdateDataStautus);

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enable Item Ref. Upgr."));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure TransferFromItemReferenceToItemCrossReference(FromItemReference: Record "Item Reference"; var ToItemCrossReference: Record "Item Cross Reference")
    begin
        ToItemCrossReference.Init();
        ToItemCrossReference."Item No." := FromItemReference."Item No.";
        ToItemCrossReference."Variant Code" := FromItemReference."Variant Code";
        ToItemCrossReference."Unit of Measure" := FromItemReference."Unit of Measure";
        ToItemCrossReference."Cross-Reference Type" := FromItemReference."Reference Type".AsInteger();
        ToItemCrossReference."Cross-Reference Type No." := FromItemReference."Reference Type No.";
        ToItemCrossReference."Cross-Reference No." := CopyStr(FromItemReference."Reference No.", 1, MaxStrLen(ToItemCrossReference."Cross-Reference No."));
        ToItemCrossReference.Description := FromItemReference.Description;
        ToItemCrossReference."Discontinue Bar Code" := FromItemReference."Discontinue Bar Code";
        ToItemCrossReference."Description 2" := FromItemReference."Description 2";
    end;
#endif
}