codeunit 6150814 "NPR POS Action: Sal.Doc.Exp."
{
    // NPR5.32/ANEN /20170314  CASE 268218 POS Action for exporting from POS to NAV Sales Document (wraps around CU[Retail Sales Doc. Mgt.])
    // NPR5.32.10/BR   /20170523  CASE 277092 Added Parameters to overwrite data from POS Sale Line
    // NPR5.34/ANEN  /20170713  CASE 283669 Added parameter. SetAutoReserveSalesLine and support for it.
    // NPR5.40/THRO/20180326 CASE 302617 Added parameter SetSendPdf2Nav - Send posted document with pdf2nav
    // NPR5.45/THRO/20180823 CASE 313966 Added parameters AskExtDocNo and AskAttention
    // NPR5.45/THRO/20180823 CASE 325216 Added Document Type::Quote


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built in function for handling sales document export';
        Setup: Codeunit "NPR POS Setup";
        REMOVE: Codeunit "NPR Sales Doc. Exp. Mgt.";
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4, %5 or %6';
        ERRORDERTYPE: Label 'Wrong Order Type. Order Type is set to %1. It must be one of %2, %3, %4.';
        ERRCUSTNOTSET: Label 'Customer must be set before working with Sales Document.';
        ERRNOSALELINES: Label 'Sales lines are required to crease sales document.';
        TextExtDocNoLabel: Label 'Enter External Document No.:';
        TextAttentionLabel: Label 'Enter Attention:';

    local procedure ActionCode(): Text
    begin
        exit('CUSTSALEDOCEXP');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.45 [313966]
        exit('1.4');
        //+NPR5.45 [313966]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple) then begin

                //-NPR5.45 [313966]
                RegisterWorkflowStep('extdocno', '(param.AskExtDocNo) && input (labels.ExtDocNo).cancel (abort);');
                RegisterWorkflowStep('attention', '(param.AskAttention) && input (labels.Attention).cancel (abort);');
                //+NPR5.45 [313966]
                //RegisterWorkflowStep('setCustomer','if (param.SetCustomer == true) { respond(); }');
                RegisterWorkflowStep('startDocumentManager', 'respond();');
                //RegisterWorkflowStep('doneDocumentManager','');
                RegisterWorkflow(true);

                //Parameter for exteral workflow call
                RegisterBooleanParameter('SetCustomer', false);

                //Reset
                RegisterBooleanParameter('Reset', false);

                //Parameters for SET
                RegisterBooleanParameter('SetAsk', false);
                RegisterBooleanParameter('SetPrint', false);
                RegisterBooleanParameter('SetInvoice', false);
                RegisterBooleanParameter('SetPost', false);
                RegisterBooleanParameter('SetReceive', false);
                RegisterBooleanParameter('SetShip', false);
                //-NPR5.45 [325216]
                RegisterOptionParameter('SetDocumentType', 'Order,Invoice,ReturnOrder,CreditMemo,Quote', 'Order');
                //+NPR5.45 [325216]
                RegisterOptionParameter('SetOrderType', 'NotSet,Order,Lending', 'NotSet');
                RegisterBooleanParameter('SetWriteInAuditRoll', false);
                RegisterBooleanParameter('SetShowCreationMessage', false);
                RegisterBooleanParameter('SetFinishSale', false);
                RegisterBooleanParameter('SetShowDepositDialog', false);

                RegisterDecimalParameter('SetReturnAmountPercentage', 100);
                RegisterIntegerParameter('SetOutputCodeunit', 0);

                //-NPR5.32.10 [277092]
                RegisterBooleanParameter('SetTransferSalesperson', false);
                RegisterBooleanParameter('SetTransferPostingSetup', true);
                RegisterBooleanParameter('SetTransferDimensions', false);
                RegisterBooleanParameter('SetTransferPaymentMethod', false);
                RegisterBooleanParameter('SetTransferTaxSetup', false);
                RegisterBooleanParameter('SetTransferTransactiondata', false);
                //+NPR5.32.10 [277092]

                RegisterBooleanParameter('InitNewSaleOnDone', false);
                //Do parameters
                RegisterBooleanParameter('TestSalePOS', false);
                RegisterBooleanParameter('ProcessPOSSale', false);
                RegisterBooleanParameter('OpenSalesDoc', false);
                //-NPR5.34 [283669]
                RegisterBooleanParameter('SetAutoReserveSalesLine', false);
                //+NPR5.34 [283669]
                //-NPR5.40 [302617]
                RegisterBooleanParameter('SetSendPdf2Nav', false);
                //+NPR5.40 [302617]
                //-NPR5.45 [313966]
                RegisterBooleanParameter('AskExtDocNo', false);
                RegisterBooleanParameter('AskAttention', false);
                //+NPR5.45 [313966]

            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        //-NPR5.45 [313966]
        Captions.AddActionCaption(ActionCode, 'ExtDocNo', TextExtDocNoLabel);
        Captions.AddActionCaption(ActionCode, 'Attention', TextAttentionLabel);
        //+NPR5.45 [313966]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;


        case WorkflowStep of
            //'setCustomer' : OnSetCustomer(Context, POSSession,FrontEnd);
            'startDocumentManager':
                OnStartDocumentManager(Context, POSSession, FrontEnd);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        JSON: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;


        Handled := true;
    end;

    local procedure "--"()
    begin
    end;

    local procedure OnSetCustomer(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSActionReceivables: Codeunit "NPR POS Action: Receivables";
    begin
        //POSActionReceivables.SelectCustomerWorkFlow(Context, POSSession, FrontEnd);
    end;

    local procedure OnStartDocumentManager(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        ResultProcessPOSSale: Boolean;
        SetDocumentType: Option "Order",Invoice,ReturnOrder,CreditMemo,Quote;
        SetOrderType: Option NotSet,"Order",Lending;
        Register: Record "NPR Register";
        POSActionReceivables: Codeunit "NPR POS Action: Receivables";
        Customer: Record Customer;
    begin

        //FrontEnd.PauseWorkflow;

        //Handling the wrap-connect to [Retail Sales Doc. Mgt.]
        POSSession.GetSetup(Setup);
        Setup.GetRegisterRecord(Register);

        //MESSAGE(FORMAT(Register));
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);



        if not SaleLinesExists(SalePOS) then Error(ERRNOSALELINES);
        //-NPR5.45 [313966]
        JSON.InitializeJObjectParser(Context, FrontEnd);
        SetReference(SalePOS, GetInput(JSON, 'extdocno'), GetInput(JSON, 'attention'));
        //+NPR5.45 [313966]

        //Collect parameter and set to [Retail Sales Doc. Mgt.]
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScope('parameters', true);

        //Set customer
        if JSON.GetBoolean('SetCustomer', true) then begin
            //POSActionReceivables.SelectCustomerWorkFlow(Context, POSSession, FrontEnd);
            if (ACTION::LookupOK = PAGE.RunModal(0, Customer)) then SalePOS."Customer No." := Customer."No.";
        end;

        if (SalePOS."Customer No." = '') then Error(ERRCUSTNOTSET);

        //Reset
        if JSON.GetBoolean('Reset', true) then RetailSalesDocMgt.Reset();

        //SET
        RetailSalesDocMgt.SetAsk(JSON.GetBoolean('SetAsk', true));
        RetailSalesDocMgt.SetPrint(JSON.GetBoolean('SetPrint', true));
        RetailSalesDocMgt.SetInvoice(JSON.GetBoolean('SetInvoice', true));
        RetailSalesDocMgt.SetPost(JSON.GetBoolean('SetPost', true));
        RetailSalesDocMgt.SetReceive(JSON.GetBoolean('SetReceive', true));
        RetailSalesDocMgt.SetShip(JSON.GetBoolean('SetShip', true));
        //-NPR5.40 [302617]
        RetailSalesDocMgt.SetSendPostedPdf2Nav(JSON.GetBoolean('SetSendPdf2Nav', true));
        //+NPR5.40 [302617]

        //-NPR5.34 [283669]
        RetailSalesDocMgt.SetAutoReserveSalesLine(JSON.GetBoolean('SetAutoReserveSalesLine', true));
        //+NPR5.34 [283669]

        //-NPR5.32.10 [277092]
        RetailSalesDocMgt.SetTransferSalesPerson(JSON.GetBoolean('SetTransferSalesperson', true));
        RetailSalesDocMgt.SetTransferPostingsetup(JSON.GetBoolean('SetTransferPostingSetup', true));
        RetailSalesDocMgt.SetTransferDimensions(JSON.GetBoolean('SetTransferDimensions', true));
        RetailSalesDocMgt.SetTransferPaymentMethod(JSON.GetBoolean('SetTransferPaymentMethod', true));
        RetailSalesDocMgt.SetTransferTaxSetup(JSON.GetBoolean('SetTransferTaxSetup', true));
        RetailSalesDocMgt.SetTransferTransactionData(JSON.GetBoolean('SetTransferTransactiondata', true));
        //+NPR5.32.10 [277092]



        SetDocumentType := JSON.GetIntegerParameter('SetDocumentType', true);
        case SetDocumentType of
            SetDocumentType::Order:
                begin
                    RetailSalesDocMgt.SetDocumentTypeOrder();
                end;
            SetDocumentType::Invoice:
                begin
                    RetailSalesDocMgt.SetDocumentTypeInvoice();
                end;
            SetDocumentType::CreditMemo:
                begin
                    RetailSalesDocMgt.SetDocumentTypeCreditMemo();
                end;
            SetDocumentType::ReturnOrder:
                begin
                    RetailSalesDocMgt.SetDocumentTypeReturnOrder();
                end;
            //-NPR5.45 [325216]
            SetDocumentType::Quote:
                begin
                    RetailSalesDocMgt.SetDocumentTypeQuote();
                end;
            else
                Error(ERRDOCTYPE, Format(SetDocumentType), Format(SetDocumentType::Order), Format(SetDocumentType::Invoice), Format(SetDocumentType::CreditMemo), Format(SetDocumentType::ReturnOrder), Format(SetDocumentType::Quote));
        //+NPR5.45 [325216]
        end;

        RetailSalesDocMgt.SetWriteInAuditRoll(JSON.GetBoolean('SetWriteInAuditRoll', true));
        if JSON.GetBoolean('SetShowCreationMessage', true) then RetailSalesDocMgt.SetShowCreationMessage();
        if JSON.GetBoolean('SetFinishSale', true) then RetailSalesDocMgt.SetFinishSale();
        if JSON.GetBoolean('SetShowDepositDialog', true) then RetailSalesDocMgt.SetShowDepositDialog();

        SetOrderType := JSON.GetIntegerParameter('SetOrderType', true);
        case SetOrderType of
            SetOrderType::NotSet:
                begin
                    RetailSalesDocMgt.SetOrderType('0');
                end;
            SetOrderType::Order:
                begin
                    RetailSalesDocMgt.SetOrderType('1');
                end;
            SetOrderType::Lending:
                begin
                    RetailSalesDocMgt.SetOrderType('2');
                end;
            else
                Error(ERRORDERTYPE, Format(SetOrderType), Format(SetOrderType::NotSet), Format(SetOrderType::Order), Format(SetOrderType::Lending));
        end;

        RetailSalesDocMgt.SetReturnAmount(Format(JSON.GetDecimalParameter('SetReturnAmountPercentage', true)));
        RetailSalesDocMgt.SetOutput(Format(JSON.GetIntegerParameter('SetOutputCodeunit', true)));

        //DO
        if JSON.GetBoolean('TestSalePOS', true) then RetailSalesDocMgt.TestSaleLinePOS(SaleLinePOS);
        if JSON.GetBoolean('ProcessPOSSale', true) then ResultProcessPOSSale := RetailSalesDocMgt.ProcessPOSSale(SalePOS);
        if JSON.GetBoolean('OpenSalesDoc', true) then RetailSalesDocMgt.OpenSalesDoc(SalePOS);

        //Re-initialize sales after all done
        if JSON.GetBoolean('InitNewSaleOnDone', true) then POSSale.InitializeNewSale(Register, FrontEnd, Setup, POSSale);

        POSSession.RequestRefreshData;
        POSSale.SelectViewForEndOfSale(POSSession);
        //FrontEnd.ResumeWorkflow;
    end;

    local procedure SaleLinesExists(SalePOS: Record "NPR Sale POS"): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        exit(not SaleLinePOS.IsEmpty);
    end;

    local procedure SetReference(var SalePOS: Record "NPR Sale POS"; ExtDocNo: Text; Attention: Text)
    var
        CustomerNo: Code[20];
    begin
        //-NPR5.45 [313966]
        if (ExtDocNo <> '') then
            SalePOS.Validate(Reference, CopyStr(ExtDocNo, 1, MaxStrLen(SalePOS.Reference)));

        if (Attention <> '') then
            SalePOS.Validate("Contact No.", CopyStr(Attention, 1, MaxStrLen(SalePOS."Contact No.")));
        //+NPR5.45 [313966]
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        //-NPR5.45 [313966]
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', true));
        //+NPR5.45 [313966]
    end;
}

