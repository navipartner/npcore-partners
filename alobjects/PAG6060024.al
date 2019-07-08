page 6060024 "GIM - Mapping Table Field Spec"
{
    AutoSplitKey = true;
    Caption = 'GIM - Mapping Table Field Spec';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "GIM - Mapping Table Field Spec";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Used For";"Used For")
                {
                    Editable = false;
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("File Value";"File Value")
                {
                    Editable = false;
                }
                field("Map To";"Map To")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Add More Values")
            {
                Caption = 'Add More Values';
                Image = Add;

                trigger OnAction()
                var
                    MapTableField: Record "GIM - Mapping Table Field";
                begin
                    MapTableField.Get("Document No.","Doc. Type Code","Sender ID","Version No.","Mapping Table Line No.","Field ID");
                    AddLine(MapTableField,"Column No.","Used For");
                end;
            }
        }
    }
}

