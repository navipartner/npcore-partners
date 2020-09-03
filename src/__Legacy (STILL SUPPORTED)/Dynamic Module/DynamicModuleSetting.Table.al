table 6014480 "NPR Dynamic Module Setting"
{
    // NPR5.38/NPKNAV/20180126  CASE 294992 Transport NPR5.38 - 26 January 2018

    Caption = 'Dynamic Module Setting';

    fields
    {
        field(1; "Module Guid"; Guid)
        {
            Caption = 'Module Guid';
        }
        field(2; "Setting ID"; Integer)
        {
            Caption = 'Setting ID';
        }
        field(10; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(20; "Data Type"; Option)
        {
            Caption = 'Data Type';
            OptionCaption = 'Boolean,Code,Date,DateFormula,DateTime,Decimal,Duration,Integer,Option,Text,Time';
            OptionMembers = Boolean,"Code",Date,DateFormula,DateTime,Decimal,Duration,"Integer",Option,Text,Time;
        }
        field(21; "Data Length"; Integer)
        {
            Caption = 'Data Length';
        }
        field(30; "Formatted Value"; Text[250])
        {
            Caption = 'Formatted Value';
        }
        field(31; "XML Formatted Value"; Text[250])
        {
            Caption = 'XML Formatted Value';
        }
        field(50; "Option String"; Text[250])
        {
            Caption = 'Option String';
        }
        field(100; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(110; "Decimal Precision"; Decimal)
        {
            Caption = 'Decimal Precision';
        }
        field(120; "Module Name"; Text[50])
        {
            Caption = 'Module Name';
        }
        field(130; "Preset XML Formatted Value"; Text[250])
        {
            Caption = 'Preset XML Formatted Value';
        }
        field(140; "Preset Formatted Value"; Text[250])
        {
            Caption = 'Preset Formatted Value';
        }
        field(150; "Integer Value"; Integer)
        {
            Caption = 'Integer Value';
        }
        field(160; "Decimal Value"; Decimal)
        {
            Caption = 'Decimal Value';
        }
        field(170; "Boolean Value"; Boolean)
        {
            Caption = 'Boolean Value';
        }
        field(180; "Date Value"; Date)
        {
            Caption = 'Date Value';
        }
        field(190; "DateFormula Value"; DateFormula)
        {
            Caption = 'DateFormula Value';
        }
        field(200; "DateTime Value"; DateTime)
        {
            Caption = 'DateTime Value';
        }
        field(210; "Duration Value"; Duration)
        {
            Caption = 'Duration Value';
        }
        field(220; "Time Value"; Time)
        {
            Caption = 'Time Value';
        }
        field(230; "Preset Integer Value"; Integer)
        {
            Caption = 'Preset Integer Value';
        }
        field(240; "Preset Decimal Value"; Decimal)
        {
            Caption = 'Preset Decimal Value';
        }
        field(250; "Preset Boolean Value"; Boolean)
        {
            Caption = 'Preset Boolean Value';
        }
        field(260; "Preset Date Value"; Date)
        {
            Caption = 'Preset Date Value';
        }
        field(270; "Preset DateFormula Value"; DateFormula)
        {
            Caption = 'Preset DateFormula Value';
        }
        field(280; "Preset DateTime Value"; DateTime)
        {
            Caption = 'Preset DateTime Value';
        }
        field(290; "Preset Duration Value"; Duration)
        {
            Caption = 'Preset Duration Value';
        }
        field(300; "Preset Time Value"; Time)
        {
            Caption = 'Preset Time Value';
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

