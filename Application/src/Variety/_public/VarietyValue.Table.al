table 6059973 "NPR Variety Value"
{
    Caption = 'Variety Value';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Variety Value";
    LookupPageId = "NPR Variety Value";

    fields
    {
        field(1; Type; Code[10])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Variety";
        }
        field(2; "Table"; Code[40])
        {
            Caption = 'Table';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR Variety Table".Code where(Type = field(Type));
        }
        field(3; Value; Code[50])
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

        field(6151479; "Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
    }

    keys
    {
        key(Key1; Type, "Table", Value)
        {
        }
        key(Key2; Type, "Table", "Sort Order")
        {
        }
        key(Key3; "Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(Key4; SystemRowVersion)
        {
        }
#ENDIF
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        VRTCheck: Codeunit "NPR Variety Check";
    begin
        if CheckTableLocked() then
            Error(Text003, Value, Table);

        VRTCheck.CheckDeleteVarietyValue(Rec);
    end;

    trigger OnInsert()
    begin
        if CheckTableLocked() then
            Error(Text002, Value, Table);

        AssignSortOrder();
    end;

    trigger OnRename()
    begin
        if CheckTableLocked() then
            Error(Text001);
    end;

    var
        Text001: Label 'The table %1 is locked for changes. Create a copy of the table under functions';
        Text002: Label 'Value %1 cannot be inserted in Variety Value for Variety table %2.  Create a copy of the table or change the Variety table manually.';
        Text003: Label 'Value %1 cannot be deleted from in Variety Value for Variety table %2.  Create a copy of the table or change the Variety table manually.';

    internal procedure AssignSortOrder()
    var
        VRTValue: Record "NPR Variety Value";
        NewSortOrder: Integer;
        Handled: Boolean;
    begin
        OnBeforeSetSortOrder(Rec, NewSortOrder, Handled);
        if Handled then begin
            "Sort Order" := NewSortOrder;
            exit;
        end;
        NewSortOrder := FindNewSortOrder(Rec.Value);

        if NewSortOrder = 0 then begin
            //either its not a number, or the number is already used for sorting
            VRTValue.SetCurrentKey(Type, Table, "Sort Order");
            VRTValue.SetRange(Type, Type);
            VRTValue.SetRange(Table, Table);
            if VRTValue.FindLast() then begin
                NewSortOrder := Round(VRTValue."Sort Order", 10, '<');
                NewSortOrder += 10;
            end else
                NewSortOrder := 10;

        end;
        "Sort Order" := NewSortOrder;
    end;

    internal procedure GetDecimalSeperator(): Text[1]
    var
        Dec: Decimal;
    begin
        Dec := 1.2;
        if StrPos(Format(Dec), '.') <> 0 then
            exit('.')
        else
            exit(',');
    end;

    internal procedure FindNewSortOrder(ValueToCheck: Code[50]): Integer
    var
        VarietyVal: Record "NPR Variety Value";
        DecSep: Text[1];
        Value2: Code[20];
        Dec: Decimal;
        RoundDec: Decimal;
        SortOrder: Integer;
    begin
        if not Evaluate(Dec, ValueToCheck) then
            exit(0);

        //its a number. take the sort order from here (if possible)
        //convert '.' with ',' so we can use the number correct
        DecSep := GetDecimalSeperator();
        if DecSep = '.' then
            Value2 := CopyStr(ConvertStr(ValueToCheck, ',', DecSep), 1, MaxStrLen(Value2))
        else
            Value2 := CopyStr(ConvertStr(ValueToCheck, '.', DecSep), 1, MaxStrLen(Value2));

        if CheckIfMoreThanOneDecimalSeparator(Value2, DecSep) then
            exit(0);

        if not Evaluate(Dec, Value2) then
            exit(0);

        //number 10 will be 100. Number 10,5 will be 105
        RoundDec := Round(Dec, 0.1) * 10;
        if CheckForIntOverflow(RoundDec) then
            exit(0);

        SortOrder := RoundDec;
        VarietyVal.SetCurrentKey(Type, Table, "Sort Order");
        VarietyVal.SetRange(Type, Type);
        VarietyVal.SetRange(Table, Table);
        VarietyVal.SetRange("Sort Order", SortOrder);
        if not VarietyVal.IsEmpty then
            exit(0);

        exit(SortOrder);
    end;

    internal procedure CheckIfMoreThanOneDecimalSeparator(ValueToCheck: Code[20]; DecSeparator: Text[1]): Boolean
    var
        ValueWithoutDecSep: Code[20];
    begin
        ValueWithoutDecSep := DelChr(ValueToCheck, '=', DecSeparator);
        exit(StrLen(ValueToCheck) - StrLen(ValueWithoutDecSep) > 1);
    end;

    internal procedure CheckForIntOverflow(DecToCheck: Decimal): Boolean
    begin
        exit(Abs(DecToCheck) > 2147483647);
    end;

    internal procedure CheckTableLocked(): Boolean
    var
        VRTTable: Record "NPR Variety Table";
    begin
        VRTTable.Get(Type, Table);
        exit(VRTTable."Lock Table");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSortOrder(VarietyValue: Record "NPR Variety Value"; var SortOrder: Integer; var Handled: Boolean)
    begin
    end;
}

