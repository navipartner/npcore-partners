codeunit 6150899 "NPR New POS Sw. Regis. Mgt"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnRequestNewPOSSwitchRegisterEnabled(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ResponseObject: JsonObject;
    begin
        if Method = 'NewPosSwitchRegister_GetEnabled' then begin
            Handled := true;
            ResponseObject.Add('NewPOSSwitchRegisterEnabled', IsNewPOSSwitchRegisterEnabled());
            FrontEnd.RespondToFrontEndMethod(Context, ResponseObject, FrontEnd);
        end;
    end;

    local procedure IsNewPOSSwitchRegisterEnabled(): Boolean
    var
        NewPOSSwitchRegister: Codeunit "NPR New POS Sw. Regis. Feature";
    begin
        exit(NewPOSSwitchRegister.IsFeatureEnabled());
    end;
}