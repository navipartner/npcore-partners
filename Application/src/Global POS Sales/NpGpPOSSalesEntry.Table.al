table 6151167 "NPR NpGp POS Sales Entry"
{
    Caption = 'Global POS Sales Entry';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpGp POS Sales Entries";
    LookupPageID = "NPR NpGp POS Sales Entries";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Entry Time"; DateTime)
        {
            Caption = 'Entry Time';
            DataClassification = CustomerContent;
        }
        field(10; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Comment,Direct Sale,Other,Credit Sale,Balancing,Cancelled Sale';
            OptionMembers = Comment,"Direct Sale",Other,"Credit Sale",Balancing,"Cancelled Sale";
        }
        field(15; "Retail ID"; Guid)
        {
            Caption = 'Retail ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use systemID instead';
        }
        field(100; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(105; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(107; "Original Company"; Text[30])
        {
            Caption = 'Original Company Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
        field(110; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(115; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(120; "Fiscal No."; Code[20])
        {
            Caption = 'Fiscal No.';
            DataClassification = CustomerContent;
        }
        field(125; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(200; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(205; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            Editable = false;
            InitValue = 1;
            MinValue = 1;
        }
        field(210; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
            DataClassification = CustomerContent;
        }
        field(215; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(220; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(225; "Return Sales Quantity"; Decimal)
        {
            Caption = 'Return Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(230; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
        }
        field(235; "Total Tax Amount"; Decimal)
        {
            Caption = 'Total Tax Amount';
            DataClassification = CustomerContent;
        }
        field(240; "Total Amount Incl. Tax"; Decimal)
        {
            Caption = 'Total Amount Incl. Tax';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "POS Store Code", "POS Unit No.", "Document No.")
        {
        }
        key(Key3; "Retail ID")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Use systemID instead';
        }
    }

    fieldgroups
    {
    }
}

