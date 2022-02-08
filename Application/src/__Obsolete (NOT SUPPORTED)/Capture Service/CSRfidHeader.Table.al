table 6151368 "NPR CS Rfid Header"
{
    Access = Internal;

    Caption = 'CS Rfid Data By Document';
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
        field(10; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Document Item Quantity"; Decimal)
        {
            Caption = 'Document Item Quantity';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Shipping Closed"; DateTime)
        {
            Caption = 'Shipping Closed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Shipping Closed By"; Code[20])
        {
            Caption = 'Shipping Closed By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Receiving Closed"; DateTime)
        {
            Caption = 'Receiving Closed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Receiving Closed By"; Code[20])
        {
            Caption = 'Receiving Closed By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(17; Closed; DateTime)
        {
            Caption = 'Closed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(20; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "From Company"; Text[30])
        {
            Caption = 'From Company';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "To Company"; Text[30])
        {
            Caption = 'To Company';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(24; "To Document Type"; Option)
        {
            Caption = 'To Document Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = ' ,Sales,Purchase';
            OptionMembers = " ",Sales,Purchase;
        }
        field(25; "To Document No."; Code[20])
        {
            Caption = 'To Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(28; "Import Tags to Shipping Doc."; Boolean)
        {
            Caption = 'Import Tags to Shipping Doc.';
            DataClassification = CustomerContent;
        }
        field(29; "Warehouse Receipt No."; Code[20])
        {
            Caption = 'Warehouse Receipt No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(33; "Document Matched"; Boolean)
        {
            Caption = 'Document Matched';
            DataClassification = CustomerContent;
        }


    }

    keys
    {
        key(Key1; Id)
        {
        }
    }

    fieldgroups
    {
    }























}

