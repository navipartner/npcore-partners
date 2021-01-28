report 6014452 "NPR Sales Ticket Stats/Date"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/Sales Ticket StatisticsDate.rdlc';
    Caption = 'Sales Ticket Statistics/Date';
    EnableHyperlinks = true;
    dataset
    {
        dataitem(Date; Date)
        {
            DataItemTableView = SORTING("Period Type", "Period Start");
            column(PeriodType_Date; Date."Period Type")
            {
            }
            column(PeriodStart_Date; Date."Period Start")
            {
            }
            column(PeriodEnd_Date; Date."Period End")
            {
            }
            column(PeriodNo_Date; Date."Period No.")
            {
            }
            column(PeriodName_Date; Date."Period Name")
            {
            }
            column(Balance_Due_LCY; Kassedata."All Normal Sales in Audit Roll")
            {
            }
            column(Purchase_LCY; Kassedata."All Debit Sales in Audit Roll")
            {
            }
            column(Total; Kassedata."All Normal Sales in Audit Roll" + Kassedata."All Debit Sales in Audit Roll")
            {
            }
            column(totalCount; totalCount)
            {
            }
            column(StayExpedition; Average)
            {
            }
            column(URLBalanceDue; URLBalanceDue)
            {
            }
            column(URLPurchase; URLPurchase)
            {
            }
            column(PeriodStartCap; Date.FieldCaption("Period Start"))
            {
            }
            column(PeriodNameCap; Date.FieldCaption("Period Name"))
            {
            }
            column(BalanceDueCap; BalanceDueCap)
            {
            }
            column(PurchasesCap; PurchasesCap)
            {
            }
            column(TotalCap; TotalCap)
            {
            }
            column(NumberExpCap; NumberExpCap)
            {
            }
            column(StayExpeditionCap; StayExpeditionCap)
            {
            }
            column(Filters; Filters)
            {
            }

            trigger OnAfterGetRecord()
            var
                Cust: Record Customer;
            begin
                Kassedata.Reset();
                AuditRoll.Reset();
                SetDateFilter();
                SetDimensionFilters();

                Kassedata.CalcFields("All Normal Sales in Audit Roll", "All Debit Sales in Audit Roll");

                CalcAverage();
                URLBalanceDue := '';
                URLPurchase := '';

                URLBalanceDue := GetUrl(CurrentClientType, CompanyName, OBJECTTYPE::Page, 6014432);
                URLBalanceDue += StrSubstNo(Url1, "Period Start", Date."Period End", AuditRoll."Sale Type"::Sale, AuditRoll.Type::Item);

                URLPurchase := GetUrl(CurrentClientType, CompanyName, OBJECTTYPE::Page, 6014432);
                URLPurchase += StrSubstNo(Url1, "Period Start", Date."Period End", AuditRoll."Sale Type"::"Debit Sale", AuditRoll.Type::Item);
            end;

            trigger OnPreDataItem()
            begin

                Date.SetRange("Period Type", PeriodType);
                Date.SetRange("Period Start", FromDate, ToDate);
                Filters := Date.GetFilters();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(PeriodType; PeriodType)
                {
                    Caption = 'Period Type';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Period Type field';
                }
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
                field(AmountType; AmountType)
                {
                    Caption = 'Amount Type';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Type field';
                }
                field(Dim1Filter; Dim1Filter)
                {
                    CaptionClass = '1,2,1';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dim1Filter field';
                }
                field(Dim2Filter; Dim2Filter)
                {
                    CaptionClass = '1,2,2';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dim2Filter field';
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            AmountType := AmountType::"Net Change";
            ToDate := Today;
            if AuditRoll2.FindFirst then
                FromDate := AuditRoll2."Sale Date";
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if FromDate > ToDate then
                Error(Err1);
        end;
    }

    var
        AuditRoll: Record "NPR Audit Roll";
        AuditRoll2: Record "NPR Audit Roll";
        Kassedata: Record "NPR Register";
        PeriodFormMgt: Codeunit PeriodFormManagement;
        AuditRollForm: Page "NPR Audit Roll";
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        FromDate: Date;
        ToDate: Date;
        "Average": Decimal;
        totalCount: Decimal;
        Tidsvalg: Integer;
        Url1: Label '&$filter=''Sale Date''%20IS%20''%1..%2''%20AND%20''Sale Type''%20IS%20''%3''%20AND%20''Type''%20IS%20''%4''';
        BalanceDueCap: Label 'Balance Due (LCY)';
        Err1: Label 'From Date should be filled in';
        NumberExpCap: Label 'Number of Exp.';
        PurchasesCap: Label 'Purchases (LCY)';
        StayExpeditionCap: Label 'Stay Expedition';
        TotalCap: Label 'Total';
        PeriodType: Option Day,Week,Month,Quarter,Year;
        VendPeriodLength: Option Day,Week,Month,Quarter,Year,Period;
        AmountType: Option "Net Change","Balance at Date";
        Filters: Text;
        URLBalanceDue: Text;
        URLPurchase: Text;

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then
            Kassedata.SetRange("Date Filter", Date."Period Start", Date."Period End")
        else
            Kassedata.SetRange("Date Filter", 0D, Date."Period End");

        if AmountType = AmountType::"Net Change" then
            AuditRoll.SetRange("Sale Date", Date."Period Start", Date."Period End")
        else
            AuditRoll.SetRange("Sale Date", 0D, Date."Period End");
    end;

    procedure CalcAverage()
    var
        totalAmount: Decimal;
    begin

        AuditRoll.SetFilter("Sale Type", '%1|%2', AuditRoll."Sale Type"::Sale, AuditRoll."Sale Type"::"Debit Sale");

        totalCount := AuditRoll.GetNoOfSales();
        AuditRoll.SetRange("Sale Type");

        totalAmount := Kassedata."All Normal Sales in Audit Roll";

        if totalCount <> 0 then
            Average := totalAmount / totalCount
        else
            Average := 0;
    end;

    procedure SetDimensionFilters()
    begin
        if Dim1Filter <> '' then
            Kassedata.SetRange("Global Dimension 1 Filter", Dim1Filter)
        else
            Kassedata.SetRange("Global Dimension 1 Filter");

        if Dim2Filter <> '' then
            Kassedata.SetFilter("Global Dimension 2 Filter", Dim2Filter)
        else
            Kassedata.SetRange("Global Dimension 2 Filter");


        if Dim1Filter <> '' then
            AuditRoll.SetRange("Shortcut Dimension 1 Code", Dim1Filter)
        else
            AuditRoll.SetRange("Shortcut Dimension 1 Code");

        if Dim2Filter <> '' then
            AuditRoll.SetFilter("Shortcut Dimension 2 Code", Dim2Filter)
        else
            AuditRoll.SetRange("Shortcut Dimension 2 Code");
    end;
}

