page 6014438 "Posted Documents"
{
    // NPR5.53/ALPO/20191010 CASE 360297 Prepayment/layaway functionality additions

    Caption = 'Posted Documents';
    DataCaptionExpression = GetCaptionText;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Posted Document Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("FORMAT(""Source Record ID"")";Format("Source Record ID"))
                {
                    Caption = 'Source Record ID';
                    Visible = false;
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("External Document No.";"External Document No.")
                {
                }
                field("Document Date";"Document Date")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field("Sell-to/Buy-from No.";"Sell-to/Buy-from No.")
                {
                }
                field("Sell-to/Buy-from Name";"Sell-to/Buy-from Name")
                {
                }
                field("Bill-to/Pay-to No.";"Bill-to/Pay-to No.")
                {
                    Visible = false;
                }
                field("Bill-to/Pay-to Name";"Bill-to/Pay-to Name")
                {
                    Visible = false;
                }
                field("Currency Code";"Currency Code")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Amount Including VAT";"Amount Including VAT")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Card)
            {
                Caption = 'Card';
                Image = EditLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F7';

                trigger OnAction()
                begin
                    ShowDocumentCard;
                end;
            }
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Navigate;
                end;
            }
        }
    }

    var
        PageCaptionTxt: Label '%1 - prepayments';

    local procedure GetCaptionText(): Text
    begin
        if "Document Type" in ["Document Type"::"Prepayment Invoice","Document Type"::"Prepayment Credit Memo"] then
          exit(StrSubstNo(PageCaptionTxt,Format("Source Record ID")));

        exit('');
    end;
}

