table 6151391 "NPR CS Stock-Takes"
{
    Access = Internal;

    Caption = 'CS Stock-Takes';
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
        field(10; Closed; DateTime)
        {
            Caption = 'Closed';
            DataClassification = CustomerContent;
        }
        field(11; Location; Code[20])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
        }
        field(12; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(13; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        field(14; "Salesfloor Started"; DateTime)
        {
            Caption = 'Salesfloor Started';
            DataClassification = CustomerContent;
        }
        field(15; "Salesfloor Started By"; Code[10])
        {
            Caption = 'Salesfloor Started By';
            DataClassification = CustomerContent;
        }
        field(16; "Salesfloor Closed"; DateTime)
        {
            Caption = 'Salesfloor Closed';
            DataClassification = CustomerContent;
        }
        field(17; "Salesfloor Closed By"; Code[20])
        {
            Caption = 'Salesfloor Closed By';
            DataClassification = CustomerContent;
        }
        field(19; "Stockroom Started"; DateTime)
        {
            Caption = 'Stockroom Started';
            DataClassification = CustomerContent;
        }
        field(20; "Stockroom Started By"; Code[10])
        {
            Caption = 'Stockroom Started By';
            DataClassification = CustomerContent;
        }
        field(21; "Stockroom Closed"; DateTime)
        {
            Caption = 'Stockroom Closed';
            DataClassification = CustomerContent;
        }
        field(22; "Stockroom Closed By"; Code[20])
        {
            Caption = 'Stockroom Closed By';
            DataClassification = CustomerContent;
        }
        field(24; "Refill Started"; DateTime)
        {
            Caption = 'Refill Started';
            DataClassification = CustomerContent;
        }
        field(25; "Refill Started By"; Code[10])
        {
            Caption = 'Refill Started By';
            DataClassification = CustomerContent;
        }
        field(26; "Refill Closed"; DateTime)
        {
            Caption = 'Refill Closed';
            DataClassification = CustomerContent;
        }
        field(27; "Refill Closed By"; Code[20])
        {
            Caption = 'Refill Closed By';
            DataClassification = CustomerContent;
        }
        field(28; "Salesfloor Duration"; Duration)
        {
            Caption = 'Salesfloor Duration';
            DataClassification = CustomerContent;
        }
        field(29; "Stockroom Duration"; Duration)
        {
            Caption = 'Stockroom Duration';
            DataClassification = CustomerContent;
        }
        field(30; "Refill Duration"; Duration)
        {
            Caption = 'Refill Duration';
            DataClassification = CustomerContent;
        }
        field(31; "Closed By"; Code[10])
        {
            Caption = 'Closed By';
            DataClassification = CustomerContent;
        }
        field(32; Approved; DateTime)
        {
            Caption = 'Approved';
            DataClassification = CustomerContent;
        }
        field(33; "Approved By"; Code[20])
        {
            Caption = 'Approved By';
            DataClassification = CustomerContent;
        }
        field(34; Note; Text[250])
        {
            Caption = 'Note';
            DataClassification = CustomerContent;
        }
        field(36; "Create Refill Data Started"; DateTime)
        {
            Caption = 'Create Refill Data Started';
            DataClassification = CustomerContent;
        }
        field(37; "Create Refill Data Ended"; DateTime)
        {
            Caption = 'Create Refill Data Ended';
            DataClassification = CustomerContent;
        }
        field(38; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(39; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(40; "Predicted Qty."; Decimal)
        {
            Caption = 'Predicted Qty.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(41; "Inventory Calculated"; Boolean)
        {
            Caption = 'Inventory Calculated';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(42; "Journal Posted"; Boolean)
        {
            Caption = 'Journal Posted';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(43; "Adjust Inventory"; Boolean)
        {
            Caption = 'Adjust Inventory';
            DataClassification = CustomerContent;
        }
        field(45; "Manuel Posting"; Boolean)
        {
            Caption = 'Manuel Posting';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Stock-Take Id")
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

