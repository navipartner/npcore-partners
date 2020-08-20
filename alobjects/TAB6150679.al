table 6150679 "NPRE Kitchen Request Station"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200803 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Order Line Station';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPRE Kitchen Request Stations";
    LookupPageID = "NPRE Kitchen Request Stations";

    fields
    {
        field(1; "Request No."; BigInteger)
        {
            Caption = 'Request No.';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Kitchen Request";
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Production Restaurant Code"; Code[20])
        {
            Caption = 'Production Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Restaurant";
        }
        field(20; "Kitchen Station"; Code[20])
        {
            Caption = 'Kitchen Station';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Kitchen Station".Code WHERE("Restaurant Code" = FIELD("Production Restaurant Code"));
        }
        field(30; "Production Status"; Option)
        {
            Caption = 'Production Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Not Started,Started,,Finished,Cancelled';
            OptionMembers = "Not Started",Started,,Finished,Cancelled;
        }
        field(40; "Start Date-Time"; DateTime)
        {
            Caption = 'Start Date-Time';
            DataClassification = CustomerContent;
        }
        field(50; "End Date-Time"; DateTime)
        {
            Caption = 'End Date-Time';
            DataClassification = CustomerContent;
        }
        field(60; "Order ID"; BigInteger)
        {
            Caption = 'Order ID';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Kitchen Order";
        }
        field(70; "On Hold"; Boolean)
        {
            Caption = 'On Hold';
            DataClassification = CustomerContent;
        }
        field(80; "Qty. Change Not Accepted"; Boolean)
        {
            Caption = 'Qty. Change Not Accepted';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(90; "Last Qty. Change Accepted"; DateTime)
        {
            Caption = 'Last Qty. Change Accepted';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
    }

    keys
    {
        key(Key1; "Request No.", "Line No.")
        {
        }
        key(Key2; "Production Restaurant Code", "Kitchen Station")
        {
        }
    }

    fieldgroups
    {
    }
}

