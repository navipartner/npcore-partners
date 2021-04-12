codeunit 6150838 "NPR POS Action: Block Discount"
{
    var
        ActionDescription: Label 'This action toggles the state of "Custom Disc Block" field.';
        Title: Label 'Block / Unblock Discount';
        PasswordPrompt: Label 'Enter %1';

    local procedure ActionCode(): Code[20]
    begin

        exit('BLOCK_DISCOUNT');
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

                RegisterWorkflowStep('PasswordPrompt', 'context.ShowPasswordPrompt && input({title: labels.title, caption: labels.password}).respond().cancel(abort);');
                RegisterWorkflowStep('ToggleBlockState', 'respond();');

                RegisterWorkflow(true);
                RegisterDataBinding();

            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        POSUnit: Record "NPR POS Unit";
    begin

        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'password', StrSubstNo(PasswordPrompt, POSUnit.FieldCaption("Password on unblock discount")));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        Setup: Codeunit "NPR POS Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Context: Codeunit "NPR POS JSON Management";
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        Setup.GetPOSUnit(POSUnit);
        Context.SetContext('ShowPasswordPrompt', POSUnit."Password on unblock discount" <> '');

        FrontEnd.SetActionContext(ActionCode, Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Confirmed: Boolean;
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        case WorkflowStep of
            'PasswordPrompt':
                VerifyPassword(Context, POSSession, FrontEnd);
            'ToggleBlockState':
                ToggleBlockState(Context, POSSession, FrontEnd);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150853, 'OnGetLineStyle', '', false, false)]
    local procedure OnGetStyle(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        if (SaleLinePOS."Custom Disc Blocked") then begin
            Color := 'blue';
        end;
    end;

    local procedure VerifyPassword(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSetup: Codeunit "NPR POS Setup";
        JSON: Codeunit "NPR POS JSON Management";
        Password: Text;
        SettingScopeErr: Label 'setting scope in VerifyPassword';
        ReadingErr: Label 'reading scope in VerifyPassword';
    begin

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeRoot();
        JSON.SetScope('$PasswordPrompt', SettingScopeErr);
        Password := JSON.GetStringOrFail('input', ReadingErr);

        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if (POSUnit."Password on unblock discount" <> Password) then
            Error('');
    end;

    local procedure ToggleBlockState(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."Custom Disc Blocked" := not SaleLinePOS."Custom Disc Blocked";
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        if (not SaleLinePOS."Custom Disc Blocked") then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";

        SaleLinePOS.Modify();

        POSSaleLine.RefreshCurrent();
        POSSession.RequestRefreshData();
    end;
}
