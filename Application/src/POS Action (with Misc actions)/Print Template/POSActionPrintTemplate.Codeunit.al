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
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        RecordSetting: Option "Sale Line POS","Sale POS";
        Template: Text[20];
    begin
        Template := CopyStr(Context.GetStringParameter('Template'), 1, MaxStrLen(Template));
        RecordSetting := Context.GetIntegerParameter('Record');

        PrintTemplate(Sale, SaleLine, RecordSetting, Template);
    end;

    local procedure PrintTemplate(var Sale: Codeunit "NPR POS Sale"; var SaleLine: Codeunit "NPR POS Sale Line"; var RecordSetting: Option "Sale Line POS","Sale POS"; Template: Text[20])
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        TemplateMgt: Codeunit "NPR RP Template Mgt.";
        "Record": Variant;
    begin
        case RecordSetting of
            RecordSetting::"Sale Line POS":
                begin
                    SaleLine.GetCurrentSaleLine(SaleLinePOS);
                    SaleLinePOS.SetRecFilter();
                    Record := SaleLinePOS;
                end;
            RecordSetting::"Sale POS":
                begin
                    Sale.GetCurrentSale(SalePOS);
                    SalePOS.SetRecFilter();
                    Record := SalePOS;
                end;
            else
                exit;
        end;

        TemplateMgt.PrintTemplate(Template, Record, 0);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPrintTemplate.js###
'let main=async({})=>await workflow.respond();'
        )
    end;

}
