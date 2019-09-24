codeunit 6150838 "POS Action - Block Discount"
{
    // NPR5.38/TSA /20171120 CASE 296709 Initial version
    // NPR5.43/TSA /20180611 CASE 296709 Added formating for blocked lines


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This action toggles the state of "Custom Disc Block" field.';
        Title: Label 'Block / Unblock Discount';
        PasswordPrompt: Label 'Enter %1:';

    local procedure ActionCode(): Code[20]
    begin

        exit('BLOCK_DISCOUNT');
    end;

    local procedure ActionVersion(): Code[10]
    begin

        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
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
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        RetailSetup: Record "Retail Setup";
    begin

        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'password', StrSubstNo(PasswordPrompt, RetailSetup.FieldCaption("Password on unblock discount")));
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action"; Parameters: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        Setup: Codeunit "POS Setup";
        RetailSetup: Record "Retail Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Context: Codeunit "POS JSON Management";
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        RetailSetup.Get();
        Context.SetContext('ShowPasswordPrompt', RetailSetup."Password on unblock discount" <> '');

        FrontEnd.SetActionContext(ActionCode, Context);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
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
    local procedure OnGetStyle(var Color: Text; var Weight: Text; var Style: Text; SaleLinePOS: Record "Sale Line POS"; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    begin

        //-NPR5.43 [296709]
        if (SaleLinePOS."Custom Disc Blocked") then begin
            Color := 'blue';
        end;
        //+NPR5.43 [296709]
    end;

    local procedure VerifyPassword(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        RetailSetup: Record "Retail Setup";
        Password: Text;
    begin

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('/', true);
        JSON.SetScope('$PasswordPrompt', true);
        Password := JSON.GetString('input', true);

        RetailSetup.Get();
        if (RetailSetup."Password on unblock discount" <> Password) then
            Error('');
    end;

    local procedure ToggleBlockState(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
    begin

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLinePOS."Custom Disc Blocked" := not SaleLinePOS."Custom Disc Blocked";
        SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::Manual;
        if (not SaleLinePOS."Custom Disc Blocked") then
            SaleLinePOS."Discount Type" := SaleLinePOS."Discount Type"::" ";

        SaleLinePOS.Modify();

        //-NPR5.43 [296709]
        POSSaleLine.RefreshCurrent();
        POSSession.RequestRefreshData();
        //+NPR5.43 [296709]
    end;
}

