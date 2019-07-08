page 6060005 "GIM - Mapping"
{
    // GIM1.00/MH/20150814  CASE 210725 Multi Level feature added

    Caption = 'GIM - Mapping';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "GIM - Mapping Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "Column Name","Column No.";
                ShowAsTree = true;
                field("Column Name";"Column Name")
                {
                    Style = Strong;
                    StyleExpr = ContainerElement;
                }
                field("Column No.";"Column No.")
                {
                    BlankZero = true;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = ContainerElement;
                }
                field("Parsed Text";"Parsed Text")
                {
                    Editable = false;
                }
                field("Allow Empty Value";"Allow Empty Value")
                {
                }
                field("Skip Processing";"Skip Processing")
                {
                }
                field(Level;Level)
                {
                }
                field("Parent Entry No.";"Parent Entry No.")
                {
                }
            }
            part(MappingTable;"GIM - Mapping Lines")
            {
                ShowFilter = false;
                SubPageLink = "Document No."=FIELD("Document No."),
                              "Column No."=FIELD("Column No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Priorities)
            {
                Caption = 'Priorities';
                Image = SetPriorities;
                RunObject = Page "GIM - Mapping Priorities";
                RunPageLink = "Document No."=FIELD("Document No.");
            }
            action("Fields")
            {
                Caption = 'Fields';
                Image = SelectField;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ContainerElement := IsContainer();
    end;

    var
        ContainerElement: Boolean;

    local procedure IsContainer(): Boolean
    var
        MappingTable: Record "GIM - Mapping Table";
    begin
        MappingTable.SetRange("Parent Entry No.","Entry No.");
        MappingTable.SetRange(Level,Level + 1);
        exit(MappingTable.FindFirst);
    end;
}

