codeunit 6151490 "NPR RS R Localization Mgt."
{
    Access = Internal;
#if not (BC17 or BC18 or BC19)
    internal procedure IsRSLocalizationActive(): Boolean
    var
        RSRetLocalizationSetup: Record "NPR RS R Localization Setup";
    begin
        if not RSRetLocalizationSetup.Get() then begin
            RSRetLocalizationSetup.Init();
            RSRetLocalizationSetup.Insert();
        end;
        exit(RSRetLocalizationSetup."Enable RS Retail Localization");
    end;
#endif
}