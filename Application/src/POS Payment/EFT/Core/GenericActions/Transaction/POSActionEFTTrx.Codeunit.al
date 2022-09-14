codeunit 6184474 "NPR POS Action: EFT Trx" implements "NPR POS IPaymentWFHandler", "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'EFT Request Workflow';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
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

        if not TempEFTIntegrationType."Version 2" then begin
            //Fallback to payment v1 workflow
            WorkflowRequest.Add('legacy', true);
            exit(WorkflowRequest);
        end;

        EntryNo := EFTTransactionMgt.PreparePayment(EFTSetup, Context.GetDecimal('suggestedAmount'), '', SalePOS, IntegrationRequest, Mechanism, Workflow);
        EFTTransactionRequest.Get(EntryNo);
        IntegrationRequest.Add('EntryNo', EntryNo);

        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);

        WorkflowRequest.Add('tryEndSale', (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]));
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('legacy', false);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        exit(WorkflowRequest);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTTrx.js###
'let main=async({workflow:t,runtime:n,context:u})=>{const e=await t.respond("PrepareEftRequest",{context:{suggestedAmount:u.suggestedAmount}}),{workflowName:r,integrationRequest:s,legacy:c}=e;debugger;if(c)return{success:!0,legacy:!0};if(s.synchronousRequest)return{success:s.synchronousSuccess,tryEndSale:e.tryEndSale};n.suspendTimeout();debugger;const{success:a,tryEndSale:o}=await t.run(r,{context:{request:s}});return{success:a,tryEndSale:e.tryEndSale&&o}};'
        );
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR SS Action: Payment", 'OnGetPaymentHandler', '', false, false)]
    local procedure OnGetPaymentHandlerSelfService(POSPaymentMethod: Record "NPR POS Payment Method"; var PaymentHandler: Text; var ForceAmount: Decimal)
    begin
        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::EFT then
            exit;
        PaymentHandler := GetPaymentHandler();
    end;
}
