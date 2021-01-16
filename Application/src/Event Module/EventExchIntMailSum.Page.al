page 6151584 "NPR Event Exch. Int. Mail Sum."
{
    // NPR5.39/TJ  /20180214 CASE 285388 New object

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
                IndentationColumn = Indentation;
                ShowAsTree = true;
                field("Exchange Item"; "Exchange Item")
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStyle;
                    ToolTip = 'Specifies the value of the Exchange Item field';
                }
                field("E-mail Account"; "E-mail Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Account field';
                }
                field(Source; Source)
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStyle;
                    ToolTip = 'Specifies the value of the Source field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        EventEWSMgt.ExchIntSummaryApplyStyleExpr(Rec, ColorStyle);
    end;

    var
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        ColorStyle: Text;
}

