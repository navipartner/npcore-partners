codeunit 6150810 "NPR POSAction: Run Report"
{
    var
        ActionDescription: Label 'This is a built-in action for running a report';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('RUNREPORT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterWorkflow(false);
                RegisterIntegerParameter('ReportId', 0);
                RegisterBooleanParameter('RequestPage', false);
                RegisterOptionParameter('Record', 'None,Sale Line,Sale Header', 'None');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ReportId: Integer;
        RunRequestPage: Boolean;
        RecordSetting: Option "None","Sale Line POS","Sale POS";
        "Record": Variant;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        ReportId := JSON.GetIntegerOrFail('ReportId', StrSubstNo(ReadingErr, ActionCode()));
        RunRequestPage := JSON.GetBooleanOrFail('RequestPage', StrSubstNo(ReadingErr, ActionCode()));
        RecordSetting := JSON.GetIntegerOrFail('Record', StrSubstNo(ReadingErr, ActionCode()));

        case RecordSetting of
            RecordSetting::"Sale Line POS":
                begin
                    POSSession.GetSaleLine(POSSaleLine);
                    POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
                    SaleLinePOS.SetRecFilter;
                    Record := SaleLinePOS;
                end;
            RecordSetting::"Sale POS":
                begin
                    POSSession.GetSale(POSSale);
                    POSSale.GetCurrentSale(SalePOS);
                    SalePOS.SetRecFilter;
                    Record := SalePOS;
                end;
        end;
        RunReport(ReportId, RunRequestPage, Record);
        Handled := true;
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure RunReport(ReportId: Integer; RunRequestPage: Boolean; "Record": Variant)
    var
        ReportPrinterInterface: Codeunit "NPR Report Printer Interface";
    begin
        if ReportId = 0 then
            exit;
        ReportPrinterInterface.RunReport(ReportId, RunRequestPage, false, Record);
    end;
}
