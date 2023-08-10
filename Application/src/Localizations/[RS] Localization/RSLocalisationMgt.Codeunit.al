codeunit 6151389 "NPR RS Localisation Mgt."
{
    Access = Internal;

    internal procedure GetLocalisationSetupEnabled(): Boolean
    begin
        if not HasRSLocalisationSetup then
            if RSLocalisationSetup.Get() then
                HasRSLocalisationSetup := true;

        exit(RSLocalisationSetup."Enable RS Local");
    end;

    var
        RSLocalisationSetup: Record "NPR RS Localisation Setup";
        HasRSLocalisationSetup: Boolean;
}