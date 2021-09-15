codeunit 6150823 "NPR POSAction: Set Tax Liable"
{
    var
        ActionDescription: Label 'Set Tax Liable';
        Title: Label 'Tax Liable property';
        Prompt: Label 'Set Tax Liable property?';
        ReadingErr: Label 'reading in %1';

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
            Sender.RegisterWorkflowStep('decl0', 'confirmtext = labels.prompt;');
            Sender.RegisterWorkflowStep('decl1', 'ask = false');
            Sender.RegisterWorkflowStep('confirm', 'confirm({title: labels.title, caption: confirmtext}).respond().no().respond();');
            Sender.RegisterWorkflow(false);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        SetTaxLiable(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', Title);
        Captions.AddActionCaption(ActionCode(), 'prompt', Prompt);
    end;

    local procedure SetTaxLiable(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        SalePOS: Record "NPR POS Sale";
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

    local procedure ActionCode(): Code[20]
    begin
        exit('SETTAXLIABLE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;
}
