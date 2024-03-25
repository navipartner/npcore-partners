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
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);

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
    begin
        Template := CopyStr(Context.GetStringParameter('Template'), 1, MaxStrLen(Template));
        RecordSetting := Context.GetIntegerParameter('Record');
        PrintAllLines := Context.GetBooleanParameter('PrintAllLines');
        SingularQuantityPrinting := Context.GetBooleanParameter('SingularQuantityPrinting');

        PrintTemplate(Sale, SaleLine, RecordSetting, Template, PrintAllLines, SingularQuantityPrinting);
    end;

    local procedure PrintTemplate(var Sale: Codeunit "NPR POS Sale"; var SaleLine: Codeunit "NPR POS Sale Line"; var RecordSetting: Option "Sale Line POS","Sale POS"; Template: Text[20]; PrintAllLines: Boolean; SingularQuantityPrinting: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        NoOfPrints: Integer;
        i: Integer;
    begin
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
                                TemplateMgt.PrintTemplate(Template, SaleLinePOS2, 0);
                        until SaleLinePOS.Next() = 0;
                end;
            RecordSetting::"Sale POS":
                begin
                    Sale.GetCurrentSale(SalePOS);
                    SalePOS.SetRecFilter();
                    TemplateMgt.PrintTemplate(Template, SalePOS, 0);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPrintTemplate.js###
'let main=async({})=>await workflow.respond();'
        )
    end;

}
