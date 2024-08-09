codeunit 6184960 "NPR POS Action Sel ShipMethodB"
{
    Access = Internal;

    local procedure ClearShipmentFeeFromSalesLines(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Shipment Fee", true);
        if not SaleLinePOS.IsEmpty then
            SaleLinePOS.DeleteAll(true);
    end;

    local procedure AddGLShipmentFee(SaleLine: Codeunit "NPR POS Sale Line"; StoreShipProfileLine: Record "NPR Store Ship. Profile Line")
    var
        Line: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        UnitPrice: Decimal;
    begin
        if StoreShipProfileLine."Shipment Fee Type" <> StoreShipProfileLine."Shipment Fee Type"::"G/L Account" then
            exit;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        SaleLine.GetNewSaleLine(Line);
        Line."Line Type" := Line."Line Type"::"GL Payment";
        Line.Validate("No.", StoreShipProfileLine."Shipment Fee No.");

        Line."Custom Descr" := (StoreShipProfileLine.Description <> '');
        if Line."Custom Descr" then
            Line.Description := CopyStr(StoreShipProfileLine.Description, 1, MaxStrLen(Line.Description));

        UnitPrice := StoreShipProfileLine."Shipment Fee Amount";
        if not Line."Price Includes VAT" then
            UnitPrice := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(UnitPrice, Line."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        Line."Unit Price" := UnitPrice;
        Line.Quantity := 1;
        Line.Amount := UnitPrice;
        Line."Store Ship Profile Code" := StoreShipProfileLine."Profile Code";
        Line."Store Ship Profile Line No." := StoreShipProfileLine."Line No.";
        Line."Shipment Fee" := true;
        SaleLine.InsertLine(Line, false);
    end;

    local procedure AddItemFee(SaleLine: Codeunit "NPR POS Sale Line"; StoreShipProfileLine: Record "NPR Store Ship. Profile Line")
    var
        Line: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        POSActionInsertItemB: Codeunit "NPR POS Action: Insert Item B";
        NPRPOSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        UnitPrice: Decimal;
    begin
        if StoreShipProfileLine."Shipment Fee Type" <> StoreShipProfileLine."Shipment Fee Type"::Item then
            exit;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        SaleLine.GetNewSaleLine(Line);

        Line."Line Type" := Line."Line Type"::Item;
        Line.Validate("No.", StoreShipProfileLine."Shipment Fee No.");

        UnitPrice := StoreShipProfileLine."Shipment Fee Amount";
        if not Line."Price Includes VAT" then
            UnitPrice := NPRPOSSaleTaxCalc.CalcAmountWithoutVAT(UnitPrice, Line."VAT %", GeneralLedgerSetup."Amount Rounding Precision");

        POSActionInsertItemB.AddItemLine(StoreShipProfileLine."Shipment Fee No.", 1, UnitPrice, StoreShipProfileLine.Description, '', '', '', true, StoreShipProfileLine."Profile Code", StoreShipProfileLine."Line No.");
    end;

    internal procedure SelectShipmentInformation(SalePOS: Record "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line") Success: Boolean;
    var
        StoreShipProfileLine: Record "NPR Store Ship. Profile Line";
        POSStore: Record "NPR POS Store";
    begin
        POSStore.Get(SalePOS."POS Store Code");

        StoreShipProfileLine.Reset();
        StoreShipProfileLine.SetRange("Profile Code", POSStore."POS Shipment Profile");
        Success := StoreShipProfileLine.IsEmpty;
        if Success then
            exit;

        Success := Page.RunModal(0, StoreShipProfileLine) = Action::LookupOK;
        if not Success then
            exit;

        ClearShipmentFeeFromSalesLines(SalePOS);

        case StoreShipProfileLine."Shipment Fee Type" of
            StoreShipProfileLine."Shipment Fee Type"::Item:
                AddItemFee(SaleLine, StoreShipProfileLine);
            StoreShipProfileLine."Shipment Fee Type"::"G/L Account":
                AddGLShipmentFee(SaleLine, StoreShipProfileLine);
        end;

        SaleLine.RefreshCurrent();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnBeforeInsertPOSSalesLine', '', true, true)]
    local procedure OnBeforeInsertPOSSalesLine(POSEntry: Record "NPR POS Entry"; SalePOS: Record "NPR POS Sale"; var POSSalesLine: Record "NPR POS Entry Sales Line"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        POSSalesLine."Shipment Fee" := SaleLinePOS."Shipment Fee";
    end;
}