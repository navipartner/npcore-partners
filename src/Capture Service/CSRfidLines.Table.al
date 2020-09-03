table 6151369 "NPR CS Rfid Lines"
{
    // NPR5.53/CLVA  /20191121  CASE 377563 Object created - NP Capture Service
    // NPR5.54/JAKUBV/20200408  CASE 379709 Transport NPR5.54 - 8 April 2020
    // NPR5.55/CLVA  /20200326  CASE 379709 Added field "Approved", "Approved By" and "Combined key"
    // NPR5.55/CLVA  /20200506  CASE 379709 Changed DataPerCompany to No

    Caption = 'CS Rfid Lines';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    DrillDownPageID = "NPR CS RFID Lines Subpage";
    LookupPageID = "NPR CS RFID Lines Subpage";

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR CS Rfid Header";
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

            trigger OnValidate()
            begin
                Validate("Variant Code", '');
            end;
        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(12; "Item Description"; Text[50])
        {
            CalcFormula = Lookup (Item.Description WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "Variant Description"; Text[50])
        {
            CalcFormula = Lookup ("Item Variant".Description WHERE(Code = FIELD("Variant Code"),
                                                                   "Item No." = FIELD("Item No.")));
            Caption = 'Variant Description';
            Editable = false;
            FieldClass = FlowField;
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
            TableRelation = "NPR Item Group";
        }
        field(18; "Item Group Description"; Text[50])
        {
            CalcFormula = Lookup ("NPR Item Group".Description WHERE("No." = FIELD("Item Group Code")));
            Caption = 'Item Group Description';
            Editable = false;
            FieldClass = FlowField;
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

    trigger OnInsert()
    begin
        Created := CurrentDateTime;
        "Created By" := UserId;
    end;
}

