codeunit 6150823 "POS Action - Set Tax Liable"
{
    // NPR9.00.00.5.32/JC  /20170613 CASE 277094 New POS Action for Setting Tax Liable


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Set Tax Liable';
        LookupType: Option "True","False";
        Title: Label 'Tax Liable property';
        Prompt: Label 'Set Tax Liable property?';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep ('decl0', 'confirmtext = labels.prompt;');
            RegisterWorkflowStep ('decl1', 'ask = false');
            RegisterWorkflowStep ('confirm', 'confirm({title: labels.title, caption: confirmtext}).respond().no().respond();');
            RegisterWorkflow(false);

          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        SetTaxLiable (Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'title', Title);
        Captions.AddActionCaption (ActionCode, 'prompt', Prompt);
    end;

    local procedure SetTaxLiable(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        Line: Record "Sale Line POS";
        SaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        TaxLiableValue: Boolean;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        TaxLiableValue := JSON.GetBoolean('value', true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Tax Liable", TaxLiableValue);
        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true,false);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Text
    begin
        exit ('SETTAXLIABLE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;
}

