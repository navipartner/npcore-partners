page 6151559 "NPR NpXml Templ. Trigger List"
{
    Caption = 'Xml Template Triggers';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR NpXml Template Trigger";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = "Table Name";
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Insert Trigger"; "Insert Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insert Trigger field';
                }
                field("Modify Trigger"; "Modify Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify Trigger field';
                }
                field("Delete Trigger"; "Delete Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Trigger field';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Comment field';
                }
            }
        }
    }

    var
        [InDataSet]
        HasNoLinks: Boolean;
}

