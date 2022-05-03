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
            SelectStr(1, ParameterShow_OptionsLbl),
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
        ParameterShow: Option CustLedgerEntries,ItemLedgerEntries,CustomerCard;
        CustomerNo: Code[20];
    begin

        GetCustomerNo(Sale, CustomerNo);

        ParameterShow := Context.GetIntegerParameter(ParameterShow_Name());
        case ParameterShow of
            ParameterShow::CustLedgerEntries:
                ShowCLE(CustomerNo);
            ParameterShow::ItemLedgerEntries:
                ShowILE(CustomerNo);
            ParameterShow::CustomerCard:
                ShowCustomerCard(CustomerNo);
        end;

    end;

    local procedure ShowCLE(CustomerNo: code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if CustomerNo <> '' then begin
            CustLedgerEntry.FilterGroup(2);
            CustLedgerEntry.SetRange("Customer No.", CustomerNo);
            CustLedgerEntry.FilterGroup(0);
        end;
        PAGE.RUN(PAGE::"Customer Ledger Entries", CustLedgerEntry);
    end;

    local procedure ShowILE(CustomerNo: code[20]);
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if CustomerNo <> '' then begin
            ItemLedgerEntry.FilterGroup(2);
            ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Customer);
            ItemLedgerEntry.SetRange("Source No.", CustomerNo);
            ItemLedgerEntry.FilterGroup(0);
        end;
        PAGE.RUN(PAGE::"Item Ledger Entries", ItemLedgerEntry);
    end;

    local procedure ParameterShow_Name(): Text[30]
    begin
        exit('Show');
    end;

    local procedure GetCustomerNo(var Sale: Codeunit "NPR POS Sale"; var CustomerNo: Code[20])
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        CustomerNo := POSSale."Customer No."
    end;

    local procedure ShowCustomerCard(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        CustomerNotSelectedLbl: Label 'Customer is not selected!';
    begin
        if Customer.Get(CustomerNo) then
            PAGE.RUN(PAGE::"Customer Card", Customer)
        else
            Message(CustomerNotSelectedLbl);
    end;
}
