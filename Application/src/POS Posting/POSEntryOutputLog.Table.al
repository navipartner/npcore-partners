table 6150636 "NPR POS Entry Output Log"
{
    Caption = 'POS Entry Output Log';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Entry Output Log";
    LookupPageID = "NPR POS Entry Output Log";

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
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(31; "Salesperson Code"; Code[20])
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

