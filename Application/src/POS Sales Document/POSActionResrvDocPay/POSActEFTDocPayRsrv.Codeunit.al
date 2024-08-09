codeunit 6184940 "NPR POS Act EFT Doc Pay Rsrv" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Reserves a payment for a sales document';
        CaptionOpenDoc: Label 'Open Document';
        CaptionPOSPaymentMethodCode: Label 'POS Payment Method Code';
        CaptionSelectCustomer: Label 'Select Customer';
        DescOpenDoc: Label 'Open the selected order before remaining amount is imported';
        DescPOSPaymentMethodCode: Label 'Select POS Payment Method Code to be used for sales document reservation';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('POSPaymentMethodCode', '', CaptionPOSPaymentMethodCode, DescPOSPaymentMethodCode);
        WorkflowConfig.AddBooleanParameter('OpenDocument', false, CaptionOpenDoc, DescOpenDoc);
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, CaptionSelectCustomer, DescSelectCustomer);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'CreateDocumentReservationAmountSale':
                FrontEnd.WorkflowResponse(CreateDocumentReservationAmountSale(Context, Sale));
            'ReserverPayment':
                FrontEnd.WorkflowResponse(ReserverPayment(Sale));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActEFTDocPayRsrv.js###
'async function main({workflow:e,parameters:n}){const t=await e.respond("CreateDocumentReservationAmountSale");if(!t.success)return;if(!(await e.run("PAYMENT_2",{parameters:{HideAmountDialog:!0,paymentNo:n.POSPaymentMethodCode,tryEndSale:!1}})).success){await e.run("CANCEL_POS_SALE",{parameters:{silent:!0}});return}return await e.respond("ReserverPayment",{salesDocumentID:t.salesDocumentID})}'
        );
    end;

    local procedure CreateDocumentReservationAmountSale(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Result: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSActEFTDocPayRsrvB: Codeunit "NPR POS Act EFT Doc Pay Rsrv B";
        POSSession: Codeunit "NPR POS Session";
        POSPaymentMethodCodeText: Text;
        OpenDocument: Boolean;
        SelectCustomer: Boolean;
        Success: Boolean;
    begin
        Sale.GetCurrentSale(SalePOS);

        SelectCustomer := Context.GetBooleanParameter('SelectCustomer');
        OpenDocument := Context.GetBooleanParameter('OpenDocument');

        if not Context.GetStringParameter('POSPaymentMethodCode', POSPaymentMethodCodeText) then
            Clear(POSPaymentMethodCodeText);
#pragma warning disable AA0139
        POSActEFTDocPayRsrvB.CheckPOSEFTPaymentReservationSetup();
        POSActEFTDocPayRsrvB.ValidatePOSSale(SalePOS, POSPaymentMethodCodeText);
#pragma warning restore AA0139

        if not POSActEFTDocPayRsrvB.CheckCustomer(SalePOS, Sale, SelectCustomer) then
            exit;

        if not POSActEFTDocPayRsrvB.SelectDocument(SalePOS, SalesHeader) then
            exit;

        Success := POSActEFTDocPayRsrvB.ConfirmDocument(SalesHeader, OpenDocument);
        if Success then
#pragma warning disable AA0139
            POSActEFTDocPayRsrvB.CreateDocumentReservationAmountSalesLine(POSSession, SalePOS, SalesHeader, POSPaymentMethodCodeText);
#pragma warning restore AA0139
        Result.Add('success', Success);
    end;

    local procedure ReserverPayment(Sale: Codeunit "NPR POS Sale"): JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        POSActEFTDocPayRsrvB: Codeunit "NPR POS Act EFT Doc Pay Rsrv B";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        Sale.GetCurrentSale(SalePOS);

        if not POSActEFTDocPayRsrvB.GetSalesHeaderFromPOSSale(SalePOS, SalesHeader) then
            exit;

        POSActEFTDocPayRsrvB.CreateDocumentPaymentReservationLines(SalePOS);

        POSCreateEntry.CreatePOSEntryForCreatedSalesDocument(SalePOS, SalesHeader, false, false, SalesHeader."Print Posted Documents", false, false);

        SaleLinePOS.DeleteAll();
        SalePOS.Delete();
        Sale.SetEnded(true);
        Commit();

        Sale.SelectViewForEndOfSale();
    end;
}
