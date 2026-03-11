#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
table 6151265 "NPR NPRE Menu"
{
    Access = Internal;
    Caption = 'Restaurant Menu';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Menus";
    LookupPageID = "NPR NPRE Menus";

    fields
    {
        field(1; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(40; "Start Time"; Time)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(41; "End Time"; Time)
        {
            Caption = 'End Time';
            DataClassification = CustomerContent;
        }
        field(50; Timezone; Text[50])
        {
            Caption = 'Timezone';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TimeZoneChoice: Text[180];
                TimeZoneSelection: Codeunit "Time Zone Selection";
            begin
                TimeZoneChoice := Timezone;
                if TimeZoneSelection.LookupTimeZone(TimezoneChoice) then
                    Timezone := CopyStr(TimezoneChoice, 1, MaxStrLen(Timezone));
            end;

            trigger OnValidate()
            var
                TimeZoneValue: Text[180];
                TimeZoneSelection: Codeunit "Time Zone Selection";
            begin
                TimeZoneValue := Timezone;
                TimeZoneSelection.ValidateTimeZone(TimeZoneValue);
                Timezone := CopyStr(TimeZoneValue, 1, MaxStrLen(Timezone));
            end;
        }
        field(100; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(110; "Last Updated"; DateTime)
        {
            Caption = 'Last Updated';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Restaurant Code", "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        NPREMenuCategory: Record "NPR NPRE Menu Category";
    begin
        NPREMenuCategory.SetRange("Menu Code", Code);
        NPREMenuCategory.SetRange("Restaurant Code", "Restaurant Code");
        NPREMenuCategory.DeleteAll(true);
    end;
}
#endif
