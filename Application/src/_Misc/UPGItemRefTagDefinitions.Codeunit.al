codeunit 6150919 "NPR UPG ItemRef Tag Def."
{
    // Register the new upgrade tag for new companies when they are created.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    begin
        PerCompanyUpgradeTags.Add(GetItemRefUpgradeTag());
    end;

    // Use methods to avoid hard-coding the tags. It is easy to remove afterwards because it's compiler-driven.
    procedure GetItemRefUpgradeTag(): Text
    begin
        exit('NPRItemRefUpgrade-20210122');
    end;
}