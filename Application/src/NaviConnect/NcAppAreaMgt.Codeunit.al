codeunit 6150946 "NPR Nc App Area Mgmt."
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetEssentialExperienceAppAreas', '', false, false)]
    local procedure OnGetEssentialExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary)
    begin
        TempApplicationAreaSetup."NPR NaviConnect" := true;
    end;
}
