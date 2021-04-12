page 6151584 "NPR Event Exch. Int. Mail Sum."
{
    Caption = 'Event Exch. Int. Email Summary';
    Editable = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Event Exc.Int.Summ. Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec.Indentation;
                ShowAsTree = true;
                field("Exchange Item"; Rec."Exchange Item")
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStyle;
                    ToolTip = 'Specifies the value of the Exchange Item field';
                }
                field("E-mail Account"; Rec."E-mail Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Account field';
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStyle;
                    ToolTip = 'Specifies the value of the Source field';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EventEWSMgt.ExchIntSummaryApplyStyleExpr(Rec, ColorStyle);
    end;

    var
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        ColorStyle: Text;
}

