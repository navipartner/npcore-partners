codeunit 6150834 "NPR POS Action: Print Template"
{
    var
        ActionDescription: Label 'This is a built-in action for running a report';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('PRINT_TEMPLATE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
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
            Sender.RegisterWorkflowStep('1', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterTextParameter('Template', '');
            Sender.RegisterOptionParameter('Record', 'Sale Line,Sale Header', 'Sale Line');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Template: Text;
        RecordSetting: Option "Sale Line POS","Sale POS";
        "Record": Variant;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        Template := JSON.GetStringOrFail('Template', StrSubstNo(ReadingErr, ActionCode()));
        RecordSetting := JSON.GetIntegerOrFail('Record', StrSubstNo(ReadingErr, ActionCode()));

        case RecordSetting of
            RecordSetting::"Sale Line POS":
                begin
                    POSSession.GetSaleLine(POSSaleLine);
                    POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
                    SaleLinePOS.SetRecFilter();
                    Record := SaleLinePOS;
                end;
            RecordSetting::"Sale POS":
                begin
                    POSSession.GetSale(POSSale);
                    POSSale.GetCurrentSale(SalePOS);
                    SalePOS.SetRecFilter();
                    Record := SalePOS;
                end;
            else
                exit;
        end;

        TemplateMgt.PrintTemplate(Template, Record, 0);
        Handled := true;
    end;
}
