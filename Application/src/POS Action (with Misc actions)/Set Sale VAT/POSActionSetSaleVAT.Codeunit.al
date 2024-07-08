codeunit 6150842 "NPR POS Action - Set Sale VAT" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        ActionDescriptionLbl: Label 'Action for changing VAT Business Posting Group of active sale.';
        CommentLine_DescLbl: Label 'Add Comment Line';
        ConfirmDialog_DescLbl: Label 'Confirm Dialog';
        ConfirmLead: Label 'Switch %1 on active sale?';
        ConfirmTitle: Label 'Confirm VAT';
        GenPostingGr_CaptLbl: Label 'Gen. Bus. Posting Group';
        GenPostingGr_DescLbl: Label 'Specify Gen. Bus. Posting Group';
        MaxSaleAmtLimit_CaptLbl: Label 'Maximum Sale Amount Limit';
        MaxSaleAmtLimit_DescLbl: Label 'Specify Maximum Sale Amount Limit';
        MaxSalesAmount_CaptLbl: Label 'Maximum Sale Amount';
        MaxSalesAmount_DescLbl: Label 'Specify Maximum Sale Amount';
        MinSaleAmtLimit_CaptLbl: Label 'Minimum Sale Amount Limit';
        MinSaleAmtLimit_DescLbl: Label 'Specify Minimum Sale Amount Limit';
        MinSalesAmount_CaptLbl: Label 'Minimum Sale Amount';
        MinSalesAmount_DescLbl: Label 'Specify Minimum Sale Amount';
        VatBusPostingGr_CaptLbl: Label 'VAT Bus. Posting Group';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);

        WorkflowConfig.AddBooleanParameter('MinimumSaleAmountLimit', false, MinSaleAmtLimit_CaptLbl, MinSaleAmtLimit_DescLbl);
        WorkflowConfig.AddDecimalParameter('MinimumSaleAmount', 0, MinSalesAmount_CaptLbl, MinSalesAmount_DescLbl);
        WorkflowConfig.AddBooleanParameter('MaximumSaleAmountLimit', false, MaxSaleAmtLimit_CaptLbl, MaxSaleAmtLimit_DescLbl);
        WorkflowConfig.AddDecimalParameter('MaximumSaleAmount', 0, MaxSalesAmount_CaptLbl, MaxSalesAmount_DescLbl);
        WorkflowConfig.AddBooleanParameter('AddCommentLine', false, CommentLine_DescLbl, CommentLine_DescLbl);
        WorkflowConfig.AddBooleanParameter('ConfirmDialog', true, ConfirmDialog_DescLbl, ConfirmDialog_DescLbl);
        WorkflowConfig.AddTextParameter('GenBusPostingGroup', '', GenPostingGr_CaptLbl, GenPostingGr_DescLbl);
        WorkflowConfig.AddTextParameter('VATBusPostingGroup', '', VatBusPostingGr_CaptLbl, VatBusPostingGr_CaptLbl);

        WorkflowConfig.AddLabel('confirmTitle', ConfirmTitle);
        WorkflowConfig.AddLabel('confirmLead', StrSubstNo(ConfirmLead, VATBusinessPostingGroup.TableCaption));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSetSaleVAT.js###
'let main=async({workflow:a,parameters:n,popup:r,captions:i})=>{n.ConfirmDialog&&!await r.confirm({title:i.confirmTitle,caption:i.confirmLead})||await a.respond()};'
          );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        SetSaleVatB: Codeunit "NPR POS Action-Set Sale VAT-B.";
        AddCommentLine: Boolean;
        MaxSaleAmountLimit: Boolean;
        MinSaleAmountLimit: Boolean;
        MaxSaleAmount: Decimal;
        MinSaleAmount: Decimal;
        GenBusPostingGroup: Text;
        VATBusPostingGroup: Text;
    begin
        MinSaleAmountLimit := Context.GetBooleanParameter('MinimumSaleAmountLimit');
        MinSaleAmount := Context.GetDecimalParameter('MinimumSaleAmount');
        MaxSaleAmountLimit := Context.GetBooleanParameter('MaximumSaleAmountLimit');
        MaxSaleAmount := Context.GetDecimalParameter('MaximumSaleAmount');
        AddCommentLine := Context.GetBooleanParameter('AddCommentLine');
        GenBusPostingGroup := Context.GetStringParameter('GenBusPostingGroup');
        VATBusPostingGroup := Context.GetStringParameter('VATBusPostingGroup');

        SetSaleVatB.CheckLimits(Sale, MinSaleAmount, MinSaleAmountLimit, MaxSaleAmount, MaxSaleAmountLimit);
        SetSaleVatB.ChangeSaleVATBusPostingGroup(Sale, SaleLine, GenBusPostingGroup, VATBusPostingGroup, AddCommentLine);
    end;
}

