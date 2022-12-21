codeunit 6150741 "NPR POS Method - Kiosk"
{
    Access = Internal;

    var
        ReadingErr: Label 'reading in %1';

    local procedure MethodName(): Text
    begin
        exit('UnlockKiosk')
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnUnlockKiosk(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Request: Codeunit "NPR Front-End: Generic";
        POSSetup: Codeunit "NPR POS Setup";
        SelfServiceProfile: Codeunit "NPR SS Profile";
        POSUnit: Record "NPR POS Unit";
        [NonDebuggable]
        UnlockPIN: Text[30];
    begin
        if Method <> MethodName() then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        UnlockPIN := SelfServiceProfile.GetUnlockPINIfProfileExist(POSUnit."POS Self Service Profile");
        Request.SetMethod(MethodName());
        Request.GetContent().Add('confirmed', IsValidPIN(JSON.GetStringOrFail('pin', StrSubstNo(ReadingErr, MethodName())), UnlockPIN));
        FrontEnd.InvokeFrontEndMethod2(Request);

        Handled := true;
    end;

    [NonDebuggable]
    local procedure IsValidPIN(PIN: Text; UnlockPIN: Text): Boolean
    begin
        exit(PIN = UnlockPIN);
    end;
}
