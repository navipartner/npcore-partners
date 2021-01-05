codeunit 6151502 "NPR Nc Dependency Factory"
{
    #region Factory Methods
    procedure CreateNcImportListUpdater(var Updater: Interface "NPR Nc Import List IUpdate"; ImportType: Record "NPR Nc Import Type"): Boolean
    var
        Handled: Boolean;
    begin
        OnDiscoverNcImportListUpdater(Updater, ImportType, Handled);
        if Handled then
            exit(true);

        Updater := ImportType."Import List Update Handler";
        exit(true);
    end;
    #endregion

    #region Event Publishers
    [IntegrationEvent(false, false)]
    local procedure OnDiscoverNcImportListUpdater(var Updater: Interface "NPR Nc Import List IUpdate"; ImportType: Record "NPR Nc Import Type"; var Handled: Boolean)
    begin
    end;
    #endregion
}