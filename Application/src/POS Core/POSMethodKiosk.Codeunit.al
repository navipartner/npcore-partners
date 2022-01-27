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
        POSUnit: Record "NPR POS Unit";
        SSProfile: Record "NPR SS Profile";
    begin
        if Method <> MethodName() then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        POSUnit.GetProfile(SSProfile);
        Request.SetMethod(MethodName());
        Request.GetContent().Add('confirmed', IsValidPIN(JSON.GetStringOrFail('pin', StrSubstNo(ReadingErr, MethodName())), SSProfile."Kiosk Mode Unlock PIN"));
        FrontEnd.InvokeFrontEndMethod(Request);

        Handled := true;
    end;

    local procedure IsValidPIN(PIN: Text; UnlockPIN: Text): Boolean
    begin
        exit(PIN = UnlockPIN);
    end;
}
