codeunit 6150747 "NPR POSMethod: Set Dragonglass"
{
    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnSetDragonglass(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if Method <> 'SetDragonglass' then
            exit;

        POSSession.SetDragonglassSession();

        Handled := true;
    end;
}
