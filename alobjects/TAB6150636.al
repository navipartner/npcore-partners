table 6150636 "POS Entry Output Log"
{
    // NPR5.39/BR  /20180207  CASE 304165 Object Created
    // NPR5.40/MMV /20180319  CASE 304639 Renamed object and fields to be print independent.
    //                                    Added field 40.
    // NPR5.41/MMV /20180425  CASE 312782 Removed table relation on field 35 as it is no longer template specific.
    // NPR5.48/MMV /20180619  CASe 318028 Added field 31

    Caption = 'POS Entry Output Log';
    DataClassification = CustomerContent;
    DrillDownPageID = "POS Entry Output Log";
    LookupPageID = "POS Entry Output Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Output Timestamp"; DateTime)
        {
            Caption = 'Output Timestamp';
            DataClassification = CustomerContent;
        }
        field(25; "Output Type"; Option)
        {
            Caption = 'Output Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sales Receipt,Large Sales Receipt,Balancing,Sales Doc. Receipt';
            OptionMembers = SalesReceipt,LargeSalesReceipt,Balancing,SalesDocReceipt;
        }
        field(30; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
        }
        field(31; "Salesperson Code"; Code[10])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(35; "Output Method Code"; Text[250])
        {
            Caption = 'Output Method Code';
            DataClassification = CustomerContent;
        }
        field(40; "Output Method"; Option)
        {
            Caption = 'Output Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Print,SMS,E-mail,Webservice';
            OptionMembers = Print,SMS,Email,Webservice;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "POS Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

