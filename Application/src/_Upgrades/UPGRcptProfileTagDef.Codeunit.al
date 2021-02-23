codeunit 6150936 "NPR UPG Rcpt. Profile Tag Def"
{
    // Register the new upgrade tag for new companies when they are created.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    begin
        PerCompanyUpgradeTags.Add(GetUpgradeTag());
    end;

    // Use methods to avoid hard-coding the tags. It is easy to remove afterwards because it's compiler-driven.
    procedure GetUpgradeTag(): Text
    begin
        exit('NPRPOSUnitRcptTxtProfile-99e3b857-d3cf-4ff8-b9fa-4768a63e33b3');
    end;
}