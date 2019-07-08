table 6151167 "NpGp POS Sales Entry"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Sales Entry';
    DrillDownPageID = "NpGp POS Sales Entries";
    LookupPageID = "NpGp POS Sales Entries";

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Entry Time";DateTime)
        {
            Caption = 'Entry Time';
        }
        field(10;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            OptionCaption = 'Comment,Direct Sale,Other,Credit Sale,Balancing,Cancelled Sale';
            OptionMembers = Comment,"Direct Sale",Other,"Credit Sale",Balancing,"Cancelled Sale";
        }
        field(15;"Retail ID";Guid)
        {
            Caption = 'Retail ID';
        }
        field(100;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(105;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(110;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(115;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(120;"Fiscal No.";Code[20])
        {
            Caption = 'Fiscal No.';
        }
        field(125;"Salesperson Code";Code[10])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(200;"Currency Code";Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(205;"Currency Factor";Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0:15;
            Editable = false;
            InitValue = 1;
            MinValue = 1;
        }
        field(210;"Sales Amount";Decimal)
        {
            Caption = 'Sales Amount';
        }
        field(215;"Discount Amount";Decimal)
        {
            Caption = 'Discount Amount';
        }
        field(220;"Sales Quantity";Decimal)
        {
            Caption = 'Sales Quantity';
        }
        field(225;"Return Sales Quantity";Decimal)
        {
            Caption = 'Return Sales Quantity';
        }
        field(230;"Total Amount";Decimal)
        {
            Caption = 'Total Amount';
        }
        field(235;"Total Tax Amount";Decimal)
        {
            Caption = 'Total Tax Amount';
        }
        field(240;"Total Amount Incl. Tax";Decimal)
        {
            Caption = 'Total Amount Incl. Tax';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"POS Store Code","POS Unit No.","Document No.")
        {
        }
        key(Key3;"Retail ID")
        {
        }
    }

    fieldgroups
    {
    }
}

