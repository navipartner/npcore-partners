codeunit 6151430 "NPR POSAction SS TicketPickup" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action allows you to pickup tickets from web orders on a self service POS';
        ScannedValueTitle: Label 'Scanned Ticket Reference';
        ScannedValueDesc: Label 'This should contain the value of the scanned ticket when workflow is run';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetWorkflowTypeUnattended();
        WorkflowConfig.AddTextParameter('scannedValue', '', ScannedValueTitle, ScannedValueDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSActionTicketMgtB: Codeunit "NPR POS Action - Ticket Mgt B.";
        TicketReferenceNumber: Text[50];
    begin
        case Step of
            'printTickets':
                begin
                    TicketReferenceNumber := CopyStr(Context.GetStringParameter('scannedValue'), 1, MaxStrLen(TicketReferenceNumber));
                    POSActionTicketMgtB.PickupPreConfirmedTicket(TicketReferenceNumber, false, false, false);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSTicketPickup.js###
'let main=async({parameters:a})=>{await workflow.respond("printTickets",a.scannedValue)};'
        )
    end;
}
