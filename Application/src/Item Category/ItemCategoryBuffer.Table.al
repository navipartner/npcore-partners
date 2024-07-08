table 6059807 "NPR Item Category Buffer"
{
    Access = Internal;
    Caption = 'Item Category Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Table Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(3; "Code with Indentation"; Text[120])
        {
            Caption = 'Indentation Text';
            DataClassification = CustomerContent;
        }
        field(4; "Order No."; Integer)
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(10; "Parent Category"; Code[20])
        {
            Caption = 'Parent Category';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(40; "Presentation Order"; Integer)
        {
            Caption = 'Presentation Order';
            DataClassification = CustomerContent;
        }
        field(50; "Has Children"; Boolean)
        {
            Caption = 'Has Children';
            DataClassification = CustomerContent;
        }
        field(60; "Last Modified Date Time"; DateTime)
        {
            Caption = 'Last Modified Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(70; "Detail Field 1"; Text[100])
        {
            Caption = 'Detail Field 1';
            DataClassification = CustomerContent;
        }
        field(80; "Detail Field 2"; Text[100])
        {
            Caption = 'Detail Field 2';
            DataClassification = CustomerContent;
        }
        field(90; "Detail Field 3"; Text[100])
        {
            Caption = 'Detail Field 3';
            DataClassification = CustomerContent;
        }
        field(100; "Detail Field 4"; Text[100])
        {
            Caption = 'Detail Field 4';
            DataClassification = CustomerContent;
        }
        field(110; "Detail Field 5"; Text[100])
        {
            Caption = 'Detail Field 5';
            DataClassification = CustomerContent;
        }
        field(120; "Detail Field 6"; Text[100])
        {
            Caption = 'Detail Field 6';
            DataClassification = CustomerContent;
        }
        field(130; "Detail Field 7"; Text[100])
        {
            Caption = 'Detail Field 7';
            DataClassification = CustomerContent;
        }
        field(140; "Detail Field 8"; Text[100])
        {
            Caption = 'Detail Field 8';
            DataClassification = CustomerContent;
        }
        field(150; "Detail Field 9"; Text[100])
        {
            Caption = 'Detail Field 9';
            DataClassification = CustomerContent;
        }
        field(160; "Detail Field 10"; Text[100])
        {
            Caption = 'Detail Field 10';
            DataClassification = CustomerContent;
        }
        field(170; "Calc Field 1"; Decimal)
        {
            Caption = 'Calc Field 1';
            DataClassification = CustomerContent;
        }
        field(180; "Calc Field 2"; Decimal)
        {
            Caption = 'Calc Field 2';
            DataClassification = CustomerContent;
        }
        field(190; "Calc Field 3"; Decimal)
        {
            Caption = 'Calc Field 3';
            DataClassification = CustomerContent;
        }
        field(200; "Calc Field 4"; Decimal)
        {
            Caption = 'Calc Field 4';
            DataClassification = CustomerContent;
        }
        field(210; "Calc Field 5"; Decimal)
        {
            Caption = 'Calc Field 5';
            DataClassification = CustomerContent;
        }
        field(220; "Calc Field 6"; Decimal)
        {
            Caption = 'Calc Field 6';
            DataClassification = CustomerContent;
        }
        field(230; "Calc Field 7"; Decimal)
        {
            Caption = 'Calc Field 7';
            DataClassification = CustomerContent;
        }
        field(240; "Calc Field 8"; Decimal)
        {
            Caption = 'Calc Field 8';
            DataClassification = CustomerContent;
        }
        field(250; "Calc Field 9"; Decimal)
        {
            Caption = 'Calc Field 9';
            DataClassification = CustomerContent;
        }
        field(260; "Calc Field 10"; Decimal)
        {
            Caption = 'Calc Field 10';
            DataClassification = CustomerContent;
        }
        field(270; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(280; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(290; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
        }
        key(Key1; Code, "Salesperson Code")
        {
        }
    }

    procedure UpdateHasChildren(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary)
    begin
        ItemCategoryBuffer.SetRange("Parent Category", Code);
        "Has Children" := not ItemCategoryBuffer.IsEmpty();
        Modify();
    end;

    procedure HasChildren(var ItemCategoryBuffer: Record "NPR Item Category Buffer" temporary): Boolean
    begin
        ItemCategoryBuffer.SetRange("Parent Category", Code);
        exit(not ItemCategoryBuffer.IsEmpty());
    end;
}
