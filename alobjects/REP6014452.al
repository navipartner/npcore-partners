report 6014452 "Sales Ticket Statistics/Date"
{
    // NPR5.50/BHR /20190524 CASE 348464 Alternative to Page 6014468
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/Sales Ticket StatisticsDate.rdlc';

    Caption = 'Sales Ticket Statistics/Date';
    EnableHyperlinks = true;

    dataset
    {
        dataitem(Date;Date)
        {
            DataItemTableView = SORTING("Period Type","Period Start");
            column(PeriodType_Date;Date."Period Type")
            {
            }
            column(PeriodStart_Date;Date."Period Start")
            {
            }
            column(PeriodEnd_Date;Date."Period End")
            {
            }
            column(PeriodNo_Date;Date."Period No.")
            {
            }
            column(PeriodName_Date;Date."Period Name")
            {
            }
            column(Balance_Due_LCY;Kassedata."All Normal Sales in Audit Roll")
            {
            }
            column(Purchase_LCY;Kassedata."All Debit Sales in Audit Roll")
            {
            }
            column(Total;Kassedata."All Normal Sales in Audit Roll"+Kassedata."All Debit Sales in Audit Roll")
            {
            }
            column(totalCount;totalCount)
            {
            }
            column(StayExpedition;Average)
            {
            }
            column(URLBalanceDue;URLBalanceDue)
            {
            }
            column(URLPurchase;URLPurchase)
            {
            }
            column(PeriodStartCap;Date.FieldCaption("Period Start"))
            {
            }
            column(PeriodNameCap;Date.FieldCaption("Period Name"))
            {
            }
            column(BalanceDueCap;BalanceDueCap)
            {
            }
            column(PurchasesCap;PurchasesCap)
            {
            }
            column(TotalCap;TotalCap)
            {
            }
            column(NumberExpCap;NumberExpCap)
            {
            }
            column(StayExpeditionCap;StayExpeditionCap)
            {
            }
            column(Filters;Filters)
            {
            }

            trigger OnAfterGetRecord()
            var
                Cust: Record Customer;
            begin
                Kassedata.Reset;
                AuditRoll.Reset;
                SetDateFilter;
                SetDimensionFilters;

                Kassedata.CalcFields("All Normal Sales in Audit Roll","All Debit Sales in Audit Roll");

                CalcAverage();
                URLBalanceDue := '';
                URLPurchase := '';


                URLBalanceDue :=  GetUrl(CurrentClientType, CompanyName, OBJECTTYPE::Page,6014432 );
                URLBalanceDue += StrSubstNo(Url1,"Period Start",Date."Period End",AuditRoll."Sale Type"::Sale,AuditRoll.Type::Item);


                URLPurchase := GetUrl(CurrentClientType, CompanyName, OBJECTTYPE::Page,6014432 );
                URLPurchase += StrSubstNo(Url1,"Period Start",Date."Period End",AuditRoll."Sale Type"::"Debit Sale",AuditRoll.Type::Item);
            end;

            trigger OnPreDataItem()
            begin

                Date.SetRange("Period Type",PeriodType);
                Date.SetRange("Period Start",FromDate,ToDate);
                Filters := Date.GetFilters;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(PeriodType;PeriodType)
                {
                    Caption = 'Period Type';
                }
                field(FromDate;FromDate)
                {
                    Caption = 'From Date';
                }
                field(ToDate;ToDate)
                {
                    Caption = 'To Date';
                }
                field(AmountType;AmountType)
                {
                    Caption = 'Amount Type';
                }
                field(Dim1Filter;Dim1Filter)
                {
                    CaptionClass = '1,2,1';
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));
                }
                field(Dim2Filter;Dim2Filter)
                {
                    CaptionClass = '1,2,2';
                    TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));
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

    labels
    {
    }

    var
        PeriodFormMgt: Codeunit PeriodFormManagement;
        AuditRollForm: Page "Audit Roll";
        VendPeriodLength: Option Day,Week,Month,Quarter,Year,Period;
        AmountType: Option "Net Change","Balance at Date";
        Kassedata: Record Register;
        Tidsvalg: Integer;
        Dim1Filter: Code[20];
        Dim2Filter: Code[20];
        PeriodType: Option Day,Week,Month,Quarter,Year;
        AuditRoll: Record "Audit Roll";
        totalCount: Decimal;
        FromDate: Date;
        ToDate: Date;
        "Average": Decimal;
        AuditRoll2: Record "Audit Roll";
        Err1: Label 'From Date should be filled in';
        URLBalanceDue: Text;
        URLPurchase: Text;
        BalanceDueCap: Label 'Balance Due (LCY)';
        PurchasesCap: Label 'Purchases (LCY)';
        TotalCap: Label 'Total';
        NumberExpCap: Label 'Number of Exp.';
        StayExpeditionCap: Label 'Stay Expedition';
        Filters: Text;
        Url1: Label '&$filter=''Sale Date''%20IS%20''%1..%2''%20AND%20''Sale Type''%20IS%20''%3''%20AND%20''Type''%20IS%20''%4''';

    local procedure SetDateFilter()
    begin
        if AmountType = AmountType::"Net Change" then
          Kassedata.SetRange("Date Filter",Date."Period Start",Date."Period End")
        else
          Kassedata.SetRange("Date Filter",0D,Date."Period End");

        if AmountType = AmountType::"Net Change" then
          AuditRoll.SetRange("Sale Date",Date."Period Start",Date."Period End")
        else
          AuditRoll.SetRange("Sale Date",0D,Date."Period End");
    end;

    procedure CalcAverage()
    var
        totalAmount: Decimal;
    begin

        AuditRoll.SetFilter("Sale Type",'%1|%2',AuditRoll."Sale Type"::Sale,AuditRoll."Sale Type"::"Debit Sale");

        totalCount  := AuditRoll.GetNoOfSales();
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

