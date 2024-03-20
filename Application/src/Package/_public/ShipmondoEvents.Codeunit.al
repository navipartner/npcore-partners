codeunit 6184795 "NPR Shipmondo Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeEndShipmentBuild(var PakkelabelsShipment: Record "NPR Shipping Provider Document"; var Output: Text)
    begin

    end;
}