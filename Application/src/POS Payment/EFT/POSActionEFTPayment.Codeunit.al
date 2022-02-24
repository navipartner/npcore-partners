codeunit 6184474 "NPR POS Action: EFT Payment" implements "NPR POS IPaymentWFHandler", "NPR IPOS Workflow"
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

    local procedure PrepareRequest(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale") HwcRequest: JsonObject
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        SalePOS: Record "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        IntegrationWorkflow: Text;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSAction: Record "NPR POS Action";
        WorkflowVersion: Integer;
        EftJsonRequest: JsonObject;
    begin
        POSSale.GetCurrentSale(SalePOS);
        POSPaymentMethod.Get(Context.GetString('paymentType'));
        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);

        EFTTransactionMgt.PreparePayment(EFTSetup, Context.GetDecimal('suggestedAmount'), '', SalePOS, IntegrationWorkflow, EftJsonRequest);

        POSAction.Init();
        if (IntegrationWorkflow <> '') then
            POSAction.Get(IntegrationWorkflow);

        // WorkflowVersion is used to determine processing flow in front-end. 
        // 1: is Legacy, this WF will terminate, the invoking WF will fall back to legacy payment workflow.
        // >= 2: the specific EFT WF (workflowName) is invoked, the invoking WF will attempt to end sale.
        WorkflowVersion := 3;
        if (POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY) then
            WorkflowVersion := 1;

        HwcRequest.ReadFrom('{}');
        HwcRequest.Add('workflowName', IntegrationWorkflow);
        HwcRequest.Add('workflowVersion', WorkflowVersion);
        if (POSAction."Workflow Implementation" = POSAction."Workflow Implementation"::LEGACY) then
            exit(HwcRequest); // Legacy payment workflow

        if (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
            HwcRequest.Add('endSale', true)
        else
            HwcRequest.Add('endSale', false); //we might recover last instead of paying.

        HwcRequest.Add('hwcRequest', EftJsonRequest);
        exit(HwcRequest);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTPayment.Codeunit.js###
'let main=async({workflow:t,runtime:u,context:c})=>{const o=await t.respond("PrepareEftRequest",{context:{suggestedAmount:c.suggestedAmount}}),{workflowName:r,workflowVersion:e,hwcRequest:n}=o;if(e<=2)return{success:!0,version:e};u.suspendTimeout();let s={success:!1,endSale:!1,version:e};if(n.entryNo!=0){const{success:a,endSale:i}=await t.run(r,{context:{hwcRequest:n}});s.success=a,s.endSale=i}return s};'
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
