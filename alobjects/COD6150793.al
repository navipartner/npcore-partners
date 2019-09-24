codeunit 6150793 "POS Action - Open Cash Drawer"
{
    // NPR5.38/TSA /20171123 CASE 297087 Added POS Entry System Event for open drawer
    // NPR5.38/ANEN /20171227 CASE 295200 Added option to as for salesperson pwd on open drawer. / Added Parameters to OnBeforeWorkflow
    // NPR5.40/MMV /20180301 CASE 300660 Use new payment bin opening methods
    // NPR5.40.02/MMV /20180418 CASE 311900 Fallback if missing setup
    // NPR5.41/MMV /20180425 CASE 312990 Proper fallback.
    // NPR5.46/TSA /20180925 CASE 314603 Implementing Secure Methods as security model, removing old security model (refactoring) & removing all comments (cleanup)
    // NPR5.51/MHA /20190613 CASE 358392 Added find before modify in OnAction() in case POSSale is not current
    // NPR5.51/ALST/20190614 CASE 353516 changed action to allow for cash drawer opening before sale is started


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for opening the cash drawer';
        Title: Label 'Insert password';
        InvalidPassword: Label 'Password is invalid';

    local procedure ActionCode(): Text
    begin
        exit('OPEN_CASH_DRAWER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.4');
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
            RegisterTextParameter('Cash Drawer No.', '');

          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        CashDrawerNo: Code[10];
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        POSSetup: Codeunit "POS Setup";
        POSUnit: Record "POS Unit";
        RecID: RecordID;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser (Context, FrontEnd);
        JSON.SetScope ('parameters', true);
        CashDrawerNo := JSON.GetString ('Cash Drawer No.', true);

        POSSession.GetSetup (POSSetup);
        POSSession.GetSale (POSSale);
        //-NPR5.51
        RecID := SalePOS.RecordId;
        //+NPR5.51
        POSSale.GetCurrentSale (SalePOS);

        if (CashDrawerNo = '') then begin
          if (POSUnit.Get (POSSetup.Register)) then
            CashDrawerNo := POSUnit."Default POS Payment Bin";
        end;

        OpenDrawer(CashDrawerNo, SalePOS);

        //-NPR5.51
        if SalePOS.RecordId <> RecID then begin
        //+NPR5.51
          //-NPR5.51 [358392]
          SalePOS.Find;
          //+NPR5.51 [358392]
          SalePOS."Drawer Opened" := true;
          SalePOS.Modify;
          POSSale.Refresh(SalePOS);
        end;

        Handled := true;
    end;

    local procedure OpenDrawer(CashDrawerNo: Code[10];SalePOS: Record "Sale POS")
    var
        POSPaymentBin: Record "POS Payment Bin";
        POSPaymentBinInvokeMgt: Codeunit "POS Payment Bin Eject Mgt.";
    begin

        if not POSPaymentBin.Get (CashDrawerNo) then
          POSPaymentBin."Eject Method" := 'PRINTER';

        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS);
    end;
}

