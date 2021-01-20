table 6150683 "NPR NPRE Kitchen Station Slct."
{
    Caption = 'Kitchen Station Selection';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(20; "Seating Location"; Code[20])
        {
            Caption = 'Seating Location';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating Location".Code WHERE("Restaurant Code" = FIELD("Restaurant Code"));
        }
        field(40; "Serving Step"; Code[10])
        {
            Caption = 'Serving Step';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(50; "Print Category Code"; Code[20])
        {
            Caption = 'Print Category Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
        field(60; "Production Restaurant Code"; Code[20])
        {
            Caption = 'Production Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(70; "Kitchen Station"; Code[20])
        {
            Caption = 'Kitchen Station';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NPRE Kitchen Station".Code WHERE("Restaurant Code" = FIELD("Production Restaurant Code"));
        }
    }

    keys
    {
        key(Key1; "Restaurant Code", "Seating Location", "Serving Step", "Print Category Code", "Production Restaurant Code", "Kitchen Station")
        {
        }
    }
}