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

        EFTTransactionMgt.SendRequestIfSynchronous(EntryNo, IntegrationRequest, Mechanism);

        WorkflowRequest.Add('tryEndSale', (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]));
        WorkflowRequest.Add('workflowName', Workflow);
        WorkflowRequest.Add('legacy', false);
        WorkflowRequest.Add('integrationRequest', IntegrationRequest);
        if Mechanism = Mechanism::Synchronous then begin
            WorkflowRequest.Add('synchronousRequest', true);
            EFTTransactionRequest.Get(EntryNo);
            WorkflowRequest.Add('synchronousSuccess', EFTTransactionRequest.Successful);
        end;
        exit(WorkflowRequest);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTTrx.js###
'let main=async({workflow:t,runtime:d,context:s})=>{const e=await t.respond("PrepareEftRequest",{context:{suggestedAmount:s.suggestedAmount}}),{workflowName:n,integrationRequest:r,legacy:u,synchronousRequest:c,synchronousSuccess:a}=e;debugger;if(u)return{success:!0,legacy:!0};if(c)return{success:a,tryEndSale:e.tryEndSale};debugger;const{success:o,tryEndSale:g}=await t.run(n,{context:{request:r}});return{success:o,tryEndSale:e.tryEndSale&&g}};'
        );
    end;

    #region POS data driver extension
    local procedure DataSourceExtensionName(): Text
    begin
        exit('EFTRequest');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDiscoverDataSourceExtensions', '', false, false)]
    local procedure OnDiscover(DataSourceName: Text; Extensions: List of [Text])
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInPaymentLine() then
            exit;

        Extensions.Add(DataSourceExtensionName());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnGetDataSourceExtension', '', false, false)]
    local procedure OnGetExtension(DataSourceName: Text; ExtensionName: Text; var DataSource: Codeunit "NPR Data Source"; var Handled: Boolean; Setup: Codeunit "NPR POS Setup")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSDataMgt: Codeunit "NPR POS Data Management";
        DataType: Enum "NPR Data Type";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInPaymentLine() then
            exit;
        if ExtensionName <> DataSourceExtensionName() then
            exit;

        Handled := true;

        DataSource.AddColumn(EFTTransactionRequest.FieldName("Card Number"), EFTTransactionRequest.FieldCaption("Card Number"), DataType::String, false);
        DataSource.AddColumn(EFTTransactionRequest.FieldName("Authorisation Number"), EFTTransactionRequest.FieldCaption("Authorisation Number"), DataType::String, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Data Management", 'OnDataSourceExtensionReadData', '', false, false)]
    local procedure OnReadData(DataSourceName: Text; ExtensionName: Text; var RecRef: RecordRef; DataRow: Codeunit "NPR Data Row"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PaymentLinePOS: Record "NPR POS Sale Line";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        if DataSourceName <> POSDataMgt.POSDataSource_BuiltInPaymentLine() then
            exit;
        if ExtensionName <> DataSourceExtensionName() then
            exit;

        Handled := true;

        RecRef.SetTable(PaymentLinePOS);
        FindEftTransactionRequest(PaymentLinePOS, EFTTransactionRequest);
        DataRow.Fields().Add(EFTTransactionRequest.FieldName("Card Number"), EFTTransactionRequest."Card Number");
        DataRow.Fields().Add(EFTTransactionRequest.FieldName("Authorisation Number"), EFTTransactionRequest."Authorisation Number");
    end;

    local procedure FindEftTransactionRequest(PaymentLinePOS: Record "NPR POS Sale Line"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EftTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EftTransactionRequest.SetRange("Sales Ticket No.", PaymentLinePOS."Sales Ticket No.");
        EftTransactionRequest.SetRange("Sales Line No.", PaymentLinePOS."Line No.");
        if not EftTransactionRequest.FindFirst() then
            Clear(EftTransactionRequest);
    end;
    #endregion POS data driver extension
}
