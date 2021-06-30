codeunit 6151176 "NPR POSAction: Merg.Smlr.Lines"
{
    var
        ActionDescriptionCaption: Label 'This action is used to merge similar item lines of the sale to a single one';
        NoLinesErr: Label 'No adequate sale lines are available in the current sale';

    local procedure ActionCode(): Text
    begin
        exit('MERGE_SIMILAR_LINES');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
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

        ColapseSaleLines(POSSession, SalePOS);

        POSSale.SetModified();
        POSSession.RequestRefreshData();

        Handled := true;
    end;

    #region Adiacent functions

    local procedure ColapseSaleLines(var POSSession: Codeunit "NPR POS Session"; SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        POSSaleLine: Codeunit "NPR POS Sale Line";
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

        POSSession.GetSaleLine(POSSaleLine);

        repeat

            SaleLinePOS.SetRange("No.", SaleLinePOS."No.");
            SaleLinePOS.SetRange("Variant Code", SaleLinePOS."Variant Code");
            SaleLinePOS.SetRange("Unit Price", SaleLinePOS."Unit Price");

            if SaleLinePOS.Count() > 1 then begin

                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Insert();

                POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
                POSSaleLine.DeleteLine();

                while SaleLinePOS.Next() > 0 do begin
                    TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
                    POSSaleLine.SetPosition(SaleLinePOS.GetPosition());
                    POSSaleLine.DeleteLine();
                end;

                TempSaleLinePOS.Modify();
            end;


            SaleLinePOS.SetRange("No.");
            SaleLinePOS.SetRange("Variant Code");
            SaleLinePOS.SetRange("Unit Price");
        until SaleLinePOS.Next() = 0;

        if not TempSaleLinePOS.FindSet() then
            exit;

        repeat
            SaleLinePOS := TempSaleLinePOS;
            POSSaleLine.InsertLine(SaleLinePOS);

            SaleLinePOS.UpdateAmounts(SaleLinePOS);
            SaleLinePOS.Modify();
            POSSaleLine.RefreshCurrent();
        until TempSaleLinePOS.Next() = 0;
    end;
    #endregion
}

