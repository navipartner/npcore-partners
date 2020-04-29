codeunit 6150796 "POS Action - Delete POS Line"
{
    // NPR5.32.10/TSA /20170615  CASE 280993 Added parameter for ConfirmDialog
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant
    // NPR5.42/BHR /20180510   CASE 313914 Added Security functionality
    // NPR5.45/TSA /20180803  CASE 323780 Added call to Sale.SetModified() to have the data driver refresh data
    // NPR5.46/TSA /20180914  CASE 314603 Refactored the security functionality to use secure methods
    // NPR5.48/MHA /20181121  CASE 330181 Added function DeleteAccessories()
    // NPR5.53/TJ  /20191021  CASE 373234 Added new publisher OnBeforeDeleteSaleLinePOS()
    // NPR5.54/TSA /20200205 CASE 387912 Made OnBeforeDeleteSaleLinePOS() public


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function deletes sales or payment line from the POS';
        Title: Label 'Delete Line';
        Prompt: Label 'Are you sure you want to delete the line %1?';
        NotAllowed: Label 'This line can''t be deleted.';

    local procedure ActionCode(): Text
    begin
        exit ('DELETE_POS_LINE');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.2'); //-+NPR5.46 [314603]
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin

            RegisterWorkflowStep ('decl0', 'confirmtext = labels.notallowed;');
            RegisterWorkflowStep ('decl1', 'if (!data.isEmpty())    {confirmtext = labels.Prompt.substitute(data("10"));};');
            RegisterWorkflowStep ('confirm',  '(param.ConfirmDialog == param.ConfirmDialog["Yes"]) ? confirm({title: labels.title, caption: confirmtext}).respond() : respond();');
            RegisterWorkflow(false);
            RegisterDataBinding();
            //-NPR5.42 [313914]
            RegisterOptionParameter('Security','None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword','None');
            //+NPR5.42 [313914]
            RegisterOptionParameter('ConfirmDialog','No,Yes','No');
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        DeletePosLine (Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'title', Title);
        Captions.AddActionCaption (ActionCode, 'notallowed', NotAllowed);
        Captions.AddActionCaption (ActionCode, 'Prompt', Prompt);
    end;

    local procedure DeletePosLine(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        POSSaleLine: Codeunit "POS Sale Line";
        POSPaymentLine: Codeunit "POS Payment Line";
        LinePOS: Record "Sale Line POS";
        POSSale: Codeunit "POS Sale";
        CurrentView: DotNet npNetView0;
        CurrentViewType: DotNet npNetViewType0;
        ViewType: DotNet npNetViewType0;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);
        POSSession.GetCurrentView (CurrentView);

        if (CurrentView.Type.Equals (ViewType.Sale)) then begin
          POSSession.GetSaleLine(POSSaleLine);
          //-NPR5.53 [373234]
          OnBeforeDeleteSaleLinePOS(POSSaleLine);
          //+NPR5.53 [373234]
          //-NPR5.48 [330181]
          DeleteAccessories(POSSaleLine);
          //+NPR5.48 [330181]
          POSSaleLine.DeleteLine();
        end;

        if (CurrentView.Type.Equals (ViewType.Payment)) then begin
          POSSession.GetPaymentLine (POSPaymentLine);
          //+NPR5.42 [288119]
          POSPaymentLine.RefreshCurrent();
          //-NPR5.42 [288119]

          POSPaymentLine.DeleteLine();
        end;

        //-NPR5.45 [323780]
        POSSession.GetSale (POSSale);
        POSSale.SetModified ();
        //+NPR5.45 [323780]

        POSSession.RequestRefreshData();
    end;

    local procedure DeleteAccessories(POSSaleLine: Codeunit "POS Sale Line")
    var
        SaleLinePOS: Record "Sale Line POS";
        SaleLinePOS2: Record "Sale Line POS";
    begin
        //-NPR5.48 [330181]
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
          exit;
        if SaleLinePOS."No." in ['','*'] then
          exit;

        SaleLinePOS2.SetRange("Register No.",SaleLinePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.",SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetRange("Sale Type",SaleLinePOS."Sale Type");
        SaleLinePOS2.SetFilter("Line No.",'<>%1',SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange("Main Line No.",SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange(Accessory,true);
        SaleLinePOS2.SetRange("Main Item No.",SaleLinePOS."No.");
        if SaleLinePOS2.IsEmpty then
          exit;

        SaleLinePOS2.SetSkipCalcDiscount(true);
        SaleLinePOS2.DeleteAll(false);
        //-NPR5.48 [330181]
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeDeleteSaleLinePOS(POSSaleLine: Codeunit "POS Sale Line")
    begin
    end;
}

