page 6151559 "NPR NpXml Templ. Trigger List"
{
    AutoSplitKey = true;
    Caption = 'Xml Template Triggers';
    CardPageID = "NPR NpXml Template Card";
    DelayedInsert = true;
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
                IndentationColumn = Rec.Level;
                IndentationControls = "Table Name";
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Insert Trigger"; Rec."Insert Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insert Trigger field';
                }
                field("Modify Trigger"; Rec."Modify Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Modify Trigger field';
                }
                field("Delete Trigger"; Rec."Delete Trigger")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delete Trigger field';
                }
                field(Comment; Rec.Comment)
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

