codeunit 6150823 "NPR POSAction: Set Tax Liable"
{
    var
        ActionDescription: Label 'Set Tax Liable';
        Title: Label 'Tax Liable property';
        Prompt: Label 'Set Tax Liable property?';
        ReadingErr: Label 'reading in %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('decl0', 'confirmtext = labels.prompt;');
                RegisterWorkflowStep('decl1', 'ask = false');
                RegisterWorkflowStep('confirm', 'confirm({title: labels.title, caption: confirmtext}).respond().no().respond();');
                RegisterWorkflow(false);

            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        SetTaxLiable(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'prompt', Prompt);
    end;

    local procedure SetTaxLiable(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        Line: Record "NPR Sale Line POS";
        SaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR Sale POS";
        POSSale: Codeunit "NPR POS Sale";
        TaxLiableValue: Boolean;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        TaxLiableValue := JSON.GetBooleanOrFail('value', StrSubstNo(ReadingErr, ActionCode()));

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Tax Liable", TaxLiableValue);
        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Text
    begin
        exit('SETTAXLIABLE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;
}
