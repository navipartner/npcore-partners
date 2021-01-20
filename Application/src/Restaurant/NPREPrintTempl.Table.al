table 6150667 "NPR NPRE Print Templ."
{
    Caption = 'NPRE Print Template';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Print Templ. Subpage";
    LookupPageID = "NPR NPRE Print Templ. Subpage";

    fields
    {
        field(1; "Print Type"; Option)
        {
            Caption = 'Print Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Kitchen Order,Serving Request,Pre Receipt';
            OptionMembers = "Kitchen Order","Serving Request","Pre Receipt";
        }
        field(2; "Seating Location"; Code[20])
        {
            Caption = 'Seating Location';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating Location";
        }
        field(3; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
        }
        field(4; "Print Category Code"; Code[20])
        {
            Caption = 'Print Category Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.53';
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
        field(5; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Restaurant";
        }
        field(6; "Serving Step"; Code[10])
        {
            Caption = 'Serving Step';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(WaiterPadLineMealFlow));
        }
        field(20; "Split Print Jobs By"; Option)
        {
            Caption = 'Split Print Jobs By';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            OptionCaption = 'None,Print Category,Serving Step,Both';
            OptionMembers = "None","Print Category","Serving Step",Both;
        }
    }

    keys
    {
        key(Key1; "Print Type", "Restaurant Code", "Seating Location", "Serving Step", "Print Category Code", "Template Code")
        {
        }
    }
}