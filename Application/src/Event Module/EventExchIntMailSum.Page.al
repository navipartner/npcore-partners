page 6151584 "NPR Event Exch. Int. Mail Sum."
{
    Extensible = False;
    Caption = 'Event Exch. Int. Email Summary';
    Editable = false;
    PageType = Worksheet;
    UsageCategory = Administration;

    SourceTable = "NPR Event Exc.Int.Summ. Buffer";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

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

                    StyleExpr = ColorStyle;
                    ToolTip = 'Specifies the value of the Exchange Item field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Account"; Rec."E-mail Account")
                {

                    ToolTip = 'Specifies the value of the E-mail Account field';
                    ApplicationArea = NPRRetail;
                }
                field(Source; Rec.Source)
                {

                    StyleExpr = ColorStyle;
                    ToolTip = 'Specifies the value of the Source field';
                    ApplicationArea = NPRRetail;
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

