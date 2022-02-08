table 6151392 "NPR CS Stock-Takes Data"
{
    Access = Internal;

    Caption = 'CS Stock-Takes Data';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; "Stock-Take Id"; Guid)
        {
            Caption = 'Stock-Take Id';
            DataClassification = CustomerContent;
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Worksheet Name';
            DataClassification = CustomerContent;
        }
        field(3; "Tag Id"; Text[30])
        {
            Caption = 'Tag Id';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;


        }
        field(11; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
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
        field(20; Approved; DateTime)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
        }
        field(21; "Approved By"; Code[10])
        {
            Caption = 'Approved By';
            DataClassification = CustomerContent;
        }
        field(22; "Transferred To Worksheet"; Boolean)
        {
            Caption = 'Transferred To Worksheet';
            DataClassification = CustomerContent;
        }
        field(23; "Combined key"; Code[30])
        {
            Caption = 'Combined key';
            DataClassification = CustomerContent;
        }
        field(24; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Config Code';
            DataClassification = CustomerContent;
        }
        field(25; "Area"; Option)
        {
            Caption = 'Area';
            DataClassification = CustomerContent;
            OptionCaption = 'Warehouse,Salesfloor,Stockroom';
            OptionMembers = Warehouse,Salesfloor,Stockroom;
        }
    }

    keys
    {
        key(Key1; "Stock-Take Id", "Worksheet Name", "Tag Id")
        {
        }
        key(Key2; Created)
        {
        }
    }

    fieldgroups
    {
    }
}

