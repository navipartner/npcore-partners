page 6060018 "GIM - Import Entities"
{
    Caption = 'GIM - Import Entities';
    DataCaptionFields = "Row No.";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GIM - Import Entity";
    SourceTableView = SORTING("Row No.","Table ID","Column No.","Field ID");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID";"Table ID")
                {
                }
                field("Table Caption";"Table Caption")
                {
                }
                field("Field ID";"Field ID")
                {
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("Current Value";"Current Value")
                {
                }
                field("New Value";"New Value")
                {
                    Style = StrongAccent;
                    StyleExpr = UseStyle;
                }
                field("Entity Action";"Entity Action")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        UseStyle := ("Entity Action" = "Entity Action"::Modify) and ("Current Value" <> "New Value");
    end;

    var
        [InDataSet]
        UseStyle: Boolean;
}

