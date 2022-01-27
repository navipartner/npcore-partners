codeunit 6151135 "NPR Ticket App Area Mgmt."
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Ticket Essential" := true;
        TempApplicationAreaSetup."NPR Ticket Advanced" := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetPremiumExperienceAppAreas', '', false, false)]
    local procedure OnGetPremiumExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR Ticket Essential" := false;
        TempApplicationAreaSetup."NPR Ticket Advanced" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt. Facade", 'OnSetExperienceTier', '', false, false)]
    local procedure EnableAdvancedApplicationAreaOnSetExperienceTier(ExperienceTierSetup: record "Experience Tier Setup"; var TempApplicationAreaSetup: record "Application Area Setup" temporary; var ApplicationAreasSet: boolean)
    begin
    end;

}
