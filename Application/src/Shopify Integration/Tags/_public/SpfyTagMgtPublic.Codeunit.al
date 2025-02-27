#if not BC17
codeunit 6248292 "NPR Spfy Tag Mgt. Public"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnGetOwnerTypeAsText(OwnerType: Enum "NPR Spfy Tag Owner Type"; var Result: Text; var Handled: Boolean)
    begin
    end;
}
#endif