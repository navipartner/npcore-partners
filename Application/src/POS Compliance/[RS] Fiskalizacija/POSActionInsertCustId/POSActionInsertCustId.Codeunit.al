codeunit 6059952 "NPR POS Action - Insert CustId" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert a Customer Identification for sale ';
        ParamDefaultDesc_CptLbl: Label 'Default Customer Identification';
        ParamDefaultDesc_DescLbl: Label 'Specifies Default Customer Identification';
        ParamEditDesc_CptLbl: Label 'Edit Customer Identification';
        ParamEditDesc_DescLbl: Label 'Enable/Disable Customer Identification edit';
        ParamEditDesc_OptCptLbl: Label 'Yes,No';
        ParamEditDesc_OptLbl: Label 'Yes,No', Locked = true;
        Prompt_EnterCustIdentification: Label 'Enter Customer Identification';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('DefaultCustIdentification', '', ParamDefaultDesc_CptLbl, ParamDefaultDesc_DescLbl);
        WorkflowConfig.AddOptionParameter('EditCustIdentification',
                                          ParamEditDesc_OptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamEditDesc_OptLbl),
#pragma warning restore 
                                          ParamEditDesc_CptLbl,
                                          ParamEditDesc_DescLbl,
                                          ParamEditDesc_OptCptLbl);
        WorkflowConfig.AddLabel('prompt', Prompt_EnterCustIdentification);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'InsertCustIdentification':
                InputPosRSCustomerCustIdentification(Context, Sale);
        end;
    end;

    local procedure InputPosRSCustomerCustIdentification(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        RSPOSSale: Record "NPR RS POS Sale";
        Found: Boolean;
    begin
        Sale.GetCurrentSale(POSSale);
        Found := RSPOSSale.Get(POSSale.SystemId);
        if not Found then
            RSPOSSale."POS Sale SystemId" := POSSale.SystemId;
        RSPOSSale."RS Customer Identification" := CopyStr(Context.GetString('NewCustIdentification'), 1, MaxStrLen(RSPOSSale."RS Customer Identification"));
        if Found then
            RSPOSSale.Modify()
        else
            RSPOSSale.Insert();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionInsertCustId.js###
'let main=async({workflow:n,captions:e,parameters:i})=>{let t;if(i.EditCustIdentification==i.EditCustIdentification.Yes&&(t=i.DefaultCustIdentification+await popup.input({caption:e.prompt})),!(t===null||t===""))return await n.respond("InsertCustIdentification",{NewCustIdentification:t})};'
        )
    end;
}
