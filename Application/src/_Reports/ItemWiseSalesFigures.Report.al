report 6060052 "NPR Item Wise Sales Figures"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Item Wise Sales Figures.rdlc';
    Caption = 'Item Wise Sales Figures';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
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
                if (not SalesHeader.FindFirst) or (SalesHeader."NPR External Order No." = '') then begin
                    PreviousItemNo := SalesLine."No.";
                    CurrReport.Skip();
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Date field';
                }
                field(ToDate; ToDate)
                {
                    Caption = 'To Date';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Date field';
                }
            }
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
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FromDate: Date;
        ToDate: Date;
        PercProfit: Decimal;
        Profit: Decimal;
        ProfitOnLineAmount: Decimal;
        MinusOneWeek: Label '-1W';
}

