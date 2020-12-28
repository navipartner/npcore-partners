table 6151363 "NPR CS Wareh. Activ. Setup"
{
    Caption = 'CS Warehouse Activity Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';



    fields
    {
        field(1; "Source Document"; Enum "Warehouse Activity Source Document")
        {
            Caption = 'Source Document';
            DataClassification = CustomerContent;
        }
        field(2; "Activity Type"; Option)
        {
            Caption = 'Activity Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Put-away,Pick,Movement,Invt. Put-away,Invt. Pick,Invt. Movement,Whse. Receipt,Whse. Shipment';
            OptionMembers = " ","Put-away",Pick,Movement,"Invt. Put-away","Invt. Pick","Invt. Movement","Whse. Receipt","Whse. Shipment";
        }
        field(10; "Show as Item No."; Option)
        {
            Caption = 'Show as Item No.';
            DataClassification = CustomerContent;
            OptionCaption = 'Item No.,Vendor Item No.';
            OptionMembers = "Item No.","Vendor Item No.";
        }
    }

    keys
    {
        key(Key1; "Source Document", "Activity Type")
        {
        }
    }

    fieldgroups
    {
    }





}