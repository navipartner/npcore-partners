codeunit 6150724 "POS Action - Change View"
{
    // NPR5.33/JDH /20170630  CASE 999999 Changed Login to use init function instead of changeview
    // NPR5.36/VB  /20170912  CASE 289011 Implementing specific view layout during change view operation.
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant
    // NPR5.38/TSA /20171123  CASE 297087 Added calls to POS Entry for logging of system actions
    // NPR5.39/MHA /20180202  CASE 302779 Replaced Local function CancelSale() with POS Action CANCEL_POS_SALE
    // NPR5.40/VB  /20180307 CASE 306347 Refactored retrieval of POS Action
    // NPR5.40/TSA /20180320 CASE 308558 Call CancelSale in POS Action Cancel Sale, the PosSession is not same after invokeworkflow - so the POSSaleLine does a deleteall without filter


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Changes the current view.';
        ActionOptions: Label 'Login,Sale,Payment,Balance,Locked';
        POS_LOGOUT: Label 'User logged out from POS %1.';
        ConfirmPrompt: Label 'Are you sure you want to cancel this sales? All lines will be deleted.';
        RemovePayment: Label 'All payment lines must be removed before selecting Login View.';
        RemainingLines: Label 'All lines could not be automatically deleted before selecting Login View. You need to cancel sales manually.';

    local procedure ActionCode(): Text
    begin
        exit ('CHANGE_VIEW');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');
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
          "Subscriber Instances Allowed"::Single)
        then begin
          RegisterWorkflow(false);

          //RegisterOptionParameter('ViewType',ActionOptions,'');
          RegisterOptionParameter('ViewType','Login,Sale,Payment,Balance,Locked','');
          //-NPR5.36 [289011]
          RegisterTextParameter('ViewCode','');
          //+NPR5.36 [289011]
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ControlId: Text;
        Value: Text;
        DoNotClearTextBox: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        ChangeView(Context,POSSession,FrontEnd);

        Handled := true;
    end;

    local procedure ChangeView(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        Item: Record Item;
        POSAction: Record "POS Action";
        POSDefaultUserView: Record "POS Default User View";
        Register: Record Register;
        POSSetup: Codeunit "POS Setup";
        JSON: Codeunit "POS JSON Management";
        POSCreateEntry: Codeunit "POS Create Entry";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        CurrentView: DotNet View0;
        CurrentViewType: DotNet ViewType0;
        POSActionCancelSale: Codeunit "POS Action - Cancel Sale";
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        ViewType := JSON.GetIntegerParameter('ViewType',true);
        //-NPR5.36 [289011]
        POSSession.GetSetup(POSSetup);
        POSSetup.GetRegisterRecord(Register);
        POSDefaultUserView.SetDefault (ViewType, Register."Register No.",JSON.GetStringParameter('ViewCode',false));
        //+NPR5.36 [289011]

        POSSession.GetCurrentView (CurrentView);

        case ViewType of
          ViewType::Login:
            begin

              //-NPR5.40 [308558]
              POSCreateEntry.InsertUnitLogoutEntry (Register."Register No.", POSSetup.Salesperson ());
              //+NPR5.40 [308558]

              if ((CurrentView.Type.Equals (CurrentViewType.Sale)) or (CurrentView.Type.Equals (CurrentViewType.Payment))) then begin
                //-NPR5.40 [308558]
                //        //-NPR5.39 [302779]
                //        //CancelSale (Context,POSSession,FrontEnd);
                //        //-NPR5.40 [306347]
                //        //POSAction.GET('CANCEL_POS_SALE');
                //        IF NOT POSSession.RetrieveSessionAction('CANCEL_POS_SALE',POSAction) THEN
                //          POSAction.GET('CANCEL_POS_SALE');
                //        //+NPR5.40 [306347]
                //        //+NPR5.40 [302779]
                //        FrontEnd.InvokeWorkflow(POSAction);
                //        //+NPR5.39 [302779]
                POSSession.GetSaleLine (POSSaleLine);

                // if there are lines to delete
                if (POSSaleLine.RefreshCurrent()) then
                  Error (RemainingLines)
                  //POSActionCancelSale.CancelSale (Context, POSSession, FrontEnd);

                //+NPR5.40 [308558]
              end;

              //-NPR5.40 [308558]
              POSSession.StartPOSSession ();

              //-#NPR5.33 [999999]
              // POSSession.ChangeViewLogin();
              // POSSession.InitializeSession();
              //+#NPR5.33 [999999]
              //-NPR5.39 [297087]      ]

              //POSCreateEntry.InsertUnitLogoutEntry (Register."Register No.", POSSetup.Salesperson ());
              //+NPR5.39 [297087]
              //+NPR5.40 [308558

            end;
          ViewType::Sale: POSSession.ChangeViewSale();
          ViewType::Payment: POSSession.ChangeViewPayment();
          ViewType::Balance: POSSession.ChangeViewBalancing();
          ViewType::Locked:
            begin
              //+NPR5.39 [297087]
              POSCreateEntry.InsertUnitLockEntry (Register."Register No.", POSSetup.Salesperson ());
              //-NPR5.39 [297087]

              POSSession.ChangeViewLocked();
            end;
        end;
    end;
}

