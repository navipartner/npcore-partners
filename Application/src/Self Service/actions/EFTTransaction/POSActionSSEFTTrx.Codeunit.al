codeunit 6151481 "NPR POS Action: SS EFT Trx" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Unattended EFT Request Workflow';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;


    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'PrepareEftRequest':
                FrontEnd.WorkflowResponse(PrepareRequest(Context, Sale));
        end;
    end;

    procedure GetPaymentHandler(): Code[20];
    begin
        exit(Format(Enum::"NPR POS Workflow"::EFT_PAYMENT));
    end;

    local procedure PrepareRequest(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") WorkflowRequest: JsonObject
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        SalePOS: Record "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        EntryNo: Integer;
        Workflow: Text;
        EFTInterface: Codeunit "NPR EFT Interface";
        TempEFTIntegrationType: Record "NPR EFT Integration Type" temporary;
    begin
        POSSale.GetCurrentSale(SalePOS);
        POSPaymentMethod.Get(Context.GetString('paymentType'));
        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);

        EFTInterface.OnDiscoverIntegrations(TempEFTIntegrationType);
        TempEFTIntegrationType.SetRange(Code, EFTSetup."EFT Integration Type");
        TempEFTIntegrationType.FindFirst();

        EntryNo := EFTTransactionMgt.PreparePayment(EFTSetup, Context.GetDecimal('amount'), '', SalePOS, IntegrationRequest, Mechanism, Workflow);
        EFTTransactionRequest.Get(EntryNo);

        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);

        WorkflowRequest.Add('tryEndSale', (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]));
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        exit(WorkflowRequest);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSEFTTrx.js###
'let main=async({workflow:t,context:n})=>{const e=await t.respond("PrepareEftRequest",{context:{amount:n.amount}}),{workflowName:s,integrationRequest:a}=e,{success:r,tryEndSale:c}=await t.run(s,{context:{request:a}});return{success:r,tryEndSale:e.tryEndSale&&c}};'
        );
    end;
}
