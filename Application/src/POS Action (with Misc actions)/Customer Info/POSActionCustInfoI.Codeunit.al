codeunit 6150801 "NPR POS Action: Cust.Info-I" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for displaying customer related transactions.';
        ParameterShow_NameCaptionLbl: Label 'Show';
        ParameterShow_NameDescriptionLbl: Label 'Specifies the type of customer related data you want to display.';
        ParameterShow_OptionsLbl: Label 'CustLedgerEntries,ItemLedgerEntries,CustomerCard', Locked = true;
        ParameterShow_OptionCaptionsLbl: Label 'Customer Ledger Entries,Customer Item Ledger Entries,Customer Card';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            ParameterShow_Name(),
            ParameterShow_OptionsLbl,
#pragma warning disable AA0139
            SelectStr(1, ParameterShow_OptionsLbl),
#pragma warning restore 
            ParameterShow_NameCaptionLbl,
            ParameterShow_NameDescriptionLbl,
            ParameterShow_OptionCaptionsLbl
        );
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionCustInfo.js###
'let main=async({})=>await workflow.respond();'
        )
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogic: Codeunit "NPR POS Action: Cust.Info-I B";
        ParameterShow: Option CustLedgerEntries,ItemLedgerEntries,CustomerCard;
        CustomerNo: Code[20];
    begin
        BusinessLogic.GetCustomerNo(Sale, CustomerNo);

        ParameterShow := Context.GetIntegerParameter(ParameterShow_Name());
        case ParameterShow of
            ParameterShow::CustLedgerEntries:
                BusinessLogic.ShowCLE(CustomerNo);
            ParameterShow::ItemLedgerEntries:
                BusinessLogic.ShowILE(CustomerNo);
            ParameterShow::CustomerCard:
                BusinessLogic.ShowCustomerCard(CustomerNo);
        end;

    end;

    local procedure ParameterShow_Name(): Text[30]
    begin
        exit('Show');
    end;
}
