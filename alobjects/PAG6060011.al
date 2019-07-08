page 6060011 "GIM - Fields List"
{
    Caption = 'GIM - Fields List';
    Editable = false;
    PageType = List;
    SourceTable = "Field";
    SourceTableView = WHERE(Class=CONST(Normal),
                            Type=FILTER(<>BLOB));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(FieldName;FieldName)
                {
                }
                field("Field Caption";"Field Caption")
                {
                }
                field(PrimaryKey;PrimaryKey)
                {
                    Caption = 'Primary Key';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        PrimaryKey := false;
        RecRef.Open(TableNo);
        PrimaryKeyRef := RecRef.KeyIndex(1);
        for i := 1 to PrimaryKeyRef.FieldCount do begin
          FldRef := PrimaryKeyRef.FieldIndex(i);
          if not PrimaryKey then
            PrimaryKey := FldRef.Number = "No.";
        end;
        RecRef.Close;
    end;

    var
        PrimaryKey: Boolean;
        RecRef: RecordRef;
        PrimaryKeyRef: KeyRef;
        i: Integer;
        FldRef: FieldRef;
}

