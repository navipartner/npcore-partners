page 6060003 "GIM - Mapping Lines"
{
    Caption = 'Mapping Lines';
    PageType = List;
    SourceTable = "GIM - Mapping Table Line";

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
                    Editable = false;
                }
                field("Find Record";"Find Record")
                {
                }
                field("If Found";"If Found")
                {
                }
                field("If Not Found";"If Not Found")
                {
                }
                field("Data Action";"Data Action")
                {
                }
                field(Note;Note)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Fields")
            {
                Caption = 'Fields';
                Image = SelectField;

                trigger OnAction()
                begin
                    ShowFields();
                end;
            }
        }
    }
}

