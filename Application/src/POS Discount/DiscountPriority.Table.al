table 6014417 "NPR Discount Priority"
{
    Caption = 'Discount Priority';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempObject: Record AllObj temporary;
            begin
                Clear(TempObject);
                SetupObjectNoList(TempObject);
                if PAGE.RunModal(PAGE::"Table Objects", TempObject) = ACTION::LookupOK then begin
                    "Table ID" := TempObject."Object ID";
                    Validate("Table ID");
                end;
            end;

            trigger OnValidate()
            var
                TempObject: Record AllObj temporary;
            begin
                CalcFields("Table Name");
                SetupObjectNoList(TempObject);
                TempObject."Object Type" := TempObject."Object Type"::Table;
                TempObject."Object ID" := "Table ID";
                if not TempObject.Find then
                    FieldError("Table ID");
            end;
        }
        field(2; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(3; "Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(10; Disabled; Boolean)
        {
            Caption = 'Disabled';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(15; "Discount Calc. Codeunit ID"; Integer)
        {
            Caption = 'Discount Calc. Codeunit ID';
            Description = 'NPR5.31';
            DataClassification = CustomerContent;
        }
        field(20; "Discount Calc. Codeunit Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Discount Calc. Codeunit ID")));
            Caption = 'Discount Calc. Codeunit Name';
            Description = 'NPR5.31';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Cross Line Calculation"; Boolean)
        {
            Caption = 'Cross Line Calculation';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
        }
        key(Key2; Priority)
        {
        }
    }

    fieldgroups
    {
    }
    procedure SetupObjectNoList(var TempObject: Record AllObj temporary)
    var
        "Object": Record AllObj;
        DiscountPriorities: array[5] of Integer;
        Index: Integer;
        NumberOfObjects: Integer;
    begin
        NumberOfObjects := 4;
        DiscountPriorities[1] := DATABASE::"NPR Mixed Discount";
        DiscountPriorities[2] := DATABASE::"Sales Line Discount";
        DiscountPriorities[3] := DATABASE::"NPR Period Discount";
        DiscountPriorities[4] := DATABASE::"NPR Quantity Discount Header";

        Object.SetRange("Object Type", Object."Object Type"::Table);
        for Index := 1 to NumberOfObjects do begin
            Object.SetRange("Object ID", DiscountPriorities[Index]);
            if Object.FindFirst then begin
                TempObject := Object;
                TempObject.Insert;
            end;
        end;
    end;
}

