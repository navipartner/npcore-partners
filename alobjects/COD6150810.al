codeunit 6150810 "POS Action - Run Report"
{
    // NPR5.32/NPKNAV/20170526  CASE 270854 Transport NPR5.32 - 26 May 2017
    // NPR5.37/MMV /20171018 CASE 293503 Added missing SETRECFILTER
    // NPR5.40/NPKNAV/20180330  CASE 308408 Transport NPR5.40 - 30 March 2018


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running a report';
        ReportMissingError: Label 'That report was not found.';
        POSSetup: Codeunit "POS Setup";

    local procedure ActionCode(): Text
    begin
        exit ('RUNREPORT');
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
            RegisterIntegerParameter ('ReportId', 0);
            RegisterBooleanParameter ('RequestPage', false);
            RegisterOptionParameter ('Record', 'None,Sale Line,Sale Header', 'None');
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ReportId: Integer;
        RunRequestPage: Boolean;
        RecordSetting: Option "None","Sale Line POS","Sale POS";
        "Record": Variant;
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);

        ReportId := JSON.GetInteger ('ReportId', true);
        //-NPR5.40 [308408]
        // RequestPage := JSON.GetBoolean ('RequestPage', TRUE);
        RunRequestPage := JSON.GetBoolean ('RequestPage', true);
        //+NPR5.40 [308408]
        RecordSetting := JSON.GetInteger ('Record', true);

        case RecordSetting of
          RecordSetting::"Sale Line POS" :
            begin
              POSSession.GetSaleLine(POSSaleLine);
              POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
              //-NPR5.37 [293503]
              SaleLinePOS.SetRecFilter;
              //+NPR5.37 [293503]
              Record := SaleLinePOS;
            end;
          RecordSetting::"Sale POS" :
            begin
              POSSession.GetSale(POSSale);
              POSSale.GetCurrentSale(SalePOS);
              //-NPR5.37 [293503]
              SalePOS.SetRecFilter;
              //+NPR5.37 [293503]
              Record := SalePOS;
            end;
        end;
        //-NPR5.40 [308408]
        //RunReport(ReportId, RequestPage, Record);
        RunReport(ReportId, RunRequestPage, Record);
        //+NPR5.40 [308408]
        Handled := true;
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure RunReport(ReportId: Integer;RunRequestPage: Boolean;"Record": Variant)
    var
        ReportPrinterInterface: Codeunit "Report Printer Interface";
    begin
        if ReportId = 0 then
          exit;
        //-NPR5.40 [308408]
        //ReportPrinterInterface.RunReport(ReportId, RequestPage, FALSE, Record);
        ReportPrinterInterface.RunReport(ReportId, RunRequestPage, false, Record);
        //-NPR5.40 [308408]
    end;
}

