codeunit 6150908 "NPR HC Customer Price Mgt."
{
    // NPR5.38/TSA /20171130 CASE 297859 Initial Version


    trigger OnRun()
    begin
    end;

    var
        InvalidXml: Label 'The response is not in valid XML format.\\%1';

    local procedure "-- Server Side (HQ)"()
    begin
    end;

    [TryFunction]
    procedure TryProcessRequest(var TmpSalesHeader: Record "Sales Header"; var TmpSalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        TmpSalesLinePriceCalc: Record "Sales Line" temporary;
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
            TmpSalesLinePriceCalc."Document Type" := SalesHeader."Document Type";
            TmpSalesLinePriceCalc."Document No." := SalesHeader."No.";
            TmpSalesLinePriceCalc."Line No." := TmpSalesLine."Line No.";
            TmpSalesLinePriceCalc.Insert(true);

            TmpSalesLinePriceCalc.Validate(Type, TmpSalesLine.Type);
            TmpSalesLinePriceCalc.Validate("No.", TmpSalesLine."No.");
            TmpSalesLinePriceCalc.Validate("Variant Code", TmpSalesLine."Variant Code");
            TmpSalesLinePriceCalc.Validate(Quantity, TmpSalesLine.Quantity);

            if (TmpSalesLine."Unit of Measure Code" <> '') then
                TmpSalesLinePriceCalc.Validate("Unit of Measure Code", TmpSalesLine."Unit of Measure Code");
            TmpSalesLinePriceCalc.Modify(true);

            // writeback of result
            TmpSalesLine.TransferFields(TmpSalesLinePriceCalc, false);
            TmpSalesLine.Modify();

        until (TmpSalesLine.Next() = 0);
    end;
}

