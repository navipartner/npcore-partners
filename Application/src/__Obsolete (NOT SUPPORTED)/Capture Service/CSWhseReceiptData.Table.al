table 6151395 "NPR CS Whse. Receipt Data"
{
    
    Caption = 'CS Whse. Receipt Data';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.'; 

    fields
    {
        field(1; "Doc. No."; Code[20])
        {
            Caption = 'Doc. No.';
            DataClassification = CustomerContent;
        }
        field(2; "Tag Id"; Text[30])
        {
            Caption = 'Tag Id';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
           
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(12; "Item Group Code"; Code[10])
        {
            Caption = 'Item Group Code';
            DataClassification = CustomerContent;
        }
     
        field(16; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(17; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        field(18; "Tag Type"; Option)
        {
            Caption = 'Tag Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Document,Not on Document,Unknown';
            OptionMembers = Document,"Not on Document",Unknown;
        }
        field(20; Transferred; DateTime)
        {
            Caption = 'Transferred';
            DataClassification = CustomerContent;
        }
        field(21; "Transferred By"; Code[10])
        {
            Caption = 'Transferred By';
            DataClassification = CustomerContent;
        }
        field(22; "Transferred To Doc"; Boolean)
        {
            Caption = 'Transferred To Doc';
            DataClassification = CustomerContent;
        }
        field(23; "Combined key"; Code[30])
        {
            Caption = 'Combined key';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Doc. No.", "Tag Id")
        {
        }
    }

    fieldgroups
    {
    }
    
}

