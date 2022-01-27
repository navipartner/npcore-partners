table 6014662 "NPR Stock-Take Worksheet"
{
    Access = Internal;
    Caption = 'Stock-Take Worksheet';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';
    fields
    {
        field(1; "Stock-Take Config Code"; Code[10])
        {
            Caption = 'Stock-Take Conf. Code';
            DataClassification = CustomerContent;
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Ready to Transfer,Partially Transferred,Complete';
            OptionMembers = OPEN,READY_TO_TRANSFER,PARTIALLY_TRANSFERRED,COMPLETE;
            DataClassification = CustomerContent;
        }
        field(212; "Item Group Filter"; Text[200])
        {
            Caption = 'Item Group Filter';
            DataClassification = CustomerContent;
        }
        field(213; "Vendor Code Filter"; Text[200])
        {
            Caption = 'Vendor Code Filter';
            DataClassification = CustomerContent;
        }
        field(214; "Global Dimension 1 Code Filter"; Code[20])
        {
            Caption = 'Global Dimension 1 Code Filter';
            DataClassification = CustomerContent;
        }
        field(215; "Global Dimension 2 Code Filter"; Code[20])
        {
            Caption = 'Global Dimension 2 Code Filter';
            DataClassification = CustomerContent;
        }
        field(226; "Allow User Modification"; Boolean)
        {
            Caption = 'Allow User Modification';
            DataClassification = CustomerContent;
        }

        field(340; "Topup Worksheet"; Boolean)
        {
            Caption = 'Topup Worksheet';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Stock-Take Config Code", Name)
        {
        }
    }

    fieldgroups
    {
    }
}
