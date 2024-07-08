codeunit 6150789 "NPR POS Action: Print Item" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Print item-based prints.';
        TitleCaption: Label 'Item Print';
        PrintQuantity: Label 'Quantity To Print';
        OptionLineSetting: Label 'All Lines,Selected Line', locked = true;
        CaptionLineSetting: Label 'Line Setting';
        DescLineSetting: Label 'Line settings.';
        OptionCptLineSetting: Label 'All Lines,Selected Line';
        OptionPrintType: Label 'Price,Shelf,Sign', locked = true;
        CaptionPrintType: Label 'Print Type';
        DescPrintType: Label 'print types.';
        OptionCptPrintType: Label 'Price,Shelf,Sign';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('title', TitleCaption);
        WorkflowConfig.AddLabel('PrintQuantity', PrintQuantity);
        WorkflowConfig.AddOptionParameter('LineSetting',
                                        OptionLineSetting,
#pragma warning disable AA0139
                                        SelectStr(2, OptionLineSetting),
#pragma warning restore 
                                        CaptionLineSetting,
                                        DescLineSetting,
                                        OptionCptLineSetting);
        WorkflowConfig.AddOptionParameter('PrintType',
                                        OptionPrintType,
#pragma warning disable AA0139
                                        SelectStr(1, OptionPrintType),
#pragma warning restore 
                                        CaptionPrintType,
                                        DescPrintType,
                                        OptionCptPrintType);
        WorkflowConfig.SetDataBinding();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogicRun: Codeunit "NPR POS Action: Print Item-B";
        LineSetting: Option "All Lines","Selected Line";
        PrintType: Option Price,Shelf,Sign;
        QuantityInput: Integer;
    begin
        LineSetting := Context.GetIntegerParameter('LineSetting');
        PrintType := Context.GetIntegerParameter('PrintType');
        if LineSetting = LineSetting::"Selected Line" then
            QuantityInput := Context.GetInteger('PrintQuantity');

        BusinessLogicRun.PrintItem(LineSetting, PrintType, QuantityInput);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPrintItem.js###
'let main=async({workflow:a,popup:e,parameters:n,captions:i})=>{if(n.LineSetting==n.LineSetting["Selected Line"]){var t=await e.numpad({title:i.title,caption:i.PrintQuantity,value:1,notBlank:!0},"value");if(t===0||t===null)return}await a.respond("PrintQuantity",{PrintQuantity:t})};'
        );
    end;
}
