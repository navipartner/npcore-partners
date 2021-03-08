table 6151369 "NPR CS Rfid Lines"
{

    Caption = 'CS Rfid Lines';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';


    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Tag Id"; Text[30])
        {
            Caption = 'Tag Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Item."No.";


        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(14; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; Match; Boolean)
        {
            Caption = 'Match';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; "Item Group Code"; Code[10])
        {
            Caption = 'Item Group Code';
            DataClassification = CustomerContent;
        }
        field(19; "Transferred To"; Option)
        {
            Caption = 'Transferred To';
            DataClassification = CustomerContent;
            OptionCaption = ',Sales Order,Whse. Receipt,Transfer Order';
            OptionMembers = ,"Sales Order","Whse. Receipt","Transfer Order";
        }
        field(20; "Transferred to Doc"; Code[20])
        {
            Caption = 'Transferred to Doc';
            DataClassification = CustomerContent;
        }
        field(21; "Transferred Date"; DateTime)
        {
            Caption = 'Transferred Date';
            DataClassification = CustomerContent;
        }
        field(22; "Transferred By"; Code[20])
        {
            Caption = 'Transferred By';
            DataClassification = CustomerContent;
        }
        field(23; Approved; DateTime)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
        }
        field(24; "Approved By"; Code[10])
        {
            Caption = 'Approved By';
            DataClassification = CustomerContent;
        }
        field(25; "Combined key"; Code[30])
        {
            Caption = 'Combined key';
            DataClassification = CustomerContent;
        }
        field(26; "Transferred to Whse. Receipt"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27; "Tag Shipped"; Boolean)
        {
            Caption = 'Tag Shipped';
            DataClassification = CustomerContent;
        }
        field(28; "Tag Received"; Boolean)
        {
            Caption = 'Tag Received';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id, "Tag Id")
        {
        }
    }

    fieldgroups
    {
    }


}

