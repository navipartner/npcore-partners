page 6151584 "Event Exch. Int. Email Summary"
{
    // NPR5.39/TJ  /20180214 CASE 285388 New object

    Caption = 'Event Exch. Int. Email Summary';
    Editable = false;
    PageType = Worksheet;
    SourceTable = "Event Exc. Int. Summary Buffer";
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
                }
                field("E-mail Account"; "E-mail Account")
                {
                    ApplicationArea = All;
                }
                field(Source; Source)
                {
                    ApplicationArea = All;
                    StyleExpr = ColorStyle;
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
        EventEWSMgt: Codeunit "Event EWS Management";
        ColorStyle: Text;
}

