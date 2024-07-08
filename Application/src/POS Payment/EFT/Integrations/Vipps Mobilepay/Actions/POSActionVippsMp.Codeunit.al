codeunit 6184693 "NPR POS Action: Vipps Mp" implements "NPR IPOS Workflow"
{
    Access = Internal;
    SingleInstance = True;

    var
        _VippsMpTrxState: Enum "NPR Vipps Mp Trx State";
        _LblTitlePayment: Label 'Payment';
        _LblTitleRefund: Label 'Refund';
        _LblInitialStatus: Label 'Initializing Request';
        _LblWaitingCustomer: Label 'Waiting for customer...';
        _LblAborting: Label 'Aborting Request';
        _LblAborted: Label 'Aborted Request';
        _LblFoundCustomer: Label 'Customer connected to sale.';
        _LblCustomerPaying: Label 'Waiting for payment...';
        _LblReceivedPayment: Label 'Received payment, finalising request...';
        _LblReceivedREsponse: Label 'Received response: %1';
        _LblCreatingTransaction: Label 'Creating transaction...';
        _LblCreatedTransaction: Label 'Created transaction, waiting for customer...';
        _LblCaptureTransaction: Label 'Finalizing transaction...';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Workflow for Mp Vipps Integration';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('TitlePayment', _LblTitlePayment);
        WorkflowConfig.AddLabel('TitleRefund', _LblTitleRefund);
        WorkflowConfig.AddLabel('Aborting', _LblAborting);
        WorkflowConfig.AddLabel('InitialStatus', _LblInitialStatus);
        WorkflowConfig.AddLabel('WaitingCustomer', _LblWaitingCustomer);
        WorkflowConfig.AddLabel('FoundCustomer', _LblFoundCustomer);
        WorkflowConfig.AddLabel('CustomerPaying', _LblCustomerPaying);
        WorkflowConfig.AddLabel('ReceivedPayment', _LblReceivedPayment);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            //Set The state of the transaction flow, start waiting for the Customer to Scan QR Code.
            'BeginWaitCustomer':
                begin
                    FrontEnd.WorkflowResponse(BeginWaitCustomer(Context));
                end;
            //Polls the WebhookResponse Table for QR Scan.
            'WaitCustomerCheckin':
                begin
                    FrontEnd.WorkflowResponse(WaitCustomerCheckin(Setup.GetPOSUnitNo(), Context));
                end;
            //After QR has been scanned and result read, we create the transaction.
            'CreateTransaction':
                begin
                    FrontEnd.WorkflowResponse(CreateTransaction(Context));
                end;
            //Poll the response of the Creation Operation.
            'WaitCreateTransaction':
                begin
                    FrontEnd.WorkflowResponse(WaitCreateTransaction(Setup.GetPOSUnitNo(), Context));
                end;
            //Polls the WEbhookResponse Table for Payment made.
            'WaitCustomerPayment':
                begin
                    FrontEnd.WorkflowResponse(WaitCustomerPayment(Setup.GetPOSUnitNo(), Context));
                end;
            //After the payment is authorized, we capture the payment.
            'CaptureTransaction':
                begin
                    FrontEnd.WorkflowResponse(CaptureTransaction(Context));
                end;
            //Polls the response for the Capture Transaction.
            'WaitCaptureTransaction':
                begin
                    FrontEnd.WorkflowResponse(WaitCaptureTransaction(Setup.GetPOSUnitNo(), Context));
                end;
            //Aborts the Request.
            'Abort':
                begin
                    FrontEnd.WorkflowResponse(AbortTransaction(Context));
                end;
        end;
    end;

    local procedure BeginWaitCustomer(Context: codeunit "NPR POS JSON Helper"): JsonObject
    var
        VippsMpLog: Codeunit "NPR Vipps Mp Log";

    begin
        _VippsMpTrxState := _VippsMpTrxState::WAITING_CUSTOMER;
        VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, Context.GetInteger('EFTEntryNo'), Context.GetString('PaymentSetupCode'), 'BeginWaitCustomer', '');
        Context.SetContext('LastStatusDescription', _LblWaitingCustomer);
    end;

    local procedure WaitCustomerCheckin(POSUnitNo: Code[10]; Context: codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpWebhookMgt: Codeunit "NPR Vipps Mp Webhook Mgt.";
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg";
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        Token: Text;
        HasResult: Boolean;
    begin
        case _VippsMpTrxState of
            Enum::"NPR Vipps Mp Trx State"::WAITING_CUSTOMER:
                begin
                    VippsMpUnitSetup.Get(POSUnitNo);
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
                    VippsMpWebhookMsg.LockTable();
#ELSE
                    VippsMpWebhookMsg.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
                    if (not VippsMpWebhookMgt.GetLastUserCheckin(VippsMpUnitSetup, HasResult, Token, VippsMpWebhookMsg)) then begin
                        VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, Context.GetInteger('EFTEntryNo'), Context.GetString('PaymentSetupCode'), 'Error: QR Scanned', GetLastErrorText());
                        VippsMpResponseHandler.AbortRequestBeforeTrxCreated(EFTTransactionRequest);
                        Response.Add('Error', True);
                        Response.Add('ErrorMessage', GetLastErrorText());
                        exit(Response);
                    end;
                    if (HasResult) then begin
                        //We remove the message to do auto clean up now that we have the value.
                        VippsMpWebhookMsg.Delete();
                        VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, Context.GetInteger('EFTEntryNo'), Context.GetString('PaymentSetupCode'), 'QR Scanned', Token);
                        Context.SetContext('UserCheckedIn', True);
                        Context.SetContext('CustomerToken', Token);
                        Context.SetContext('LastStatusDescription', _LblFoundCustomer);
                        Response.Add('Done', True);
                    end else begin
                        Context.SetContext('UserCheckedIn', False);
                    end;
                end;
            Enum::"NPR Vipps Mp Trx State"::ABORT_REQUESTED:
                begin
                    EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                    VippsMpResponseHandler.AbortRequestBeforeTrxCreated(EFTTransactionRequest);
                    VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, EFTTransactionRequest, 'Aborted', '');
                    _VippsMpTrxState := _VippsMpTrxState::ABORTED;
                    Context.SetContext('Success', false);
                    Context.SetContext('TryEndSale', false);
                    Context.SetContext('LastStatusDescription', _LblAborted);
                    Response.Add('UserCheckInAborted', true);
                    Response.Add('Done', True);
                end;
        end;
    end;

    local procedure CreateTransaction(Context: codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VippsMpePaymentAPI: Codeunit "NPR Vipps Mp ePayment API";
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        ResponseJson: JsonObject;
        ErrTraxCreateLbl: Label 'Error when creating transaction: %1';
    begin
        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::PAYMENT) then begin
            if (VippsMpePaymentAPI.CreatePayment_StaticQRFlow(EFTTransactionRequest, Context.GetString('CustomerToken'), ResponseJson)) then begin
                _VippsMpTrxState := _VippsMpTrxState::CREATING_TRX;
                Context.SetContext('LastStatusDescription', _LblCreatingTransaction);
                VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, EFTTransactionRequest, 'Create Payment Transaction', ResponseJson);
            end else begin
                _VippsMpTrxState := _VippsMpTrxState::ERROR;
                VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, EFTTransactionRequest, 'Failed Payment Transaction', ResponseJson);
                Response.Add('Error', True);
                Response.Add('ErrorMessage', StrSubstNo(ErrTraxCreateLbl, GetLastErrorText()));
            end;
            exit;
        end;
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::REFUND) then begin
            if (VippsMpePaymentAPI.RefundPayment(EFTTransactionRequest, ResponseJson)) then begin
                _VippsMpTrxState := _VippsMpTrxState::CREATING_TRX;
                Context.SetContext('LastStatusDescription', _LblCreatingTransaction);
                Response.Add('CreatedRefund', True);
                VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, EFTTransactionRequest, 'Refund Transaction', ResponseJson);
            end else begin
                _VippsMpTrxState := _VippsMpTrxState::ERROR;
                VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, EFTTransactionRequest, 'Failed Refund Transaction', ResponseJson);
                Response.Add('Error', True);
                Response.Add('ErrorMessage', StrSubstNo(ErrTraxCreateLbl, GetLastErrorText()));
            end;
            exit;
        end;
    end;

    local procedure WaitCreateTransaction(POSUnitNo: Code[10]; Context: codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg";
        VippsMpWebhookMgt: Codeunit "NPR Vipps Mp Webhook Mgt.";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        VippsMpWebhookEvents: Enum "NPR Vipps Mp WebhookEvents";
        HasResult: Boolean;
        WebhookContent: JsonObject;
    begin
        VippsMpUnitSetup.Get(POSUnitNo);
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        VippsMpWebhookMsg.LockTable();
#ELSE
        VippsMpWebhookMsg.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
        if (not VippsMpWebhookMgt.GetNextPaymentWebhook(VippsMpUnitSetup, Context.GetString('ReferenceNumberInput'), HasResult, WebhookContent, VippsMpWebhookMsg)) then begin
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, Context.GetInteger('EFTEntryNo'), Context.GetString('PaymentSetupCode'), 'Error: Wait Create Trx', GetLastErrorText());
            Response.Add('Error', True);
            Response.Add('ErrorMessage', GetLastErrorText());
            exit;
        end;
        if (HasResult) then begin
            VippsMpWebhookMsg.Delete();
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, Context.GetInteger('EFTEntryNo'), Context.GetString('PaymentSetupCode'), 'Wait Create Trx', WebhookContent);
            GetPaymentEventType(WebhookContent, VippsMpWebhookEvents);
            case VippsMpWebhookEvents of
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_CREATED:
                    begin
                        _VippsMpTrxState := _VippsMpTrxState::WAITING_AUTHORIZED;
                        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                        VippsMpResponseHandler.HandleCreatedResponse(EFTTransactionRequest, WebhookContent);
                        Context.SetContext('LastStatusDescription', _LblCreatedTransaction);
                        Response.Add('Done', True);
                    end;
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_REFUNDED:
                    begin
                        _VippsMpTrxState := _VippsMpTrxState::COMPLETED;
                        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                        VippsMpResponseHandler.HandleRefundResponse(EFTTransactionRequest, WebhookContent);
                        Response.Add('Done', True);
                        Context.SetContext('Success', true);
                        Context.SetContext('TryEndSale', true);
                    end;
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_CANCELLED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_EXPIRED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_TERMINATED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_ABORTED:
                    begin
                        _VippsMpTrxState := _VippsMpTrxState::COMPLETED;
                        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                        VippsMpResponseHandler.HandleUnsuccessfulTransaction(EFTTransactionRequest, WebhookContent);
                        Response.Add('Done', True);
                        Context.SetContext('Success', false);
                        Context.SetContext('TryEndSale', false);
                    end;
            end;
        end;
    end;

    local procedure WaitCustomerPayment(POSUnitNo: Code[10]; Context: codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg";
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpWebhookMgt: Codeunit "NPR Vipps Mp Webhook Mgt.";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        VippsMpWebhookEvents: Enum "NPR Vipps Mp WebhookEvents";
        WebhookContent: JsonObject;
        HasResult: Boolean;
    begin
        VippsMpUnitSetup.Get(POSUnitNo);
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        VippsMpWebhookMsg.LockTable();
#ELSE
        VippsMpWebhookMsg.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
        if (not VippsMpWebhookMgt.GetNextPaymentWebhook(VippsMpUnitSetup, Context.GetString('ReferenceNumberInput'), HasResult, WebhookContent, VippsMpWebhookMsg)) then begin
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, Context.GetInteger('EFTEntryNo'), Context.GetString('PaymentSetupCode'), 'Error: Wait Customer Payment', GetLastErrorText());
            Response.Add('Error', True);
            Response.Add('ErrorMessage', GetLastErrorText());
            exit;
        end;
        if (HasResult) then begin
            VippsMpWebhookMsg.Delete();
            GetPaymentEventType(WebhookContent, VippsMpWebhookEvents);
            case VippsMpWebhookEvents of
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_AUTHORIZED:
                    begin
                        _VippsMpTrxState := _VippsMpTrxState::AUTHORIZED;
                        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                        VippsMpResponseHandler.HandleAuthorizedResponse(EFTTransactionRequest, WebhookContent);
                        Response.Add('CaptureTransaction', True);
                    end;
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_TERMINATED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_ABORTED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_EXPIRED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_CANCELLED:
                    begin
                        _VippsMpTrxState := _VippsMpTrxState::COMPLETED;
                        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                        VippsMpResponseHandler.HandleUnsuccessfulTransaction(EFTTransactionRequest, WebhookContent);
                        Context.SetContext('Success', false);
                        Context.SetContext('TryEndSale', false);
                    end;
            end;
            Context.SetContext('LastStatusDescription', StrSubstNo(_LblReceivedREsponse, Format(VippsMpWebhookEvents).Replace('EPAYMENT_', '')));
            Response.Add('Done', True);
        end;
    end;

    local procedure CaptureTransaction(Context: codeunit "NPR POS JSON Helper"): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VippsMpePaymentAPI: Codeunit "NPR Vipps Mp ePayment API";
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        ResponseJson: JsonObject;
        Response: Text;
    begin
        _VippsMpTrxState := _VippsMpTrxState::WAITING_CAPTURE;
        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
        VippsMpePaymentAPI.CapturePayment(EFTTransactionRequest, ResponseJson);
        ResponseJson.WriteTo(Response);
        VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::All, Context.GetInteger('EFTEntryNo'), Context.GetString('PaymentSetupCode'), 'Capturing Transaction', Response);
        Context.SetContext('LastStatusDescription', _LblCaptureTransaction);
    end;

    local procedure WaitCaptureTransaction(POSUnitNo: Code[10]; Context: codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg";
        VippsMpUnitSetup: Record "NPR Vipps Mp Unit Setup";
        VippsMpWebhookMgt: Codeunit "NPR Vipps Mp Webhook Mgt.";
        VippsMpResponseHandler: Codeunit "NPR Vipps Mp Response Handler";
        VippsMpLog: Codeunit "NPR Vipps Mp Log";
        VippsMpWebhookEvents: Enum "NPR Vipps Mp WebhookEvents";
        WebhookContent: JsonObject;
        HasResult: Boolean;
    begin
        VippsMpUnitSetup.Get(POSUnitNo);
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        VippsMpWebhookMsg.LockTable();
#ELSE
        VippsMpWebhookMsg.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
        if (not VippsMpWebhookMgt.GetNextPaymentWebhook(VippsMpUnitSetup, Context.GetString('ReferenceNumberInput'), HasResult, WebhookContent, VippsMpWebhookMsg)) then begin
            VippsMpLog.Log(Enum::"NPR Vipps Mp Log Lvl"::Error, Context.GetInteger('EFTEntryNo'), Context.GetString('PaymentSetupCode'), 'Error: Wait Capture Payment', GetLastErrorText());
            Response.Add('Error', True);
            Response.Add('ErrorMessage', GetLastErrorText());
        end;
        if (HasResult) then begin
            VippsMpWebhookMsg.Delete();
            GetPaymentEventType(WebhookContent, VippsMpWebhookEvents);
            case VippsMpWebhookEvents of
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_CAPTURED:
                    begin
                        _VippsMpTrxState := _VippsMpTrxState::COMPLETED;
                        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                        VippsMpResponseHandler.HandleCapturedResponse(EFTTransactionRequest, WebhookContent);
                        Context.SetContext('LastStatusDescription', 'Got payment');
                        Context.SetContext('Success', True);
                        Context.SetContext('TryEndSale', True);
                    end;
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_TERMINATED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_ABORTED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_EXPIRED,
                Enum::"NPR Vipps Mp WebhookEvents"::EPAYMENT_CANCELLED:
                    begin
                        _VippsMpTrxState := _VippsMpTrxState::COMPLETED;
                        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                        VippsMpResponseHandler.HandleUnsuccessfulTransaction(EFTTransactionRequest, WebhookContent);
                        Response.Add('Done', True);
                        Context.SetContext('Success', false);
                        Context.SetContext('TryEndSale', false);
                    end;
            end;
            Response.Add('Done', True);
        end;
    end;

    local procedure GetPaymentEventType(JsonContent: JsonObject; var EPaymentEvent: Enum "NPR Vipps Mp WebhookEvents")
    var
        Token: JsonToken;
        VippsMpUtil: Codeunit "NPR Vipps Mp Util";
    begin
        JsonContent.Get('name', Token);
        VippsMpUtil.PaymentWebhookEventNameToEnum(Token.AsValue().AsText(), EPaymentEvent);
    end;

    local procedure AbortTransaction(Context: codeunit "NPR POS JSON Helper"): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VippsMpePaymentAPI: Codeunit "NPR Vipps Mp ePayment API";
        CancelResponse: JsonObject;
    begin
        case _VippsMpTrxState of
            Enum::"NPR Vipps Mp Trx State"::WAITING_CUSTOMER:
                begin
                    _VippsMpTrxState := _VippsMpTrxState::ABORT_REQUESTED;
                end;
            Enum::"NPR Vipps Mp Trx State"::AUTHORIZED,
            Enum::"NPR Vipps Mp Trx State"::CREATING_TRX,
            Enum::"NPR Vipps Mp Trx State"::WAITING_AUTHORIZED,
            Enum::"NPR Vipps Mp Trx State"::WAITING_CAPTURE:
                begin
                    EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
                    if (VippsMpePaymentAPI.CancelPayment(EFTTransactionRequest, CancelResponse)) then begin
                        _VippsMpTrxState := _VippsMpTrxState::ABORT_REQUESTED;
                    end;
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionVippsMp.Codeunit.js###
'let main=async u=>{let{workflow:e,context:t,popup:n,captions:o}=u;t.EFTEntryNo=t.request.EFTEntryNo,t.PaymentSetupCode=t.request.PaymentSetupCode,t.Type=t.request.Type.toUpperCase(),t.ReferenceNumberInput=t.request.ReferenceNumberInput,t.LastStatusDescription=o.InitialStatus,t.Success=!1,t.TryEndSale=!1;let a="";switch(t.Type){case"PAYMENT":a=o.TitlePayment;break;case"REFUND":a=o.TitleRefund;break}let r=await n.mobilePay({title:a,initialStatus:t.LastStatusDescription,showStatus:!0,amount:t.request.FormattedAmount,qr:{value:t.request.QrContent},onAbort:async()=>{r.updateStatus(o.Aborting),await e.respond("Abort")}});try{let s=async c=>{let l=await e.respond(c);if(l.Error)throw Error(l.ErrorMessage);return l},i={};if(r.enableAbort(!0),t.Type==="PAYMENT"){if(t.request.QrOnCustomerDisplay)try{await e.run("HTML_DISPLAY_QR",{context:{IsNestedWorkflow:!0,QrShow:!0,QrTitle:"MobilePay",QrMessage:t.request.FormattedAmount,QrContent:t.request.QrContent}})}catch(c){console.error("Could not display Qr code on Customer Display: "+c)}await s("BeginWaitCustomer"),r.updateStatus(t.LastStatusDescription),i=await PollPromise("WaitCustomerCheckin",e),r.updateStatus(t.LastStatusDescription)}i.UserCheckInAborted||(await s("CreateTransaction"),r.updateStatus(t.LastStatusDescription),await PollPromise("WaitCreateTransaction",e),r.updateStatus(t.LastStatusDescription),t.Type==="PAYMENT"&&(i=await PollPromise("WaitCustomerPayment",e),r.updateStatus(t.LastStatusDescription),i.CaptureTransaction&&(await s("CaptureTransaction"),r.updateStatus(t.LastStatusDescription),await PollPromise("WaitCaptureTransaction",e),r.updateStatus(t.LastStatusDescription))))}catch(s){console.error("Vipps Mobilepay Error"),console.error(s);let i=s.message?s.message:s;n.error(i,"Vipps Mobilepay Error"),await e.respond("Abort")}finally{if(r&&r.close(),t.request.QrOnCustomerDisplay)try{await e.run("HTML_DISPLAY_QR",{context:{IsNestedWorkflow:!0,QrShow:!1,QrTitle:"MobilePay"}})}catch(s){console.error("Could not close qr on customer display: "+s)}}return{success:t.Success,tryEndSale:t.TryEndSale}};function PollPromise(u,e){return new Promise((t,n)=>{let o=async()=>{try{let a=await e.respond(u);if(a.Done){t(a);return}if(a.Error){n(a.ErrorMessage);return}}catch(a){await e.respond("Abort"),n(a);return}setTimeout(o,1e3)};setTimeout(o,1e3)})}'
        );
    end;
}
