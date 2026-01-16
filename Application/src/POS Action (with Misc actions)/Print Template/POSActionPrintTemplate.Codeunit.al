codeunit 6150834 "NPR POS Action: Print Template" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'This is a built-in action for running a report';
        ParamRecord_CptLbl: Label 'Record';
        ParamRecord_DescLbl: Label 'Specifies Record';
        ParamRecord_OptDescLbl: Label 'Sale Line,Sale Header';
        ParamRecord_OptLbl: Label 'Sale Line,Sale Header', Locked = true;
        ParamTemplate_CaptLbl: Label 'Templete';
        ParamTemplate_DescLbl: Label 'Specifies template.';
        ParamPrintAllLines_CaptLbl: Label 'Print All Lines';
        ParamPrintAllLines_DescLbl: Label 'Specifies if user wants to print all lines';
        ParamSingularQuantityPrinting_CaptLbl: Label 'Singular Quantity Printing';
        ParamSingularQuantityPrinting_DescLbl: Label 'Specifies singular quantity printing';
        ParamUseReportSelection_CaptLbl: Label 'Use Report Selection Print Template';
        ParamUseReportSelection_DescLbl: Label 'Specifies if template should be selected from Report Selection - Retail based on POS Unit';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);

        WorkflowConfig.AddBooleanParameter('UseReportSelPrintTemplate', false, ParamUseReportSelection_CaptLbl, ParamUseReportSelection_DescLbl);
        WorkflowConfig.AddTextParameter('Template', '', ParamTemplate_CaptLbl, ParamTemplate_DescLbl);
        WorkflowConfig.AddOptionParameter('Record',
#pragma warning disable AA0139
                                          ParamRecord_OptLbl,
                                          SelectStr(1, ParamRecord_OptLbl),
#pragma warning restore                                          
                                          ParamRecord_CptLbl,
                                          ParamRecord_DescLbl,
                                          ParamRecord_OptDescLbl);
        WorkflowConfig.AddBooleanParameter('PrintAllLines', false, ParamPrintAllLines_CaptLbl, ParamPrintAllLines_DescLbl);
        WorkflowConfig.AddBooleanParameter('SingularQuantityPrinting', false, ParamSingularQuantityPrinting_CaptLbl, ParamSingularQuantityPrinting_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        RecordSetting: Option "Sale Line POS","Sale POS";
        Template: Text[20];
        PrintAllLines: Boolean;
        SingularQuantityPrinting: Boolean;
        UseReportSelPrintTemplate: Boolean;
    begin
        UseReportSelPrintTemplate := Context.GetBooleanParameter('UseReportSelPrintTemplate');
        Template := CopyStr(Context.GetStringParameter('Template'), 1, MaxStrLen(Template));
        RecordSetting := Context.GetIntegerParameter('Record');
        PrintAllLines := Context.GetBooleanParameter('PrintAllLines');
        SingularQuantityPrinting := Context.GetBooleanParameter('SingularQuantityPrinting');

        PrintTemplate(Sale, SaleLine, RecordSetting, Template, PrintAllLines, SingularQuantityPrinting, UseReportSelPrintTemplate, Setup);
    end;

    local procedure PrintTemplate(var Sale: Codeunit "NPR POS Sale"; var SaleLine: Codeunit "NPR POS Sale Line"; var RecordSetting: Option "Sale Line POS","Sale POS"; Template: Text[20]; PrintAllLines: Boolean; SingularQuantityPrinting: Boolean; UseReportSelPrintTemplate: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        NoOfPrints: Integer;
        i: Integer;
        TemplateToUse: Code[20];
    begin
        if UseReportSelPrintTemplate then
            TemplateToUse := GetTemplateFromReportSelection(Setup)
        else
            TemplateToUse := CopyStr(Template, 1, MaxStrLen(TemplateToUse));

        case RecordSetting of
            RecordSetting::"Sale Line POS":
                begin
                    SaleLine.GetCurrentSaleLine(SaleLinePOS);
                    SaleLinePOS.SetRecFilter();

                    if PrintAllLines then
                        SaleLinePOS.SetRange("Line No.");

                    if SaleLinePOS.FindSet() then
                        repeat
                            SaleLinePOS2 := SaleLinePOS;
                            SaleLinePOS2.SetRecFilter();
                            if SingularQuantityPrinting then
                                NoOfPrints := SaleLinePOS.Quantity
                            else
                                NoOfPrints := 1;
                            for i := 1 to NoOfPrints do
                                TemplateMgt.PrintTemplate(TemplateToUse, SaleLinePOS2, 0);
                        until SaleLinePOS.Next() = 0;
                end;
            RecordSetting::"Sale POS":
                begin
                    Sale.GetCurrentSale(SalePOS);
                    SalePOS.SetRecFilter();
                    TemplateMgt.PrintTemplate(TemplateToUse, SalePOS, 0);
                end;
        end;
    end;

    local procedure GetTemplateFromReportSelection(Setup: Codeunit "NPR POS Setup"): Code[20]
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        POSUnit: Record "NPR POS Unit";
        ReportSelectionType: Enum "NPR Report Selection Type";
    begin
        Setup.GetPOSUnit(POSUnit);

        ReportSelectionRetail.SetLoadFields("Report Type", "Print Template", "Register No.");
        ReportSelectionRetail.SetRange("Report Type", ReportSelectionType::"Print Template");
        ReportSelectionRetail.SetFilter("Print Template", '<>%1', '');
        if ReportSelectionRetail.IsEmpty() then
            exit('');

        ReportSelectionRetail.SetRange("Register No.", POSUnit."No.");
        if ReportSelectionRetail.FindFirst() then
            exit(ReportSelectionRetail."Print Template");

        ReportSelectionRetail.SetRange("Register No.", '');
        if ReportSelectionRetail.FindFirst() then
            exit(ReportSelectionRetail."Print Template");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPrintTemplate.js###
'let main=async({})=>await workflow.respond();'
        )
    end;

}
