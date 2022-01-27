table 6014480 "NPR Dynamic Module Setting"
{
    Caption = 'Dynamic Module Setting';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Module Guid"; Guid)
        {
            Caption = 'Module Guid';
            DataClassification = CustomerContent;
        }
        field(2; "Setting ID"; Integer)
        {
            Caption = 'Setting ID';
            DataClassification = CustomerContent;
        }
        field(10; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(20; "Data Type"; Option)
        {
            Caption = 'Data Type';
            OptionCaption = 'Boolean,Code,Date,DateFormula,DateTime,Decimal,Duration,Integer,Option,Text,Time';
            OptionMembers = Boolean,"Code",Date,DateFormula,DateTime,Decimal,Duration,"Integer",Option,Text,Time;
            DataClassification = CustomerContent;
        }
        field(21; "Data Length"; Integer)
        {
            Caption = 'Data Length';
            DataClassification = CustomerContent;
        }
        field(30; "Formatted Value"; Text[250])
        {
            Caption = 'Formatted Value';
            DataClassification = CustomerContent;
        }
        field(31; "XML Formatted Value"; Text[250])
        {
            Caption = 'XML Formatted Value';
            DataClassification = CustomerContent;
        }
        field(50; "Option String"; Text[250])
        {
            Caption = 'Option String';
            DataClassification = CustomerContent;
        }
        field(100; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(110; "Decimal Precision"; Decimal)
        {
            Caption = 'Decimal Precision';
            DataClassification = CustomerContent;
        }
        field(120; "Module Name"; Text[50])
        {
            Caption = 'Module Name';
            DataClassification = CustomerContent;
        }
        field(130; "Preset XML Formatted Value"; Text[250])
        {
            Caption = 'Preset XML Formatted Value';
            DataClassification = CustomerContent;
        }
        field(140; "Preset Formatted Value"; Text[250])
        {
            Caption = 'Preset Formatted Value';
            DataClassification = CustomerContent;
        }
        field(150; "Integer Value"; Integer)
        {
            Caption = 'Integer Value';
            DataClassification = CustomerContent;
        }
        field(160; "Decimal Value"; Decimal)
        {
            Caption = 'Decimal Value';
            DataClassification = CustomerContent;
        }
        field(170; "Boolean Value"; Boolean)
        {
            Caption = 'Boolean Value';
            DataClassification = CustomerContent;
        }
        field(180; "Date Value"; Date)
        {
            Caption = 'Date Value';
            DataClassification = CustomerContent;
        }
        field(190; "DateFormula Value"; DateFormula)
        {
            Caption = 'DateFormula Value';
            DataClassification = CustomerContent;
        }
        field(200; "DateTime Value"; DateTime)
        {
            Caption = 'DateTime Value';
            DataClassification = CustomerContent;
        }
        field(210; "Duration Value"; Duration)
        {
            Caption = 'Duration Value';
            DataClassification = CustomerContent;
        }
        field(220; "Time Value"; Time)
        {
            Caption = 'Time Value';
            DataClassification = CustomerContent;
        }
        field(230; "Preset Integer Value"; Integer)
        {
            Caption = 'Preset Integer Value';
            DataClassification = CustomerContent;
        }
        field(240; "Preset Decimal Value"; Decimal)
        {
            Caption = 'Preset Decimal Value';
            DataClassification = CustomerContent;
        }
        field(250; "Preset Boolean Value"; Boolean)
        {
            Caption = 'Preset Boolean Value';
            DataClassification = CustomerContent;
        }
        field(260; "Preset Date Value"; Date)
        {
            Caption = 'Preset Date Value';
            DataClassification = CustomerContent;
        }
        field(270; "Preset DateFormula Value"; DateFormula)
        {
            Caption = 'Preset DateFormula Value';
            DataClassification = CustomerContent;
        }
        field(280; "Preset DateTime Value"; DateTime)
        {
            Caption = 'Preset DateTime Value';
            DataClassification = CustomerContent;
        }
        field(290; "Preset Duration Value"; Duration)
        {
            Caption = 'Preset Duration Value';
            DataClassification = CustomerContent;
        }
        field(300; "Preset Time Value"; Time)
        {
            Caption = 'Preset Time Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Module Guid", "Setting ID")
        {
        }
    }

    fieldgroups
    {
    }
}

