codeunit 6150827 "POS Action - Item Card"
{
    // NPR5.34/BR /20170724  CASE 282747 Object Created
    // NPR5.38/ANEN /201801013 CASE 289390 Added option to as for salesperson pwd or supervisor pwd.
    // NPR5.46/TSA /20180914 CASE 314603 Refactored the security functionality to use secure methods
    // NPR5.46/TSA /20180914 CASE 314603 Fixed ActionCode and ActionVersion GlobalText to Functions


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function opens the item card page for a selected sales line in the POS';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin

            RegisterWorkflow(false);
            RegisterBooleanParameter('RefreshLine',true);
            RegisterBooleanParameter('PageEditable',true);
            //-NPR5.38 [289390]
            RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
            //+NPR5.38 [289390]
          end;
    end;

    local procedure ActionCode(): Text
    begin

        exit ('ITEMCARD');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.2');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        OpenItemPage (Context, POSSession, FrontEnd);
        Handled := true;
    end;

    local procedure OpenItemPage(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        POSSaleLine: Codeunit "POS Sale Line";
        POSPaymentLine: Codeunit "POS Payment Line";
        LinePOS: Record "Sale Line POS";
        Item: Record Item;
        CurrentView: DotNet View0;
        CurrentViewType: DotNet ViewType0;
        ViewType: DotNet ViewType0;
        RetailItemCard: Page "Retail Item Card";
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);
        POSSession.GetCurrentView (CurrentView);

        if (CurrentView.Type.Equals (ViewType.Sale)) then begin
          POSSession.GetSaleLine(POSSaleLine);
          POSSaleLine.GetCurrentSaleLine(LinePOS);
          if LinePOS.Type = LinePOS.Type::Item then begin
            if Item.Get(LinePOS."No.") then begin
              Item.SetRecFilter;
              RetailItemCard.Editable(JSON.GetBooleanParameter ('PageEditable',false) );
              RetailItemCard.SetRecord(Item);
              RetailItemCard.RunModal;
              if JSON.GetBooleanParameter ('RefreshLine',false) then begin
                LinePOS.Validate("No.");
                LinePOS.Modify(true);
              end;
            end;
          end;
        end;

        POSSession.RequestRefreshData();
    end;
}

