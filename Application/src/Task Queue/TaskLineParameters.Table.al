table 6059909 "NPR Task Line Parameters"
{
    Access = Internal;
    Caption = 'Task Line Parameters';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(3; "Journal Line No."; Integer)
        {
            Caption = 'Journal Line No.';
            DataClassification = CustomerContent;
        }
        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(9; "Field Code"; Code[20])
        {
            Caption = 'Field Code';
            DataClassification = CustomerContent;
        }
        field(10; "Field Type"; Option)
        {
            Caption = 'Field Type';
            OptionCaption = 'Text,Date,Time,DateTime,Integer,Decimal,Boolean,DateFormula';
            OptionMembers = Text,Date,Time,DateTime,"Integer",Decimal,Boolean,DateFormula;
            DataClassification = CustomerContent;
        }
        field(11; "Text Sub Type"; Option)
        {
            Caption = 'Text Sub Type';
            OptionCaption = ' ,E-mail Address,Password';
            OptionMembers = " ",EmailAddress,Password;
            DataClassification = CustomerContent;
        }
        field(20; Value; Text[250])
        {
            Caption = 'Text Value';
            DataClassification = CustomerContent;
        }
        field(21; "Date Value"; Date)
        {
            Caption = 'Date Value';
            DataClassification = CustomerContent;
        }
        field(22; "Time Value"; Time)
        {
            Caption = 'Time Value';
            DataClassification = CustomerContent;
        }
        field(23; "DateTime Value"; DateTime)
        {
            Caption = 'DateTime Value';
            DataClassification = CustomerContent;
        }
        field(24; "Integer Value"; Integer)
        {
            Caption = 'Integer Value';
            DataClassification = CustomerContent;
        }
        field(25; "Decimal Value"; Decimal)
        {
            Caption = 'Decimal Value';
            DataClassification = CustomerContent;
        }
        field(26; "Boolean Value"; Boolean)
        {
            Caption = 'Boolean Value';
            DataClassification = CustomerContent;
        }
        field(27; "Date Formula"; DateFormula)
        {
            Caption = 'Date Formula';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Journal Line No.", "Field No.", "Line No.")
        {
        }
    }
}

