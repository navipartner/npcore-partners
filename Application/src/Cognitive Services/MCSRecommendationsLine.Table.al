table 6060084 "NPR MCS Recommendations Line"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

    Caption = 'MCS Recommendations Line';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MCS Recomm. Lines";
    LookupPageID = "NPR MCS Recomm. Lines";

    fields
    {
        field(10; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(20; "Model No."; Code[10])
        {
            Caption = 'Model No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR MCS Recomm. Model";
        }
        field(30; "Log Entry No."; Integer)
        {
            Caption = 'Log Entry No.';
            DataClassification = CustomerContent;
        }
        field(50; "Seed Item No."; Code[20])
        {
            Caption = 'Seed Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(110; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(120; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(130; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(140; "Register No."; Code[10])
        {
            Caption = 'Register No.';
            DataClassification = CustomerContent;
        }
        field(150; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(160; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(200; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = false;
        }
        field(210; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(220; Rating; Decimal)
        {
            AutoFormatExpression = '<precision,0:2><Standard Format,0>%';
            AutoFormatType = 10;
            Caption = 'Rating';
            DataClassification = CustomerContent;
        }
        field(300; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table No.", "Document Type", "Document No.", "Document Line No.", Rating)
        {
        }
        key(Key3; "Seed Item No.", Rating)
        {
        }
    }

    fieldgroups
    {
    }

    procedure LogSelectRecommendedItem()
    var
        MCSRecommendationsLog: Record "NPR MCS Recommendations Log";
    begin
        MCSRecommendationsLog.Init;
        MCSRecommendationsLog."Entry No." := 0;
        MCSRecommendationsLog.Type := MCSRecommendationsLog.Type::SelectRecommendation;
        MCSRecommendationsLog."Start Date Time" := CurrentDateTime;
        MCSRecommendationsLog."End Date Time" := CurrentDateTime;
        MCSRecommendationsLog.Success := true;
        MCSRecommendationsLog."Model No." := "Model No.";
        MCSRecommendationsLog."Seed Item No." := "Seed Item No.";
        MCSRecommendationsLog."Selected Item" := "Item No.";
        MCSRecommendationsLog."Selected Rating" := Rating;
        MCSRecommendationsLog."Table No." := "Table No.";
        MCSRecommendationsLog."Document Type" := "Document Type";
        MCSRecommendationsLog."Document No." := "Document No.";
        MCSRecommendationsLog."Document Line No." := "Document Line No.";
        MCSRecommendationsLog."Register No." := "Register No.";
        MCSRecommendationsLog."Customer No." := "Customer No.";
        MCSRecommendationsLog."Document Date" := "Document Date";
        MCSRecommendationsLog.Insert(true);
    end;
}

