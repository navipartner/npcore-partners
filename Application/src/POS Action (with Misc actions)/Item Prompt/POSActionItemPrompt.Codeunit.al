codeunit 6150843 "NPR POS Action: Item Prompt" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action prompts for a numeric item number';
        Title: Label 'We need more information.';
        Caption: Label 'Item Number';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('title', Title);
        WorkflowConfig.AddLabel('caption', Caption);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'createitem':
                FrontEnd.WorkflowResponse(CreateItem());
        end;
    end;

    local procedure CreateItem() Response: JsonObject;
    begin
        Response.Add('workflowName', 'ITEM');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionItemPrompt.js###
'let main=async({workflow:t,captions:e,parameters:n})=>{let a=await popup.stringpad({title:e.title,caption:e.caption});if(a===null)return" ";const{workflowName:i}=await t.respond("createitem");await t.run(i,{parameters:{itemNo:a.toString(),itemQuantity:1,itemIdentifierType:0}})};'
        )
    end;
}

