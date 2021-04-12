codeunit 6150844 "NPR POS Action: Postcode Stats"
{
    var
        ActionDescription: Label 'This action prompts for a post code and store it on the sales header';
        Title: Label 'We need more information.';
        Caption: Label 'Post Code';

    local procedure ActionCode(): Text
    begin
        exit('POSTCODE_STATS');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin

            Sender.RegisterWorkflowStep('postcode', 'input ({title: labels.Title, caption: labels.Caption, value: context.DefaultValue}).cancel(abort);');
            Sender.RegisterWorkflowStep('invoke', 'respond();');
            Sender.RegisterWorkflow(true);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'Title', Title);
        Captions.AddActionCaption(ActionCode(), 'Caption', Caption);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin

        if not Action.IsThisAction(ActionCode()) then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        Context.SetContext('DefaultValue', SalePOS."Stats - Customer Post Code");

        FrontEnd.SetActionContext(ActionCode(), Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        POSAction: Record "NPR POS Action";
        SalePOS: Record "NPR POS Sale";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalePOS."Stats - Customer Post Code" := CopyStr(GetNumpad(JSON, 'postcode'), 1, MaxStrLen(SalePOS."Stats - Customer Post Code"));
        SalePOS.Modify();

        POSSale.Refresh(SalePOS);
    end;

    local procedure GetNumpad(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetString('input'));
    end;
}
