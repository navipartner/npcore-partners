table 6151592 "NpDc Coupon Entry"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171012  CASE 293232 Updated OptionString of Field 10 "Entry Type"

    Caption = 'Coupon Entry';
    DrillDownPageID = "NpDc Coupon Entries";
    LookupPageID = "NpDc Coupon Entries";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Coupon No.";Code[20])
        {
            Caption = 'Coupon No.';
            TableRelation = "NpDc Coupon";
        }
        field(10;"Entry Type";Option)
        {
            Caption = 'Entry Type';
            Description = 'NPR5.37';
            OptionCaption = ',Issue Coupon,Discount Application,Manual Archive';
            OptionMembers = ,"Issue Coupon","Discount Application","Manual Archive";
        }
        field(15;"Coupon Type";Code[20])
        {
            Caption = 'Coupon Type';
            TableRelation = "NpDc Coupon Type";
        }
        field(17;Positive;Boolean)
        {
            Caption = 'Positive';
        }
        field(20;Amount;Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
        }
        field(25;"Posting Date";Date)
        {
            Caption = 'Posting Date';
        }
        field(30;Open;Boolean)
        {
            Caption = 'Open';
        }
        field(35;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
        }
        field(40;"Remaining Quantity";Decimal)
        {
            Caption = 'Remaining Quantity';
            DecimalPlaces = 0:5;
        }
        field(45;"Amount per Qty.";Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount per Qty.';
        }
        field(50;"Register No.";Code[10])
        {
            Caption = 'Register No.';
            TableRelation = Register."Register No.";
        }
        field(55;"Sales Ticket No.";Code[20])
        {
            Caption = 'Sales Ticket No.';
        }
        field(65;"User ID";Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(70;"Closed by Entry No.";Integer)
        {
            BlankZero = true;
            Caption = 'Closed by Entry No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Coupon No.")
        {
            SumIndexFields = Amount,Quantity;
        }
    }

    fieldgroups
    {
    }
}

