codeunit 6150829 "POS Action - POS Info"
{
    // NPR5.34/BR /20170727  CASE 282625 Object Created
    // NPR5.34/NPKNAV/20170801  CASE 282748 Transport NPR5.34 - 1 August 2017
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant
    // NPR5.45/TSA /20180810 CASE 319879 Added support for info codes in the payment view and refactored
    // NPR5.51/ALPO/20190826 CASE 364558 Define application scope for POSInfo action
    // NPR5.52/ALPO/20190920 CASE 364558 Data source set to 'BUILTIN_SALE'
    // NPR5.53/ALPO/20200204 CASE 388697 Set value 'All Lines' as default option for parameter 'ApplicationScope'


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function opens a page displaying the POS Information.';
        Title: Label 'Item Card';
        NotAllowed: Label 'Cannot open the Item Inventory Overview for this line.';

    local procedure ActionCode(): Text
    begin
        exit ('POSINFO');
    end;

    local procedure ActionVersion(): Text
    begin
        //EXIT ('1.4');
        //EXIT ('1.5');  //NPR5.51 [364558]
        exit ('1.6');  //NPR5.53 [388697]
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
            RegisterTextParameter ('POSInfoCode', '');
            //-NPR5.51 [364558]
            //RegisterOptionParameter('ApplicationScope',' ,Current Line,All Lines,New Lines,Ask',' ');  //NPR5.53 [388697]-revoked
            RegisterOptionParameter('ApplicationScope',' ,Current Line,All Lines,New Lines,Ask','All Lines');  //NPR5.53 [388697]
            RegisterBooleanParameter('ClearPOSInfo',false);
            //+NPR5.51 [364558]
            RegisterWorkflow(false);
            RegisterDataSourceBinding('BUILTIN_SALE');  //NPR5.52 [364558]

            //-NPR5.45 [319879]
            //RegisterDataBinding();
            //+NPR5.45 [319879]
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

        OpenPOSInfoPage (Context, POSSession, FrontEnd);

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'title', Title);
        Captions.AddActionCaption (ActionCode, 'notallowed', NotAllowed);
    end;

    local procedure OpenPOSInfoPage(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        POSPaymentLine: Codeunit "POS Payment Line";
        POSInfoManagement: Codeunit "POS Info Management";
        SalePOS: Record "Sale POS";
        LinePOS: Record "Sale Line POS";
        CurrentView: DotNet npNetView0;
        CurrentViewType: DotNet npNetViewType0;
        ViewType: DotNet npNetViewType0;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope ('parameters', true);

        //-NPR5.45 [319879]
        // POSSession.GetCurrentView (CurrentView);
        // IF (CurrentView.Type.Equals (ViewType.Sale)) THEN BEGIN
        //  POSSession.GetSaleLine(POSSaleLine);
        //  POSSaleLine.GetCurrentSaleLine(LinePOS);
        //  POSInfoManagement.ProcessPOSInfoMenuFunction(LinePOS,JSON.GetString ('POSInfoCode', TRUE));
        // END;

        POSSession.GetSale (POSSale);
        POSSale.GetCurrentSale (SalePOS);

        POSSession.GetCurrentView (CurrentView);
        if (CurrentView.Type.Equals (ViewType.Sale)) then begin
          POSSession.GetSaleLine(POSSaleLine);
          POSSaleLine.GetCurrentSaleLine(LinePOS);
        end;

        if (CurrentView.Type.Equals (ViewType.Payment)) then begin
          POSSession.GetPaymentLine(POSPaymentLine);
          POSPaymentLine.GetCurrentPaymentLine(LinePOS);
        end;

        if (LinePOS."Sales Ticket No." = '') then begin
          // No lines in current view
          LinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
          LinePOS."Register No." := SalePOS."Register No.";
          LinePOS.Date := SalePOS.Date;
          LinePOS.Type := LinePOS.Type::Item;
        end;

        //POSInfoManagement.ProcessPOSInfoMenuFunction(LinePOS,JSON.GetString ('POSInfoCode', TRUE));  //NPR5.51 [364558]-revoked
        //-NPR5.51 [364558]
        POSInfoManagement.ProcessPOSInfoMenuFunction(
          LinePOS,JSON.GetString('POSInfoCode',true),JSON.GetInteger('ApplicationScope',false),JSON.GetBoolean('ClearPOSInfo',false));
        //+NPR5.51 [364558]
        //+NPR5.45 [319879]
    end;
}

