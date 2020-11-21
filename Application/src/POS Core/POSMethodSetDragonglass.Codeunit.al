codeunit 6150747 "NPR POSMethod: Set Dragonglass"
{
    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnSetDragonglass(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Pin: Text;
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        if Method <> 'SetDragonglass' then
            exit;

        POSSession.SetDragonglassSession();

        Handled := true;
    end;
}
