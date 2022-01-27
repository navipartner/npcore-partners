table 6060044 "NPR Item Worksh. Variety Value"
{
    Access = Internal;
    Caption = 'Item Worksheet Variety Value';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Item Worksh.Vrty. Values";
    LookupPageID = "NPR Item Worksh.Vrty. Values";
    fields
    {
        field(1; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Item Worksh. Template";
        }
        field(2; "Worksheet Name"; Code[10])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Item Worksheet".Name WHERE("Item Template Name" = FIELD("Worksheet Template Name"));
        }
        field(3; "Worksheet Line No."; Integer)
        {
            Caption = 'Worksheet Line No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Worksheet Line"."Line No." WHERE("Worksheet Template Name" = FIELD("Worksheet Template Name"),
                                                                    "Worksheet Name" = FIELD("Worksheet Name"));
        }
        field(4; Type; Code[10])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Variety";
        }
        field(5; "Table"; Code[20])
        {
            Caption = 'Table';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(6; Value; Code[50])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            begin
                if Description = '' then begin
                    if StrLen(Value) = 1 then
                        Description := CopyStr(Value, 1, MaxStrLen(Description))
                    else
                        Description := CopyStr(CopyStr(Value, 1, 1) + LowerCase(CopyStr(Value, 2)), 1, MaxStrLen(Description));
                end;
            end;
        }
        field(10; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", Type, "Table", Value)
        {
        }
        key(Key2; "Worksheet Line No.", Type, "Sort Order")
        {
        }
        key(Key3; "Worksheet Template Name", "Worksheet Name", "Worksheet Line No.", Type, "Table", "Sort Order")
        {
        }
        key(Key4; "Worksheet Template Name", "Worksheet Name", "Sort Order")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
    end;

    trigger OnInsert()
    begin
        AssignSortOrder();
    end;

    procedure AssignSortOrder()
    var
        VRTValue: Record "NPR Item Worksh. Variety Value";
        Value2: Code[50];
        Dec: Decimal;
        NewSortOrder: Integer;
        DecSep: Text[1];
        IsNumber: Boolean;
    begin
        IsNumber := Evaluate(Dec, Value);
        if not IsNumber then begin
            //convert '.' with ',' so we can use the number correct
            DecSep := GetDecimalSeperator();
            Value2 := DelChr(Value, '=', DecSep);
            if DecSep = '.' then
                Value2 := ConvertStr(Value2, ',', DecSep)
            else
                Value2 := ConvertStr(Value2, '.', DecSep);
            IsNumber := Evaluate(Dec, Value2);
        end;
        if IsNumber then begin
            //its a number. take the sort order from here (if possible)
            //number 10 will be 100. Number 10,5 will be 105
            NewSortOrder := Round(Dec, 0.1) * 10;
            VRTValue.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Sort Order");
            VRTValue.SetRange("Worksheet Template Name", "Worksheet Template Name");
            VRTValue.SetRange("Worksheet Name", "Worksheet Name");
            VRTValue.SetRange("Sort Order", NewSortOrder);
            if not VRTValue.IsEmpty then
                NewSortOrder := 0;
        end;

        if NewSortOrder = 0 then begin
            //either its not a number, or the number is already used for sorting
            VRTValue.SetCurrentKey("Worksheet Template Name", "Worksheet Name", "Sort Order");
            VRTValue.SetRange("Worksheet Template Name", "Worksheet Template Name");
            VRTValue.SetRange("Worksheet Name", "Worksheet Name");
            if VRTValue.FindLast() then begin
                NewSortOrder := Round(VRTValue."Sort Order", 10, '<');
                NewSortOrder += 10;
            end else
                NewSortOrder := 10;

        end;
        "Sort Order" := NewSortOrder;
    end;

    procedure GetDecimalSeperator(): Text[1]
    var
        Dec: Decimal;
    begin
        Dec := 1.2;
        if StrPos(Format(Dec), '.') <> 0 then
            exit('.')
        else
            exit(',');
    end;
}

