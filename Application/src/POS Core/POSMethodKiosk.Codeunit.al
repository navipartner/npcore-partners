codeunit 6150741 "NPR POS Method - Kiosk"
{
    // NPR5.38/VB  /20171206 CASE 300814 Support for kiosk mode in Major Tom
    // NPR5.45/TJ  /20180809 CASE 323728 PIN for unlocking is now read from POS Unit


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnUnlockKiosk(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Request: Codeunit "NPR Front-End: Generic";
        Pin: Text;
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        if Method <> 'UnlockKiosk' then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        //-NPR5.45 [323728]
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        //+NPR5.45 [323728]
        Request.SetMethod('UnlockKiosk');
        //-NPR5.45 [323728]
        //Request.Content.Add('confirmed',IsValidPIN(JSON.GetString('pin',TRUE)));
        Request.GetContent().Add('confirmed', IsValidPIN(JSON.GetString('pin', true), POSUnit."Kiosk Mode Unlock PIN"));
        //+NPR5.45 [323728]
        FrontEnd.InvokeFrontEndMethod(Request);

        Handled := true;
    end;

    local procedure IsValidPIN(PIN: Text; UnlockPIN: Text): Boolean
    begin
        //-NPR5.45 [323728]
        //EXIT(PIN = '1313');
        exit(PIN = UnlockPIN);
        //+NPR5.45 [323728]
    end;
}

