table 6014429 "NPR Retail Comment"
{
    Caption = 'Retail Comment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'Number';
            DataClassification = CustomerContent;
        }
        field(3; "No. 2"; Code[20])
        {
            Caption = 'Number 1';
            DataClassification = CustomerContent;
        }
        field(4; "Option"; Option)
        {
            Caption = 'Option';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9";
            DataClassification = CustomerContent;
        }
        field(5; "Option 2"; Option)
        {
            Caption = 'Option 1';
            OptionCaption = '0,1,2,3,4,5,6,7,8,9';
            OptionMembers = "0","1","2","3","4","5","6","7","8","9";
            DataClassification = CustomerContent;
        }
        field(6; "Integer"; Integer)
        {
            Caption = 'Integer';
            DataClassification = CustomerContent;
        }
        field(7; "Integer 2"; Integer)
        {
            Caption = 'Integer 1';
            DataClassification = CustomerContent;
        }
        field(8; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(9; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(11; Comment; Text[80])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(12; "Hide on printout"; Boolean)
        {
            Caption = 'Hide on printout';
            DataClassification = CustomerContent;
        }
        field(13; Attention; Text[30])
        {
            Caption = 'Attention';
            DataClassification = CustomerContent;
        }
        field(14; "Sales Person Code"; Code[10])
        {
            Caption = 'Sales Person Code';
            DataClassification = CustomerContent;
        }
        field(15; "Long Comment"; Text[250])
        {
            Caption = 'Long comment';
            DataClassification = CustomerContent;
        }
        field(16; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(17; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID", "No.", "No. 2", Option, "Option 2", "Integer", "Integer 2", "Line No.")
        {
        }
    }

    procedure SetupNewLine()
    var
        BemLinie: Record "NPR Retail Comment";
    begin
        BemLinie.SetRange("Table ID", "Table ID");
        BemLinie.SetRange("No.", "No.");
        BemLinie.SetRange("No. 2", "No. 2");
        BemLinie.SetRange(Option, Option);
        BemLinie.SetRange("Option 2", "Option 2");
        BemLinie.SetRange(Integer, Integer);
        BemLinie.SetRange("Integer 2", "Integer 2");
        if not BemLinie.Find('-') then
            Date := WorkDate();
    end;

    procedure Copylines(var from1: Record "NPR Retail Comment")
    var
        to1: Record "NPR Retail Comment";
        nextline: Integer;
        TableIDErr: Label 'You have to set table id';
    begin
        nextline := 10000;

        to1.CopyFilters(Rec);
        if to1.Find('+') then
            nextline := to1."Line No." + 10000;

        if from1.Find('-') then
            repeat
                Init();
                TransferFields(from1, false);
                if to1.GetFilter("Table ID") = '' then
                    Error(TableIDErr);
                Evaluate("Table ID", to1.GetFilter("Table ID"));

                if to1.GetFilter("No.") <> '' then
                    Evaluate("No.", to1.GetFilter("No."));
                if to1.GetFilter("No. 2") <> '' then
                    Evaluate("No. 2", to1.GetFilter("No. 2"));
                if to1.GetFilter(Option) <> '' then
                    Evaluate(Option, to1.GetFilter(Option));
                if to1.GetFilter("Option 2") <> '' then
                    Evaluate("Option 2", to1.GetFilter("Option 2"));
                if to1.GetFilter(Integer) <> '' then
                    Evaluate(Integer, to1.GetFilter(Integer));
                if to1.GetFilter("Integer 2") <> '' then
                    Evaluate("Integer 2", to1.GetFilter("Integer 2"));
                "Line No." := nextline;
                Insert(true);
                nextline += 10000;
            until from1.Next() = 0;
    end;
}

