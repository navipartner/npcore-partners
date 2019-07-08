page 6060029 "GIM - Import Entities Subpage"
{
    Caption = 'Entities';
    Editable = false;
    PageType = ListPart;
    SourceTable = "GIM - Import Entity";
    SourceTableView = SORTING("Row No.","Table ID","Column No.","Field ID");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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

