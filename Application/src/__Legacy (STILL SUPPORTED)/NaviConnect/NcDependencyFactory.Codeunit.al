codeunit 6151502 "NPR Nc Dependency Factory"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
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

    procedure CreateNCImportListProcessor(var Processor: Interface "NPR Nc Import List IProcess"; ImportType: Record "NPR Nc Import Type"): Boolean
    var
        Handled: Boolean;
    begin
        OnDiscoverNcImportListProcessor(Processor, ImportType, Handled);
        if Handled then
            exit(true);

        Processor := ImportType."Import List Process Handler";
        exit(true);
    end;

    procedure CreateNCImportListILookup(var ILookup: Interface "NPR Nc Import List ILookup"; ImportType: Record "NPR Nc Import Type"): Boolean
    var
        Handled: Boolean;
    begin
        OnDiscoverNcImportListILookup(ILookup, ImportType, Handled);
        if Handled then
            exit(true);

        ILookup := ImportType."Import List Lookup Handler";
        exit(true);
    end;
    #endregion

    #region Event Publishers
    [IntegrationEvent(false, false)]
    local procedure OnDiscoverNcImportListUpdater(var Updater: Interface "NPR Nc Import List IUpdate"; ImportType: Record "NPR Nc Import Type"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverNcImportListProcessor(var Processor: Interface "NPR Nc Import List IProcess"; ImportType: Record "NPR Nc Import Type"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverNcImportListILookup(var ILookup: Interface "NPR Nc Import List ILookup"; ImportType: Record "NPR Nc Import Type"; var Handled: Boolean)
    begin
    end;
    #endregion
}
