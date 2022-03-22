codeunit 6059782 "NPR Membership App Area Mgmt."
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Membership Essential" := true;
        TempApplicationAreaSetup."NPR Membership Advanced" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetPremiumExperienceAppAreas', '', false, false)]
    local procedure OnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Membership Essential" := false;
        TempApplicationAreaSetup."NPR Membership Advanced" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnSetExperienceTier', '', false, false)]
    local procedure EnableAdvancedApplicationAreaOnSetExperienceTier(ExperienceTierSetup: record "Experience Tier Setup"; var TempApplicationAreaSetup: record "Application Area Setup" temporary; var ApplicationAreasSet: boolean)
    begin
    end;

}