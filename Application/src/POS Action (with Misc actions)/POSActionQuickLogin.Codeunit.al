codeunit 6150845 "NPR POS Action: Quick Login"
{
    var
        Text000: Label 'Quick Login - change Salesperson on current POS Sale';
        ReadingErr: Label 'reading in %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            Text000,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
                then begin
            Sender.RegisterWorkflowStep('FixedSalespersonCode', 'if (param.FixedSalespersonCode != "")  {respond()}');
            Sender.RegisterWorkflowStep('LookupSalespersonCode', 'if (param.LookupSalespersonCode)  {respond()}');

            Sender.RegisterTextParameter('FixedSalespersonCode', '');
            Sender.RegisterBooleanParameter('LookupSalespersonCode', true);
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'FixedSalespersonCode':
                begin
                    Handled := true;
                    OnActionFixedSalespersonCode(JSON, POSSession);

                    exit;
                end;
            'LookupSalespersonCode':
                begin
                    Handled := true;
                    OnActionLookupSalespersonCode(JSON, POSSession);
                    exit;
                end;
        end;
    end;

    local procedure OnActionFixedSalespersonCode(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        SalespersonCode: Code[20];
    begin
        JSON.SetScopeParameters(ActionCode());
        SalespersonCode := JSON.GetStringOrFail('FixedSalespersonCode', StrSubstNo(ReadingErr, ActionCode()));
        if SalespersonCode = '' then
            exit;

        ApplySalespersonCode(SalespersonCode, POSSession);

        POSSession.RequestRefreshData();
    end;

    local procedure OnActionLookupSalespersonCode(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();
        if SalespersonPurchaser.Get(SalePOS."Salesperson Code") then;
        SalespersonPurchaser.FilterGroup(2);
        SalespersonPurchaser.SetFilter("NPR Locked-to Register No.", '%1|%2', '', SalePOS."Register No.");
        SalespersonPurchaser.FilterGroup(0);
        if PAGE.RunModal(0, SalespersonPurchaser) <> ACTION::LookupOK then
            exit;

        ApplySalespersonCode(SalespersonPurchaser.Code, POSSession);
        POSSession.RequestRefreshData();
    end;

    local procedure ApplySalespersonCode(SalespersonCode: Code[20]; var POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Find();

        SalePOS.Validate("Salesperson Code", SalespersonCode);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
    end;

    local procedure ActionCode(): Text
    begin
        exit('QUICK_LOGIN');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;
}
