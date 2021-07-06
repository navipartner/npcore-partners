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

        exit('1.1');
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
            Sender.RegisterWorkflowStep('PasswordPrompt', 'context.ShowPasswordPrompt && input({title: labels.title, caption: labels.password}).respond().cancel(abort);');
            Sender.RegisterWorkflowStep('ToggleBlockState', 'respond();');

            Sender.RegisterWorkflow(true);
            Sender.RegisterDataBinding();

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        POSSecurityProfile: Record "NPR POS Security Profile";
    begin

        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'password', StrSubstNo(PasswordPrompt, POSSecurityProfile.FieldCaption("Password on Unblock Discount")));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
        POSSecurityProfile: Record "NPR POS Security Profile";
        Setup: Codeunit "NPR POS Setup";
        Context: Codeunit "NPR POS JSON Management";
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        Setup.GetPOSUnit(POSUnit);
        POSUnit.GetProfile(POSSecurityProfile);
        Context.SetContext('ShowPasswordPrompt', POSSecurityProfile."Password on Unblock Discount" <> '');

        FrontEnd.SetActionContext(ActionCode(), Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        case WorkflowStep of
            'PasswordPrompt':
                VerifyPassword(Context, POSSession, FrontEnd);
            'ToggleBlockState':
                ToggleBlockState(POSSession);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Ext.: Line Format.", 'OnGetLineStyle', '', false, false)]
    local procedure OnGetStyle(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "NPR POS Sale Line"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        if (SaleLinePOS."Custom Disc Blocked") then begin
            Color := 'blue';
        end;
    end;

    local procedure VerifyPassword(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSecurityProfile: Record "NPR POS Security Profile";
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
        POSUnit.GetProfile(POSSecurityProfile);
        if (POSSecurityProfile."Password on Unblock Discount" <> Password) then
            Error('');
    end;

    local procedure ToggleBlockState(POSSession: Codeunit "NPR POS Session")
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
