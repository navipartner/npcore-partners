report 6060052 "NPR Item Wise Sales Figures"
{
    // NPR70.00.00.00/LS/20150107  CASE 202876 : Report to 2013 version
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento references updated according to MAG2.00
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Wise Sales Figures.rdlc';

    Caption = 'Item Wise Sales Figures';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Sales Line"; "Sales Line")
        {
            DataItemTableView = SORTING(Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Document Type", "Shipment Date");
            RequestFilterFields = "No.";
            column(LineAmount_SalesLine; "Sales Line"."Line Amount")
            {
            }
            column(No_SalesLine; "Sales Line"."No.")
            {
            }
            column(Quantity_SalesLine; "Sales Line".Quantity)
            {
            }
            column(Amount_SalesLine; "Sales Line".Amount)
            {
            }
            column(AmountIncludingVAT_SalesLine; "Sales Line"."Amount Including VAT")
            {
            }
            column(DocumentType_SalesLine; "Sales Line"."Document Type")
            {
            }
            column(DocumentNo_SalesLine; "Sales Line"."Document No.")
            {
            }
            column(LineNo_SalesLine; "Sales Line"."Line No.")
            {
            }
            column(FromDate; FromDate)
            {
            }
            column(ToDate; ToDate)
            {
            }
            column(Profit; Profit)
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }

            trigger OnAfterGetRecord()
            var
                ItemTmp: Record Item;
                PreviousItemNo: Code[20];
                SomeProfit: Decimal;
            begin
                SalesHeader.SetFilter(SalesHeader."Order Date", '%1..%2', FromDate, ToDate);
                SalesHeader.SetRange(SalesHeader."No.", "Sales Line"."Document No.");
                SalesHeader.SetRange(SalesHeader."Document Type", "Sales Line"."Document Type");

                //-NPR5.23.03
                //IF ((NOT(SalesHeader.FIND('-'))) OR (SalesHeader."Internet Order No." = 0))  THEN BEGIN
                if (not SalesHeader.FindFirst) or (SalesHeader."NPR External Order No." = '') then begin
                    //+NPR5.23.03
                    PreviousItemNo := SalesLine."No.";
                    CurrReport.Skip;
                end
                else
                    if ItemTmp.Get("Sales Line"."No.") then begin
                        ItemTmp.Validate(ItemTmp."Unit Price", "Sales Line"."Unit Price");
                        if ("Sales Line"."No." <> PreviousItemNo) then
                            Profit := 0;
                        SomeProfit := ItemTmp."Profit %";
                        Profit += (ItemTmp."Profit %" * "Sales Line"."Line Amount") / 100;
                        PreviousItemNo := SalesLine."No.";
                    end;
            end;

            trigger OnPreDataItem()
            begin
                "Sales Line".SetRange("Sales Line".Type, "Sales Line".Type::Item);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(FromDate; FromDate)
                {
                    Caption = 'From Date';
                    ApplicationArea=All;
                }
                field(ToDate; ToDate)
                {
                    Caption = 'To Date';
                    ApplicationArea=All;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
        Report_Lbl_Caption = 'Item Wise Sales Figures';
        No_Caption = 'No.';
        Quantity_Caption = 'Quantity';
        Amount_Caption = 'Amount';
        AmountIncVAT_Caption = 'Amount Including VAT';
        LineAmount_Caption = 'Line Amount';
        Profit_Caption = 'Profit on Quantity sold';
        Page_Caption = 'Page';
    }

    trigger OnInitReport()
    begin
        FromDate := CalcDate(MinusOneWeek, Today);
        ToDate := Today;
    end;

    var
        SalesHeader: Record "Sales Header";
        FromDate: Date;
        ToDate: Date;
        Item: Record Item;
        PercProfit: Decimal;
        Profit: Decimal;
        ProfitOnLineAmount: Decimal;
        SalesLine: Record "Sales Line";
        MinusOneWeek: Label '-1W';
}

