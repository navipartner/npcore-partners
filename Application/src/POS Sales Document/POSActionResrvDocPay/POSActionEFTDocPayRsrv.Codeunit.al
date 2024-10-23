codeunit 6184940 "NPR POSActionEFTDocPayRsrv" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Reserves a payment for a sales document';
        CaptionOpenDoc: Label 'Open Document';
        CaptionPOSPaymentMethodCode: Label 'POS Payment Method Code';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionVoucherTypeCode: Label 'Voucher Type';
        CaptionAskForVouchers: Label 'Ask for vouchers';
        CaptionAskForVoucherType: Label 'Ask for voucher type';
        CaptionEnableVoucherList: Label 'Open Voucher List';
        DescOpenDoc: Label 'Open the selected order before remaining amount is imported';
        DescPOSPaymentMethodCode: Label 'Select POS Payment Method Code to be used for sales document reservation';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescriptionAskForVouchers: Label 'Prompt for scanning a voucher';
        DescVoucherTypeCode: Label 'Specifies Voucher Type';
        DescAskForVoucherType: Label 'The system is going to ask for the voucher type before scanning';
        DescEnableVoucherList: Label 'Open Voucher List if Reference No. is blank';
        ScanVoucherRequestLbl: Label 'Do you want to scan a vocuher? Remaining amount: %1.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('POSPaymentMethodCode', '', CaptionPOSPaymentMethodCode, DescPOSPaymentMethodCode);
        WorkflowConfig.AddTextParameter('VoucherTypeCode', '', CaptionVoucherTypeCode, DescVoucherTypeCode);
        WorkflowConfig.AddBooleanParameter('OpenDocument', false, CaptionOpenDoc, DescOpenDoc);
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddBooleanParameter('AskForVouchers', true, CaptionAskForVouchers, DescriptionAskForVouchers);
        WorkflowConfig.AddBooleanParameter('AskForVoucherType', false, CaptionAskForVoucherType, DescAskForVoucherType);
        WorkflowConfig.AddBooleanParameter('EnableVoucherList', false, CaptionEnableVoucherList, DescEnableVoucherList);
        WorkflowConfig.AddLabel('ScanVoucherRequestCaption', ScanVoucherRequestLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'CreateDocumentReservationAmountSale':
                FrontEnd.WorkflowResponse(CreateDocumentReservationAmountSale(Context, Sale, PaymentLine));
            'ReserverPayment':
                FrontEnd.WorkflowResponse(ReserverPayment(Sale));
            'DeletePaymentLines':
                DeletePaymentLines();
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTDocPayRsrv.js###
'async function main({workflow:e,parameters:n,captions:r}){let t=0;const o=await e.respond("CreateDocumentReservationAmountSale");if(!o.success)return{};if(t=o.remainingAmount,n.AskForVouchers){let a=!0,s;for(;a;)a=await popup.confirm(r.ScanVoucherRequestCaption.replace("%1",t)),a&&(s=await e.run("SCAN_VOUCHER_2",{parameters:{AskForVoucherType:n.AskForVoucherType,VoucherTypeCode:n.VoucherTypeCode,EnableVoucherList:n.EnableVoucherList,EndSale:!1}}),s.success&&(a=s.remainingSalesBalanceAmount>0,t=s.remainingSalesBalanceAmount))}return t>0&&!(await e.run("PAYMENT_2",{parameters:{HideAmountDialog:!0,paymentNo:n.POSPaymentMethodCode,tryEndSale:!1}})).success?(await e.respond("DeletePaymentLines"),await e.run("CANCEL_POS_SALE",{parameters:{silent:!0}}),{}):e.respond("ReserverPayment",{salesDocumentID:o.salesDocumentID})}'
        );
    end;

    local procedure CreateDocumentReservationAmountSale(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line") Result: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
        POSActionDocExportB: Codeunit "NPR POS Action: Doc. ExportB";
        POSSession: Codeunit "NPR POS Session";
        POSPaymentMethodCodeText: Text;
        OpenDocument: Boolean;
        SelectCustomer: Boolean;
        Success: Boolean;
        RemainingAmount: Decimal;
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
        RemainingAmount := POSActionDocExportB.CalculateRemainingAmount(POSPaymentMethodCodeText, PaymentLine);
#pragma warning restore AA0139

        Result.Add('success', Success);
        Result.Add('remainingAmount', RemainingAmount);
    end;

    local procedure ReserverPayment(Sale: Codeunit "NPR POS Sale"): JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
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

    local procedure DeletePaymentLines()
    var
        POSActEFTDocPayRsrvB: Codeunit "NPR POSActionEFTDocPayRsrvB";
    begin
        POSActEFTDocPayRsrvB.DeletePaymentLines();
    end;
}
