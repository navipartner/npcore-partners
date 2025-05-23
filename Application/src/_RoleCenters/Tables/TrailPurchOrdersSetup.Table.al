﻿table 6151249 "NPR Trail. Purch. Orders Setup"
{
    Access = Internal;
    Caption = 'Trailing Purchase Orders Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Text[132])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Period Length"; Option)
        {
            Caption = 'Period Length';
            OptionCaption = 'Day,Week,Month,Quarter,Year';
            OptionMembers = Day,Week,Month,Quarter,Year;
            DataClassification = CustomerContent;
        }
        field(3; "Show Orders"; Option)
        {
            Caption = 'Show Orders';
            OptionCaption = 'All Orders,Orders Until Today,Delayed Orders';
            OptionMembers = "All Orders","Orders Until Today","Delayed Orders";
            DataClassification = CustomerContent;
        }
        field(4; "Use Work Date as Base"; Boolean)
        {
            Caption = 'Use Work Date as Base';
            DataClassification = CustomerContent;
        }
        field(5; "Value to Calculate"; Option)
        {
            Caption = 'Value to Calculate';
            OptionCaption = 'Amount Excl. VAT,No. of Orders';
            OptionMembers = "Amount Excl. VAT","No. of Orders";
            DataClassification = CustomerContent;
        }
        field(6; "Chart Type"; Option)
        {
            Caption = 'Chart Type';
            OptionCaption = 'Stacked Area,Stacked Area (%),Stacked Column,Stacked Column (%)';
            OptionMembers = "Stacked Area","Stacked Area (%)","Stacked Column","Stacked Column (%)";
            DataClassification = CustomerContent;
        }
        field(7; "Latest Order Document Date"; Date)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = Max("Sales Header"."Document Date" WHERE("Document Type" = CONST(Order)));
            Caption = 'Latest Order Document Date';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "User ID")
        {
        }
    }

    var
        Text001: Label 'Updated at %1.';

    procedure GetCurrentSelectionText(): Text[100]
    begin
        exit(Format("Show Orders") + '|' +
          Format("Period Length") + '|' +
          Format("Value to Calculate") + '|. (' +
          StrSubstNo(Text001, Time) + ')');
    end;

    procedure GetStartDate(): Date
    var
        StartDate: Date;
    begin
        if "Use Work Date as Base" then
            StartDate := WorkDate()
        else
            StartDate := Today();
        if "Show Orders" = "Show Orders"::"All Orders" then begin
            CalcFields("Latest Order Document Date");
            StartDate := "Latest Order Document Date";
        end;

        exit(StartDate);
    end;

    procedure GetChartType(): Integer
    var
        BusinessChartBuf: Record "Business Chart Buffer";
    begin
        case "Chart Type" of
#if BC17
            "Chart Type"::"Stacked Area":
                exit(BusinessChartBuf."Chart Type"::StackedArea);
            "Chart Type"::"Stacked Area (%)":
                exit(BusinessChartBuf."Chart Type"::StackedArea100);
            "Chart Type"::"Stacked Column":
                exit(BusinessChartBuf."Chart Type"::StackedColumn);
            "Chart Type"::"Stacked Column (%)":
                exit(BusinessChartBuf."Chart Type"::StackedColumn100);
#else
            "Chart Type"::"Stacked Area":
                exit(BusinessChartBuf."Chart Type"::StackedArea.AsInteger());
            "Chart Type"::"Stacked Area (%)":
                exit(BusinessChartBuf."Chart Type"::StackedArea100.AsInteger());
            "Chart Type"::"Stacked Column":
                exit(BusinessChartBuf."Chart Type"::StackedColumn.AsInteger());
            "Chart Type"::"Stacked Column (%)":
                exit(BusinessChartBuf."Chart Type"::StackedColumn100.AsInteger());
#endif                
        end;
    end;

    procedure SetPeriodLength(PeriodLength: Option)
    begin
        "Period Length" := PeriodLength;
        Modify();
    end;

    procedure SetShowOrders(ShowOrders: Integer)
    begin
        "Show Orders" := ShowOrders;
        Modify();
    end;

    procedure SetValueToCalcuate(ValueToCalc: Integer)
    begin
        "Value to Calculate" := ValueToCalc;
        Modify();
    end;

    procedure SetChartType(ChartType: Integer)
    begin
        "Chart Type" := ChartType;
        Modify();
    end;
}

