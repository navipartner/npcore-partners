codeunit 6151176 "NPR POSAction: Merg.Smlr.Lines"
{
    // NPR5.51/ALST/20190701 CASE 360269 new object
    // NPR5.52/ALST/20191017 CASE 360269 items with diferent unit prices will not be colapsed


    trigger OnRun()
    begin
    end;

    var
        ActionDescriptionCaption: Label 'This action is used to merge similar item lines of the sale to a single one';
        NoLinesErr: Label 'No adequate sale lines are available in the current sale';

    local procedure ActionCode(): Text
    begin
        exit('MERGE_SIMILAR_LINES');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
  ActionCode(),
  ActionDescriptionCaption,
  ActionVersion(),
  Sender.Type::Generic,
  Sender."Subscriber Instances Allowed"::Multiple)
then begin
            Sender.RegisterWorkflowStep('', 'respond();');
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        ColapseSaleLines(SalePOS);

        POSSale.RefreshCurrent();
        POSSession.ChangeViewSale();
        POSSession.RequestRefreshData();

        Handled := true;
    end;

    local procedure "--- Adiacent functions"()
    begin
    end;

    local procedure ColapseSaleLines(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
    begin
        SaleLinePOS.SetCurrentKey("No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter("Discount Type", '<>%1', SaleLinePOS."Discount Type"::Manual);
        if not SaleLinePOS.FindSet() then
            Error(NoLinesErr);

        repeat
            SaleLinePOS.SetRange("No.", SaleLinePOS."No.");
            //-NPR5.52 [360269]
            SaleLinePOS.SetRange("Unit Price", SaleLinePOS."Unit Price");
            //+NPR5.52 [360269]

            if SaleLinePOS.Count() > 1 then begin
                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Insert();

                SaleLinePOS.Delete(true);

                while SaleLinePOS.Next() > 0 do begin
                    TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
                    SaleLinePOS.Delete(true);
                end;

                TempSaleLinePOS.Modify();
            end;

            SaleLinePOS.SetRange("No.");
            //-NPR5.52 [360269]
            SaleLinePOS.SetRange("Unit Price");
        //+NPR5.52 [360269]
        until SaleLinePOS.Next() = 0;

        if not TempSaleLinePOS.FindSet() then
            exit;

        repeat
            SaleLinePOS := TempSaleLinePOS;
            SaleLinePOS.Insert();

            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            SaleLinePOS.Modify();
        until TempSaleLinePOS.Next() = 0;
    end;
}

