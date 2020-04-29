codeunit 6150815 "POS Action - Cust.Sal.Doc.Imp."
{
    // NPR5.32/ANEN /20170314  CASE 268218 POS Action for importing NAV Sales Document to POS (wraps around the CU[Retail Sales Doc. Imp. Mgt.])
    // NPR5.48/THRO /20181129  CASE 334516 Update POS subtotal after lines are inserted


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built in function for handling sales document import to POS';
        Setup: Codeunit "POS Setup";
        REMOVE: Codeunit "Retail Sales Doc. Mgt.";
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4 or %5';
        ERRORDERTYPE: Label 'Wrong Order Type. Order Type is set to %1. It must be one of %2, %3, %4.';
        ERRPARSET: Label 'SalesDocumentToPOS and SalesDocumentAmountToPOS can not be used simultaneously. This is an error in parameter setting on menu button for action %1.';
        ERRPARSETCOMB: Label 'Import of amount is only supported for Document Type Order. This is an error in parameter setting on menu button for action %1.';
        ERRDOCTYPESUPPORT: Label 'Document Type %1 is not supported. This is an error in parameter setting on menu button for action %2.';

    local procedure ActionCode(): Text
    begin
        exit ('CUSTSALEDOCIMP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin


            RegisterWorkflowStep('startDocumentManager','respond();');
            RegisterWorkflowStep('doneDocumentManager','');
            RegisterWorkflow(true);

            //Parameters for set -
            RegisterOptionParameter('SetDocumentType', 'Quote,Order,Invoice,CreditMemo,BlanketOrder,ReturnOrder', 'Order');
            RegisterOptionParameter('SetOrderType','NotSet,Order,Lending', 'NotSet');
            RegisterBooleanParameter('SetConfirmDelete', false);

            //Parameters for do
            RegisterBooleanParameter('SalesDocumentToPOS', false);
            RegisterBooleanParameter('SalesDocumentAmountToPOS', false);
            RegisterBooleanParameter('DeleteSalesDocAfterImport', false);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;


        case WorkflowStep of
          'startDocumentManager': OnStartDocumentManager(Context, POSSession,FrontEnd);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        JSON: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;
    end;

    local procedure "--"()
    begin
    end;

    local procedure OnStartDocumentManager(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        SetDocumentType: Option Quote,"Order",Invoice,CreditMemo,BlanketOrder,ReturnOrder;
        SetOrderType: Option NotSet,"Order",Lending;
        SalesDocumentToPOS: Boolean;
        SalesDocumentAmountToPOS: Boolean;
    begin
        //Handling the wrap-connect to [Retail Sales Doc. Imp. Mgt.]

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        //Collect parameter and set to [Retail Sales Doc. Imp. Mgt.]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters', true);


        //DOS

        RetailSalesDocImpMgt.SetDeleteDocumentOnImport( JSON.GetBoolean('DeleteSalesDocAfterImport', true), JSON.GetBoolean('SetConfirmDelete', true) );

        SalesDocumentToPOS := JSON.GetBoolean('SalesDocumentToPOS', true);
        SalesDocumentAmountToPOS := JSON.GetBoolean('SalesDocumentAmountToPOS', true);
        if SalesDocumentToPOS and SalesDocumentAmountToPOS then Error(ERRPARSET, ActionCode);


        //SET
        SetOrderType:= JSON.GetIntegerParameter('SetOrderType', true);
        case SetOrderType of
           SetOrderType::NotSet :
            begin
              RetailSalesDocImpMgt.SetOrderType(SetOrderType::NotSet);
            end;
            SetOrderType::Order :
            begin
              RetailSalesDocImpMgt.SetOrderType(SetOrderType::Order);
            end;
            SetOrderType::Lending :
            begin
              RetailSalesDocImpMgt.SetOrderType(SetOrderType::Lending);
            end;
          else Error(ERRORDERTYPE, Format(SetOrderType), Format(SetOrderType::NotSet), Format(SetOrderType::Order), Format(SetOrderType::Lending) );
        end;

        SetDocumentType := JSON.GetIntegerParameter('SetDocumentType', true);
        case SetDocumentType of
          SetDocumentType::Quote :
            begin
              if SalesDocumentToPOS then RetailSalesDocImpMgt.SalesDocumentToPOSLegacy(SalePOS, SetDocumentType);
              //IF SalesDocumentAmountToPOS THEN RetailSalesDocImpMgt.SalesDocumentAmountToPOS(SalePOS, SetDocumentType);
              if SalesDocumentAmountToPOS then Error(ERRPARSETCOMB, ActionCode);
            end;
          SetDocumentType::Order :
            begin
              if SalesDocumentToPOS then RetailSalesDocImpMgt.SalesDocumentToPOSLegacy(SalePOS, SetDocumentType);
              if SalesDocumentAmountToPOS then RetailSalesDocImpMgt.SalesDocumentAmountToPOSLegacy(SalePOS, SetDocumentType);
            end;
          SetDocumentType::Invoice :
            begin
              if SalesDocumentToPOS then RetailSalesDocImpMgt.SalesDocumentToPOSLegacy(SalePOS, SetDocumentType);
              //IF SalesDocumentAmountToPOS THEN RetailSalesDocImpMgt.SalesDocumentAmountToPOS(SalePOS, SetDocumentType);
              if SalesDocumentAmountToPOS then Error(ERRPARSETCOMB, ActionCode);
            end;
          SetDocumentType::CreditMemo :
            begin
              if SalesDocumentToPOS then RetailSalesDocImpMgt.SalesDocumentToPOSLegacy(SalePOS, SetDocumentType);
              //IF SalesDocumentAmountToPOS THEN RetailSalesDocImpMgt.SalesDocumentAmountToPOS(SalePOS, SetDocumentType);
              if SalesDocumentAmountToPOS then Error(ERRPARSETCOMB, ActionCode);
            end;
          SetDocumentType::ReturnOrder :
            begin
              if SalesDocumentToPOS then RetailSalesDocImpMgt.SalesDocumentToPOSLegacy(SalePOS, SetDocumentType);
              //IF SalesDocumentAmountToPOS THEN RetailSalesDocImpMgt.SalesDocumentAmountToPOS(SalePOS, SetDocumentType);
              if SalesDocumentAmountToPOS then Error(ERRPARSETCOMB, ActionCode);
            end;
            SetDocumentType::BlanketOrder :
            begin
              Error(ERRDOCTYPESUPPORT, SetDocumentType::BlanketOrder, ActionCode);
            end;
          else Error(ERRDOCTYPE, Format(SetDocumentType), Format(SetDocumentType::Order), Format(SetDocumentType::Invoice), Format(SetDocumentType::CreditMemo), Format(SetDocumentType::ReturnOrder) );
        end;

        //POSSale.Modify
        //-NPR5.48 [334516]
        //POSSale.Refresh(SalePOS);
        //POSSale.RefreshCurrent();
        POSSaleLine.SetLast();
        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();
        //+NPR5.48 [334516]
        POSSession.RequestRefreshData();
    end;
}

