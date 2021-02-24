codeunit 6150836 "NPR POS Action: UnlockPOS"
{
    // NPR5.37/TSA /20171024 CASE 293905 POS Action - Unlock POS, initial version
    // NPR5.38/NPKNAV/20180126  CASE 297087 Transport NPR5.38 - 26 January 2018
    // NPR5.39/TSA /20180214 CASE 305106 Disallow blank password, update current sale with new sales person


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function unlocks the POS';
        IllegalPassword: Label 'Illegal password.';
        ChangeSalesperson: Label 'The POS is logged in by a different salesperson. Do you want to change salesperson?';

    local procedure ActionCode(): Code[20]
    begin

        exit('UNLOCK_POS');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflow(false);
                RegisterDataBinding();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Confirmed: Boolean;
        Type: Text;
        Password: Text;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        RetailSetup: Record "NPR NP Retail Setup";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        PasswordValid: Boolean;
        SalePOS: Record "NPR Sale POS";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        Type := JSON.GetString('type', true);

        Clear(SalespersonPurchaser);
        RetailSetup.Get();

        case Type of
            'SalespersonCode':
                begin
                    Password := JSON.GetString('password', true);

                    SalespersonPurchaser.SetFilter("NPR Register Password", '=%1', Password);
                    PasswordValid := SalespersonPurchaser.FindFirst();

                    if (not PasswordValid) then
                        PasswordValid := (Password = RetailSetup."Open Register Password");

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

                if (not Confirm(ChangeSalesperson, false, POSSetup.Salesperson)) then
                    Error('');

                POSSetup.SetSalesperson(SalespersonPurchaser);

                POSSale.GetCurrentSale(SalePOS);
                SalePOS.Find;

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

