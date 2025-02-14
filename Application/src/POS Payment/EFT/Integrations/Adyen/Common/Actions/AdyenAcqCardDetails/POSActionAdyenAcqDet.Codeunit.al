codeunit 6248232 "NPR POS Action Adyen AcqDet" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'This action uses an Adyen terminal to acquire details about a card.';
        PaymentTypeNameLbl: Label 'Payment Type';
        PaymentTypeDescLbl: Label 'Defines the payment type which will be used for the configuration for the terminal.';
        ShowSpinnerNameLbl: Label 'Show Spinner';
        ShowSpinnerDescLbl: Label 'Defines if a spinner dialog should be shown while the terminal is performing the transaction.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('paymentType', '', PaymentTypeNameLbl, PaymentTypeDescLbl);
        WorkflowConfig.AddBooleanParameter('showSpinner', true, ShowSpinnerNameLbl, ShowSpinnerDescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        EFTSetup: Record "NPR EFT Setup";
        POSSale: Record "NPR POS Sale";
        PaymentType: Code[10];
        EntryNo: Integer;
        OnlyAdyenSupportedErr: Label 'Currently, only Adyen terminals are supported for this action. The found method was "%1"', Comment = '%1 = the found eft integration type';
    begin
        case Step of
            'prepareAcquireCard':
                begin
#pragma warning disable AA0139
                    PaymentType := Context.GetStringParameter('paymentType');
#pragma warning restore AA0139
                    if (PaymentType = '') then
                        Error('Missing required parameter: paymentType');

                    EFTSetup.FindSetup(Setup.GetPOSUnitNo(), PaymentType);
                    if (StrPos(EFTSetup."EFT Integration Type", 'ADYEN') = 0) then
                        Error(OnlyAdyenSupportedErr, EFTSetup."EFT Integration Type");

                    Sale.GetCurrentSale(POSSale);

                    FrontEnd.WorkflowResponse(AcquireCard(EFTSetup, Setup.GetPOSUnitNo(), POSSale."Sales Ticket No.", Context.GetBooleanParameter('showSpinner')));
                end;
            'getCardDetails':
                begin
                    Context.SetScope('context');
                    EntryNo := Context.GetInteger('entryNo');
                    if (EntryNo <= 0) then
                        Error('entryNo cannot be 0 or less. This is a programming bug, contact system vendor.');

                    FrontEnd.WorkflowResponse(GetCardDetails(EntryNo));
                end;
            else
                Error('Unknown step "%1" was requested. This is a programming bug, contact system vendor.', Step);
        end;
    end;

    local procedure AcquireCard(EFTSetup: Record "NPR EFT Setup"; POSUnitNo: Code[10]; SalesReceiptNo: Code[20]; ShowSpinner: Boolean) WorkflowRequest: JsonObject
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
        EntryNo: Integer;
    begin
        EntryNo := EFTTransactionMgt.PrepareAuxOperation(EFTSetup, POSUnitNo, SalesReceiptNo, "NPR EFT Adyen Aux Operation"::ACQUIRE_CARD.AsInteger(), IntegrationRequest, Mechanism, Workflow);
        WorkflowRequest.Add('entryNo', EntryNo);
        WorkflowRequest.Add('showSpinner', ShowSpinner);
        WorkflowRequest.Add('showSuccessMessage', false);
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
    end;

    local procedure GetCardDetails(EntryNo: Integer) CardDetails: JsonObject
    var
        EFTTrasactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTrasactionRequest.Get(EntryNo);
        EFTTrasactionRequest.TestField(Successful);

        CardDetails.Add('maskedPan', EFTTrasactionRequest."Card Number");
        CardDetails.Add('parToken', EFTTrasactionRequest."Payment Account Reference");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
            //###NPR_INJECT_FROM_FILE:POSActionAdyenAcqCardDet.js###
            'let main=async({workflow:e})=>{const{entryNo:t,showSpinner:a,showSuccessMessage:n,workflowName:s,integrationRequest:r}=await e.respond("prepareAcquireCard");await e.run(s,{context:{request:r,showSpinner:a,showSuccessMessage:n}});const i=await e.respond("getCardDetails",{context:{entryNo:t}});debugger;return i};'
        );
    end;
}