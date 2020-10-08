table 6060149 "NPR RC Members. Burndown Setup"
{

    Caption = 'Trailing Sales Orders Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Text[132])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(2; "Period Length"; Option)
        {
            Caption = 'Period Length';
            DataClassification = CustomerContent;
            OptionCaption = 'Day,Week,Month,Quarter,Year';
            OptionMembers = Day,Week,Month,Quarter,Year;
        }
        field(3; "Show Memberships"; Option)
        {
            Caption = 'Show Memberships';
            DataClassification = CustomerContent;
            OptionCaption = 'Type of Sales,By Community,By Membership';
            OptionMembers = SALES_TYPE,BY_COMMUNITY,BY_MEMBERSHIP;
        }
        field(4; "Use Work Date as Base"; Boolean)
        {
            Caption = 'Use Work Date as Base';
            DataClassification = CustomerContent;
        }
        field(5; "Value to Calculate"; Option)
        {
            Caption = 'Value to Calculate';
            DataClassification = CustomerContent;
            OptionCaption = 'Membership Count,Membership Value';
            OptionMembers = MEMBERSHIP_COUNT,MEMBERSHIP_VALUE;
        }
        field(6; "Chart Type"; Option)
        {
            Caption = 'Chart Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Stacked Area,Stacked Area (%),Stacked Column,Stacked Column (%)';
            OptionMembers = "Stacked Area","Stacked Area (%)","Stacked Column","Stacked Column (%)";
        }
        field(8; "Show Change As"; Option)
        {
            Caption = 'Show Change As';
            DataClassification = CustomerContent;
            OptionCaption = 'Net,Accumulative';
            OptionMembers = NET,ACK;
        }
        field(9; "StartDate Offset"; DateFormula)
        {
            Caption = 'StartDate Offset';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "User ID")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Updated at %1.';

    procedure GetCurrentSelectionText(): Text[100]
    begin
        //EXIT(FORMAT("Show Memberships") + '|' +
        //  FORMAT("Period Length") + '|' +
        //  FORMAT("Value to Calculate") + '|. (' +
        //  StrSubstNo(Text001,TIME) + ')');

        exit(StrSubstNo('%1|%2|%3|%4|. (%5)',
          "Show Memberships",
          "Period Length",
          "Value to Calculate",
          "StartDate Offset",
          StrSubstNo(Text001, Time)
          ));
    end;

    procedure GetStartDate(): Date
    var
        StartDate: Date;
    begin
        if "Use Work Date as Base" then
            StartDate := WorkDate
        else
            StartDate := Today;

        if (Format("StartDate Offset") <> '') then
            StartDate := CalcDate("StartDate Offset", StartDate);

        exit(StartDate);
    end;

    procedure GetChartType(): Integer
    var
        BusinessChart: Record "Business Chart Buffer";
    begin
        case "Chart Type" of
            "Chart Type"::"Stacked Area":
                exit(BusinessChart."Chart Type"::StackedArea);
            "Chart Type"::"Stacked Area (%)":
                exit(BusinessChart."Chart Type"::StackedArea100);
            "Chart Type"::"Stacked Column":
                exit(BusinessChart."Chart Type"::StackedColumn);
            "Chart Type"::"Stacked Column (%)":
                exit(BusinessChart."Chart Type"::StackedColumn100);
        end;
    end;

    procedure SetPeriodLength(PeriodLength: Option)
    begin
        "Period Length" := PeriodLength;
        Modify();
    end;

    procedure SetShowMemberships(ShowMembership: Integer)
    begin
        "Show Memberships" := ShowMembership;
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

    procedure SetPeriodType(PeriodType: Option)
    begin
        "Show Change As" := PeriodType;
        Modify();
    end;
}

