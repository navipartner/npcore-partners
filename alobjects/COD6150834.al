codeunit 6150834 "POS Action - Print Template"
{
    // NPR5.37/MMV /20171018 CASE 293503 Created object.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running a report';
        ReportMissingError: Label 'That report was not found.';
        POSSetup: Codeunit "POS Setup";

    local procedure ActionCode(): Text
    begin
        exit ('PRINT_TEMPLATE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('1','respond();');
            RegisterWorkflow(false);
            RegisterTextParameter('Template', '');
            RegisterOptionParameter ('Record', 'Sale Line,Sale Header', 'Sale Line');
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Template: Text;
        RecordSetting: Option "Sale Line POS","Sale POS";
        "Record": Variant;
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        TemplateMgt: Codeunit "RP Template Mgt.";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);

        Template := JSON.GetString ('Template', true);
        RecordSetting := JSON.GetInteger ('Record', true);

        case RecordSetting of
          RecordSetting::"Sale Line POS" :
            begin
              POSSession.GetSaleLine(POSSaleLine);
              POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
              SaleLinePOS.SetRecFilter;
              Record := SaleLinePOS;
            end;
          RecordSetting::"Sale POS" :
            begin
              POSSession.GetSale(POSSale);
              POSSale.GetCurrentSale(SalePOS);
              SalePOS.SetRecFilter;
              Record := SalePOS;
            end;
          else
            exit;
        end;

        TemplateMgt.PrintTemplate(Template, Record, 0);
        Handled := true;
    end;
}

