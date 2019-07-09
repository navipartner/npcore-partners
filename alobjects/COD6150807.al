codeunit 6150807 "POS Action - Import Sales Doc."
{
    // NPR5.48/THRO /20181129  CASE 334516 Update POS subtotal after lines are inserted


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for handling Customer Info';
        ErrorDescription: Label 'Error';
        CustNoMissing: Label 'Customer number not chosen.';
        CustDepositError: Label 'You cannot change customer when doing customer deposits.';
        DebitSaleChangeCancelled: Label 'Debit sale change is cancelled by sales person.';
        ConfirmPosting: Label 'Do you want to post ?';
        POSSetup: Codeunit "POS Setup";
        SerialNumberError: Label 'You have not set a Serial Number from the item. \ \Sales line deleted if the item requires a serial number!';

    local procedure ActionCode(): Text
    begin
        exit ('IMPORTSALESDOC');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflow(false);
            RegisterOptionParameter('ImportDocType','ImportSale','ImportSale');
            RegisterTextParameter('Sales Ticket No.','');


          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ImportDocType: Integer;
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalesTicketNo: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        //MESSAGE('DEBUG: %1\\%2', WorkflowStep, Context.ToString());

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);
        ImportDocType := JSON.GetInteger('ImportDocType',true);
        SalesTicketNo := JSON.GetString('Sales Ticket No.', false);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        //-NPR5.48 [334516]
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        //+NPR5.48 [334516]

        case ImportDocType of
          0 : SetImportSale(SalePOS,SalesTicketNo);
        end;

        //-NPR5.48 [334516]
        POSSaleLine.SetLast();
        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();
        //+NPR5.48 [334516]

        POSSession.RequestRefreshData();

        Handled := true;
    end;

    local procedure "-- Locals --"()
    begin
    end;

    procedure SetImportSale(var SalePOS: Record "Sale POS";SalesTicketNo: Code[20])
    var
        TouchScreenFunctions: Codeunit "Touch Screen - Functions";
        Validering: Code[10];
    begin
        with SalePOS do begin
          TouchScreenFunctions.ImportSalesTicket(SalePOS,SalesTicketNo);
        end;
    end;
}

