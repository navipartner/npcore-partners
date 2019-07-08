table 6060022 "GIM - Table Metadata"
{
    Caption = 'GIM - Table Metadata';

    fields
    {
        field(1;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(2;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(20;"Field ID";Integer)
        {
            Caption = 'Field ID';
        }
        field(30;"Node Name";Text[250])
        {
            Caption = 'Node Name';
        }
        field(40;Property;Text[250])
        {
            Caption = 'Property';
        }
        field(50;"Property Value";Text[250])
        {
            Caption = 'Property Value';
        }
        field(60;Level;Integer)
        {
            Caption = 'Level';
        }
        field(70;"Parent Entry No.";Integer)
        {
            Caption = 'Parent Entry No.';
        }
    }

    keys
    {
        key(Key1;"Table ID","Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure InsertLine(TableIDHere: Integer;FieldIDHere: Integer;NodeNameHere: Text;PropertyHere: Text;PropertyValueHere: Text;LevelHere: Integer;ParentEntryNo: Integer)
    var
        EntryNo: Integer;
    begin
        if (PropertyHere  = '') and (PropertyValueHere = '') then
          exit;

        SetRange("Table ID",TableIDHere);
        if FindLast then
          EntryNo := "Entry No." + 1
        else
          EntryNo := 1;

        Reset;
        Init;
        "Table ID" := TableIDHere;
        "Entry No." := EntryNo;
        "Field ID" := FieldIDHere;
        "Node Name" := NodeNameHere;
        Property := PropertyHere;
        "Property Value" := PropertyValueHere;
        Level := LevelHere;
        "Parent Entry No." := ParentEntryNo;
        Insert;
    end;

    procedure GetAttribute(FromWhere: Option FieldNode,TableRelationNode;TableID: Integer;FieldIDHere: Integer;AttributeName: Text[250]): Text[250]
    begin
        SetRange("Table ID",TableID);
        SetRange("Field ID",FieldIDHere);
        case FromWhere of
          0: SetRange("Node Name",'Field');
          1: SetRange("Node Name",'TableRelations');
        end;
        SetRange(Property,AttributeName);
        if FindFirst then
          exit("Property Value");
        exit('');
    end;
}

