﻿codeunit 6150836 "NPR POS Action: UnlockPOS"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used.';

    var
        ActionDescription: Label 'This built in function unlocks the POS';
        IllegalPassword: Label 'Illegal password.';
        ChangeSalesperson: Label 'The POS is logged in by a different salesperson. Do you want to change salesperson?';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin

        exit('UNLOCK_POS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflow(false);
            Sender.RegisterDataBinding();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Type: Text;
        Password: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        PasswordValid: Boolean;
        SalePOS: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        ScurityProfile: Codeunit "NPR POS Security Profile";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        Type := JSON.GetStringOrFail('type', StrSubstNo(ReadingErr, ActionCode()));

        Clear(SalespersonPurchaser);

        case Type of
            'SalespersonCode':
                begin
                    Password := JSON.GetStringOrFail('password', StrSubstNo(ReadingErr, ActionCode()));

                    SalespersonPurchaser.SetFilter("NPR Register Password", '=%1', Password);
                    PasswordValid := SalespersonPurchaser.FindFirst();

                    if (not PasswordValid) then begin
                        POSSetup.GetPOSUnit(POSUnit);
                        PasswordValid := ScurityProfile.IsUnlockPasswordValidIfProfileExist(POSUnit."POS Security Profile", Password)
                    end;
                    if (DelChr(Password, '<=>', ' ') = '') then
                        PasswordValid := false;
                end;
            else
                PasswordValid := false;
        end;

        if (PasswordValid) then begin
            POSSession.GetSale(POSSale);
            POSSession.GetSetup(POSSetup);
            if (SalespersonPurchaser.Code <> POSSetup.Salesperson()) then begin

                if (not Confirm(ChangeSalesperson, false, POSSetup.Salesperson())) then
                    Error('');

                POSSetup.SetSalesperson(SalespersonPurchaser);

                POSSale.GetCurrentSale(SalePOS);
                SalePOS.Find();

                SalePOS.Validate("Salesperson Code", SalespersonPurchaser.Code);
                SalePOS.Modify(true);
                POSSale.RefreshCurrent();

                POSSale.Modify(false, false);
                POSSession.RequestRefreshData();

            end;
        end;

        if (not PasswordValid) then
            Error(IllegalPassword);

        POSSession.GetSetup(POSSetup);
        POSCreateEntry.InsertUnitUnlockEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());

        POSSession.ChangeViewSale();
    end;
}
