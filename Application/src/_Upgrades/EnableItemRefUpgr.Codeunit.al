codeunit 6014502 "NPR Enable Item Ref. Upgr."
{
    Subtype = Upgrade;

    var
        AutoEnableItemReferenceTag: Label 'AutoEnableItemReference-20210324';

    trigger OnUpgradePerCompany()
    begin
        AutoEnableItemReference();
    end;

    procedure AutoEnableItemReference()
    var
        ItemReferenceMgt: Codeunit "Item Reference Management";
        FeatureKey: Record "Feature Key";
        FeatureUpdateDataStautus: Record "Feature Data Update Status";
        ItemReference: Record "Item Reference";
        ItemCrossReference: Record "Item Cross Reference";
        UpgradeTag: Codeunit "Upgrade Tag";

    begin
        if UpgradeTag.HasUpgradeTag(AutoEnableItemReferenceTag) then
            exit;

        //If item reference is enabled, add tag and skip update
        if ItemReferenceMgt.IsEnabled() then begin
            UpgradeTag.SetUpgradeTag(AutoEnableItemReferenceTag);
            exit;
        end;

        //Transfer all item reference in cross reference, data update will return it back
        if ItemReference.FindSet() then
            repeat
                ItemCrossReference.TransferFields(ItemReference);
                if not ItemCrossReference.Insert(false) then
                    ItemCrossReference.Modify(false);
            until ItemReference.Next() = 0;
        ItemReference.DeleteAll();

        FeatureKey.Get(ItemReferenceMgt.GetFeatureKey());

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

        UpgradeTag.SetUpgradeTag(AutoEnableItemReferenceTag);
    end;
}
