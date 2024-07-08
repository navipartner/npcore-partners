codeunit 6059956 "NPR POS Action - Ins. AddCustF" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert a Additional Customer Field for sale ';
        ParamDefaultDesc_CptLbl: Label 'Default Additional Customer Field';
        ParamDefaultDesc_DescLbl: Label 'Specifies Default Additional Customer Field';
        ParamEditDesc_CptLbl: Label 'Edit Additional Customer Field';
        ParamEditDesc_DescLbl: Label 'Enable/Disable Additional Customer Field edit';
        ParamEditDesc_OptCptLbl: Label 'Yes,No';
        ParamEditDesc_OptLbl: Label 'Yes,No', Locked = true;
        Prompt_EnterAddCustField: Label 'Enter Additional Customer Field';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('DefaultAddCustField', '', ParamDefaultDesc_CptLbl, ParamDefaultDesc_DescLbl);
        WorkflowConfig.AddOptionParameter('EditAddCustField',
                                          ParamEditDesc_OptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamEditDesc_OptLbl),
#pragma warning restore 
                                          ParamEditDesc_CptLbl,
                                          ParamEditDesc_DescLbl,
                                          ParamEditDesc_OptCptLbl);
        WorkflowConfig.AddLabel('prompt', Prompt_EnterAddCustField);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'InsertAddCustField':
                InputPosRSCustomerAddCustField(Context, Sale);
        end;
    end;

    local procedure InputPosRSCustomerAddCustField(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        RSPOSSale: Record "NPR RS POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        RSPOSSale."POS Sale SystemId" := POSSale.SystemId;
        RSPOSSale."RS Add. Customer Field" := CopyStr(Context.GetString('NewAddCustField'), 1, MaxStrLen(RSPOSSale."RS Add. Customer Field"));
        if not RSPOSSale.Insert() then
            RSPOSSale.Modify();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionInsertAddCustF.js###
'let main=async({workflow:i,captions:e,parameters:t})=>{let d;if(t.EditAddCustField==t.EditAddCustField.Yes&&(d=t.DefaultAddCustField+await popup.input({caption:e.prompt})),!(d===null||d===""))return await i.respond("InsertAddCustField",{NewAddCustField:d})};'
        )
    end;
}
