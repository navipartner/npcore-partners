table 6150654 "NPR POS Unit Rcpt.Txt Profile"
{
    // NPR5.54/BHR /20200210 CASE 389444 Table 'POS Unit Receipt Text Profile'

    Caption = 'POS Unit Receipt Text Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Unit Rcpt.Txt Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(10; "Sales Ticket Line Text off"; Option)
        {
            Caption = 'Sales Ticket Line Text off';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            OptionCaption = 'Pos Unit,Comment';
            OptionMembers = "Pos Unit",Comment;
        }
        field(11; "Sales Ticket Line Text1"; Code[50])
        {
            Caption = 'Sales Ticket Line Text1';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(12; "Sales Ticket Line Text2"; Code[50])
        {
            Caption = 'Sales Ticket Line Text2';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(13; "Sales Ticket Line Text3"; Code[50])
        {
            Caption = 'Sales Ticket Line Text3';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(14; "Sales Ticket Line Text4"; Code[50])
        {
            Caption = 'Sales Ticket Line Text 4';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(15; "Sales Ticket Line Text5"; Code[50])
        {
            Caption = 'Sales Ticket Line Text 5';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(16; "Sales Ticket Line Text6"; Code[50])
        {
            Caption = 'Sales Ticket Line Text6';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(17; "Sales Ticket Line Text7"; Code[50])
        {
            Caption = 'Sales Ticket Line Text7';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(18; "Sales Ticket Line Text8"; Code[50])
        {
            Caption = 'Sales Ticket Line Text8';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(19; "Sales Ticket Line Text9"; Code[50])
        {
            Caption = 'Sales Ticket Line Text9';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

