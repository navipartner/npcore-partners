﻿codeunit 6150747 "NPR POSMethod: Set Dragonglass"
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnSetDragonglass(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if Method <> 'SetDragonglass' then
            exit;

        Handled := true;
    end;
}
