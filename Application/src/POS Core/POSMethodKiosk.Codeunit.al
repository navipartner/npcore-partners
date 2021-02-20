codeunit 6150741 "NPR POS Method - Kiosk"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', false, false)]
    local procedure OnUnlockKiosk(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Request: Codeunit "NPR Front-End: Generic";
        Pin: Text;
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        SSProfile: Record "NPR SS Profile";
    begin
        if Method <> 'UnlockKiosk' then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSUnit.GetProfile(SSProfile);
        Request.SetMethod('UnlockKiosk');
        Request.GetContent().Add('confirmed', IsValidPIN(JSON.GetString('pin', true), SSProfile."Kiosk Mode Unlock PIN"));
        FrontEnd.InvokeFrontEndMethod(Request);

        Handled := true;
    end;

    local procedure IsValidPIN(PIN: Text; UnlockPIN: Text): Boolean
    begin
        exit(PIN = UnlockPIN);
    end;
}

