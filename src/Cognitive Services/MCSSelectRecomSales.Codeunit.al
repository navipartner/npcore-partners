codeunit 6060085 "NPR MCS Select Recom. Sales"
{
    // NPR5.30/BR  /20170303  CASE 252646 Object Created
    // NPR5.30/NPKNAV/20170310  CASE 252646 Transport NPR5.30 - 26 January 2017


    trigger OnRun()
    begin
    end;

    procedure SelectRecommendedItem(SalesHeader: Record "Sales Header") AccountNo: Code[20]
    var
        MCSRecommendationsLine: Record "NPR MCS Recommendations Line";
        TempMCSRecommendationsLine: Record "NPR MCS Recommendations Line" temporary;
        MCSRecommendationsModel: Record "NPR MCS Recomm. Model";
        MCSRecommendationsSetup: Record "NPR MCS Recommendations Setup";
        Item: Record Item;
        TempItem: Record Item temporary;
        SalesLine: Record "Sales Line";
        MCSRecommendationsHandler: Codeunit "NPR MCS Recomm. Handler";
        RetailItemList: Page "NPR Retail Item List";
        ItemFilter: Text;
    begin
        MCSRecommendationsSetup.Get;
        if not MCSRecommendationsSetup."Background Send POS Lines" then begin
            SendSaleData(SalesHeader);
            Commit;
        end;

        MCSRecommendationsHandler.GetRecommendationsLinesFromSales(SalesHeader, TempMCSRecommendationsLine);
        MCSRecommendationsHandler.GetItemListFromRecommendations(TempItem, TempMCSRecommendationsLine, MCSRecommendationsSetup."Max. Rec. per Sales Document");

        if PAGE.RunModal(PAGE::"NPR Retail Item List", TempItem) = ACTION::LookupOK then begin
            TempMCSRecommendationsLine.SetRange("Item No.", TempItem."No.");
            if TempMCSRecommendationsLine.FindFirst then
                TempMCSRecommendationsLine.LogSelectRecommendedItem;
            InsertRecommendedItemInSalesLine(SalesHeader, TempItem);
        end;
    end;

    local procedure SendSaleData(SalesHeader: Record "Sales Header") AccountNo: Code[20]
    var
        MCSRecommendationsModel: Record "NPR MCS Recomm. Model";
        MCSRecommendationsSetup: Record "NPR MCS Recommendations Setup";
        MCSRecommendationsHandler: Codeunit "NPR MCS Recomm. Handler";
    begin
        MCSRecommendationsSetup.Get;
        MCSRecommendationsSetup.TestField("Online Recommendations Model");
        MCSRecommendationsModel.Get(MCSRecommendationsSetup."Online Recommendations Model");
        MCSRecommendationsHandler.InsertSalesRecommendations(MCSRecommendationsModel, SalesHeader);
    end;

    local procedure InsertRecommendedItemInSalesLine(SalesHeader: Record "Sales Header"; TempItem: Record Item temporary)
    var
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        SalesLine.Reset;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast then
            LineNo := SalesLine."Line No." + 10000
        else
            LineNo := 10000;

        SalesHeader.TestField(Status, SalesHeader.Status::Open);

        SalesLine.Init;
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", LineNo);
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", TempItem."No.");
        SalesLine.Modify;
    end;
}

