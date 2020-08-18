codeunit 6150747 "POS Method - Set Dragonglass"
{
    // NPR5.55/VB  /20200527 CASE 406862 Custom method implemented.


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnSetDragonglass(Method: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Request: DotNet npNetJsonRequest;
        Pin: Text;
        POSSetup: Codeunit "POS Setup";
        POSUnit: Record "POS Unit";
    begin
        if Method <> 'SetDragonglass' then
            exit;

        POSSession.SetDragonglassSession();

        Handled := true;
    end;
}

