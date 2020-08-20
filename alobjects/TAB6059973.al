table 6059973 "Variety Value"
{
    // NPR4.16/JDH/20151022 CASE 225661 Changed NotBlank to yes, to avoid blank primary key value
    // VRT1.10/JDH/20151202 CASE 201022 Added Blocking of a Variety Table
    // VRT1.11/JDH /20160602 CASE 242940 Added Captions
    // NPR5.38/BR  /20171212 CASE 268786 Fixed Error messages
    // NPR5.47/JDH /20180913 CASE 327541  Changed field length of Table to 40 characters

    Caption = 'Variety Value';
    DataClassification = CustomerContent;
    DrillDownPageID = "Variety Value";
    LookupPageID = "Variety Value";

    fields
    {
        field(1; Type; Code[10])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Variety;
        }
        field(2; "Table"; Code[40])
        {
            Caption = 'Table';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Variety Table".Code WHERE(Type = FIELD(Type));
        }
        field(3; Value; Code[20])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            begin

                if Description = '' then begin
                    if StrLen(Value) = 1 then
                        Description := Value
                    else
                        Description := CopyStr(Value, 1, 1) + LowerCase(CopyStr(Value, 2));
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
        key(Key1; Type, "Table", Value)
        {
        }
        key(Key2; Type, "Table", "Sort Order")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        VRTCheck: Codeunit "Variety Check";
    begin
        //-VRT1.10
        if CheckTableLocked() then
            //-NPR5.38 [268786]
            //ERROR(Text001);
            Error(Text003, Value, Table);
        //+NPR5.38 [268786]
        //+VRT1.10

        VRTCheck.CheckDeleteVarietyValue(Rec);
    end;

    trigger OnInsert()
    begin
        //-VRT1.10
        if CheckTableLocked() then
            //-NPR5.38 [268786]
            //ERROR(Text001);
            Error(Text002, Value, Table);
        //+NPR5.38 [268786]
        //+VRT1.10

        AssignSortOrder;
    end;

    trigger OnRename()
    begin
        //-VRT1.10
        if CheckTableLocked() then
            Error(Text001);
        //+VRT1.10
    end;

    var
        Text001: Label 'The table %1 is locked for changes. Create a copy of the table under functions';
        Text002: Label 'Value %1 cannot be inserted in Variety Value for Variety table %2.  Create a copy of the table or change the Variety table manually.';
        Text003: Label 'Value %1 cannot be deleted from in Variety Value for Variety table %2.  Create a copy of the table or change the Variety table manually.';

    procedure AssignSortOrder()
    var
        VRTValue: Record "Variety Value";
        Dec: Decimal;
        NewSortOrder: Integer;
        DecSep: Text[1];
        Value2: Code[20];
    begin
        if Evaluate(Dec, Value) then begin
            //its a number. take the sort order from here (if possible)
            //convert '.' with ',' so we can use the number correct
            DecSep := GetDecimalSeperator;
            if DecSep = '.' then
                Value2 := ConvertStr(Value, ',', DecSep)
            else
                Value2 := ConvertStr(Value, '.', DecSep);
            Evaluate(Dec, Value2);

            //number 10 will be 100. Number 10,5 will be 105
            NewSortOrder := Round(Dec, 0.1) * 10;
            VRTValue.SetCurrentKey(Type, Table, "Sort Order");
            VRTValue.SetRange(Type, Type);
            VRTValue.SetRange(Table, Table);
            VRTValue.SetRange("Sort Order", NewSortOrder);
            if not VRTValue.IsEmpty then
                NewSortOrder := 0;
        end;

        if NewSortOrder = 0 then begin
            //either its not a number, or the number is already used for sorting
            VRTValue.SetCurrentKey(Type, Table, "Sort Order");
            VRTValue.SetRange(Type, Type);
            VRTValue.SetRange(Table, Table);
            if VRTValue.FindLast then begin
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

    procedure CheckTableLocked(): Boolean
    var
        VRTTable: Record "Variety Table";
    begin
        //-VRT1.10
        VRTTable.Get(Type, Table);
        exit(VRTTable."Lock Table");
        //+VRT1.10
    end;
}

