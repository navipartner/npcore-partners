codeunit 6150908 "NPR HC Customer Price Mgt."
{
    [TryFunction]
    procedure TryProcessRequest(var TmpSalesHeader: Record "Sales Header"; var TmpSalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        TempSalesLinePriceCalc: Record "Sales Line" temporary;
    begin
        TmpSalesHeader.TestField("Sell-to Customer No.");

        SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", TmpSalesHeader."Sell-to Customer No.");
        SalesHeader.Validate("Currency Code", TmpSalesHeader."Currency Code");

        SalesHeader.Modify(true);

        TmpSalesLine.FindSet();
        repeat
            TempSalesLinePriceCalc."Document Type" := SalesHeader."Document Type";
            TempSalesLinePriceCalc."Document No." := SalesHeader."No.";
            TempSalesLinePriceCalc."Line No." := TmpSalesLine."Line No.";
            TempSalesLinePriceCalc.Insert(true);

            TempSalesLinePriceCalc.Validate(Type, TmpSalesLine.Type);
            TempSalesLinePriceCalc.Validate("No.", TmpSalesLine."No.");
            TempSalesLinePriceCalc.Validate("Variant Code", TmpSalesLine."Variant Code");
            TempSalesLinePriceCalc.Validate(Quantity, TmpSalesLine.Quantity);

            if (TmpSalesLine."Unit of Measure Code" <> '') then
                TempSalesLinePriceCalc.Validate("Unit of Measure Code", TmpSalesLine."Unit of Measure Code");
            TempSalesLinePriceCalc.Modify(true);

            // writeback of result
            TmpSalesLine.TransferFields(TempSalesLinePriceCalc, false);
            TmpSalesLine.Modify();
        until (TmpSalesLine.Next() = 0);
    end;
}

