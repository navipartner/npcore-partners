page 6151559 "NPR NpXml Templ. Trigger List"
{
    Extensible = False;
    Caption = 'Xml Template Triggers';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR NpXml Template Trigger";
    ApplicationArea = NPRRetail;

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

                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Insert Trigger"; Rec."Insert Trigger")
                {

                    ToolTip = 'Specifies the value of the Insert Trigger field';
                    ApplicationArea = NPRRetail;
                }
                field("Modify Trigger"; Rec."Modify Trigger")
                {

                    ToolTip = 'Specifies the value of the Modify Trigger field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Trigger"; Rec."Delete Trigger")
                {

                    ToolTip = 'Specifies the value of the Delete Trigger field';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {

                    Style = Attention;
                    StyleExpr = HasNoLinks;
                    ToolTip = 'Specifies the value of the Comment field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        [InDataSet]
        HasNoLinks: Boolean;
}

