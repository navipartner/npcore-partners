page 6060031 "GIM - Map. Table Field Filters"
{
    Caption = 'Filters';
    PageType = ListPart;
    SourceTable = "GIM - Mapping Table Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field ID";"Field ID")
                {
                    Editable = false;
                }
                field("Field Caption";"Field Caption")
                {
                }
                field("Field Type";"Field Type")
                {
                    Editable = false;
                }
                field("Automatically Created";"Automatically Created")
                {
                    Editable = false;
                }
                field("Find Filter";"Find Filter")
                {
                }
                field("Filter Value Type";"Filter Value Type")
                {
                }
                field("Filter Value";"Filter Value")
                {
                    Editable = ValueEditable;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        ValueEditable := "Filter Value Type" <> "Filter Value Type"::Specific;
    end;

    var
        [InDataSet]
        ValueEditable: Boolean;
}

