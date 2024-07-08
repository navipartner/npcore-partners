codeunit 6150810 "NPR POSAction: Run Report" implements "NPR IPOS Workflow"
{
    Access = internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for running a report';
        RecordIdCaptionLbl: Label 'Report Id';
        RecordIdDescriptionLbl: Label 'Specifies Report''s id';
        RequestPageCaptionLbl: label 'Request Page';
        RequestPageDescriptionLbl: label 'Specifies should Request Page be called';
        RecordOption_OptionNameLbl: Label 'None,SaleLine,SaleHeader', Locked = true;
        RecordCaptionLbl: Label 'Record';
        RecordDescriptionLbl: Label 'Specifies the Record as Table View';
        RecordOption_OptionCaptionLbl: Label 'None,POS Sale Line,POS Sale Header';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddIntegerParameter('ReportId', 0, RecordIdCaptionLbl, RecordIdDescriptionLbl);
        WorkflowConfig.AddBooleanParameter('RequestPage', false, RequestPageCaptionLbl, RequestPageDescriptionLbl);
        WorkflowConfig.AddOptionParameter('Record',
            RecordOption_OptionNameLbl,
#pragma warning disable AA0139
            SelectStr(1, RecordOption_OptionNameLbl),
#pragma warning restore 
            RecordCaptionLbl,
            RecordDescriptionLbl,
            RecordOption_OptionCaptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        ReportId: Integer;
        RunRequestPage: Boolean;
        RecordSetting: Option "None","Sale Line POS","Sale POS";
        SetRecord: Variant;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
    begin
        ReportId := Context.GetIntegerParameter('ReportId');
        RunRequestPage := Context.GetBooleanParameter('RequestPage');
        RecordSetting := Context.GetIntegerParameter('Record');

        case RecordSetting of
            RecordSetting::None:
                report.run(ReportId, RunRequestPage);
            RecordSetting::"Sale Line POS":
                begin
                    SaleLine.GetCurrentSaleLine(SaleLinePOS);
                    POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
                    SaleLinePOS.SetRecFilter();
                    SetRecord := SaleLinePOS;
                    RunReport(ReportId, RunRequestPage, SetRecord)
                end;
            RecordSetting::"Sale POS":
                begin
                    Sale.GetCurrentSale(SalePOS);
                    POSSale.GetCurrentSale(SalePOS);
                    SalePOS.SetRecFilter();
                    SetRecord := SalePOS;
                    RunReport(ReportId, RunRequestPage, SetRecord)
                end;
        end;


    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRunReport.js###
        'let main=async({})=>await workflow.respond();'
        );
    end;

    local procedure RunReport(ReportId: Integer; RunRequestPage: Boolean; SetRecord: Variant)
    begin
        if ReportId = 0 then
            exit;
        Report.Run(ReportId, RunRequestPage, false, SetRecord);
    end;
}
