table 6014435 "NPR Touch Screen: Meta Func."
{
    Access = Internal;
    // NPR/RMT/20150210 Case 198862 - Assigned a valid lookuppage to the table
    // NPR5.20/MHA/20150315 CASE 235325 Added Action Type NavEvent for invoking Publisher function HandleMetaTriggerEvent()

    Caption = 'Touch Screen - Meta Functions';
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Unique number';
            Description = 'Unique Number';
            DataClassification = CustomerContent;
        }
        field(2; "Code"; Code[50])
        {
            Caption = 'Function Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description Native Language';
            DataClassification = CustomerContent;
        }
        field(4; "Text Line 1"; Text[50])
        {
            Caption = 'Text line 1';
            Description = 'Text for button';
            DataClassification = CustomerContent;
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Start Up,Login,Sale,Payment,Balancing,General,Comment,Discount,Prints,Reports';
            OptionMembers = Startup,Login,Sale,Payment,Balancing,Generel,Comment,Discount,Prints,Reports;
            DataClassification = CustomerContent;
        }
        field(6; "Used counter"; Integer)
        {
            Caption = 'Used counter';
            DataClassification = CustomerContent;
        }
        field(7; "Action"; Option)
        {
            Caption = 'Action';
            Description = 'NPR5.20';
            OptionCaption = ' ,,,Event - Codeunit 6014630 HandleMetaTriggerEvent';
            OptionMembers = " ","Report",Form,NavEvent;
            DataClassification = CustomerContent;
        }
        field(8; "Description ENU"; Text[250])
        {
            Caption = 'English description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "Code", "No.")
        {
        }
        key(Key2; "Used counter")
        {
        }
        key(Key3; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

