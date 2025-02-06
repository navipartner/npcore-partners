codeunit 6248256 "NPR Generic Filter Events"
{
    Access = Internal;
    [IntegrationEvent(true, false)]
    internal procedure OnBeforeSetCurrentPOSUnitFilter(TableNo: Integer; var FilterText: Text; var Hanlded: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    internal procedure OnAfterSetCurrentPOSUnitFilter(TableNo: Integer; var FilterText: Text)
    begin
    end;
}