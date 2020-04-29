page 6150711 "POS View Card"
{
    Caption = 'POS View Card';
    PageType = Card;
    SourceTable = "POS View";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field(View;View)
                {
                    Editable = Editable;
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        SetMarkup(View);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        View := GetMarkup();
        SetEditable();
    end;

    trigger OnAfterGetRecord()
    begin
        View := '';
        SetEditable();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        View := '';
        SetEditable();
    end;

    var
        View: Text;
        Editable: Boolean;

    local procedure SetEditable()
    begin
        Editable := CurrPage.Editable;
    end;
}

