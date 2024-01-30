codeunit 6184737 "NPR Retail Localization Mgt."
{
    Access = Internal;

    procedure IsRetailLocalizationEnabled(): Boolean
    begin
        case true of
            RSRetailEnabled():
                exit(true);
            else
                exit(false);
        end;
    end;

    local procedure RSRetailEnabled(): Boolean
    var
        RSRLocalization: Record "NPR RS R Localization Setup";
    begin
        if not RSRLocalization.Get() then
            exit(false);

        exit(RSRLocalization."Enable RS Retail Localization");
    end;
}