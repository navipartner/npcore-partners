page 6014438 "NPR Posted Documents"
{
    // NPR5.53/ALPO/20191010 CASE 360297 Prepayment/layaway functionality additions

    Caption = 'Posted Documents';
    DataCaptionExpression = GetCaptionText;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "NPR Posted Doc. Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("FORMAT(""Source Record ID"")"; Format("Source Record ID"))
                {
                    ApplicationArea = All;
                    Caption = 'Source Record ID';
                    Visible = false;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Sell-to/Buy-from No."; "Sell-to/Buy-from No.")
                {
                    ApplicationArea = All;
                }
                field("Sell-to/Buy-from Name"; "Sell-to/Buy-from Name")
                {
                    ApplicationArea = All;
                }
                field("Bill-to/Pay-to No."; "Bill-to/Pay-to No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bill-to/Pay-to Name"; "Bill-to/Pay-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;

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
                ApplicationArea=All;

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
        if "Document Type" in ["Document Type"::"Prepayment Invoice", "Document Type"::"Prepayment Credit Memo"] then
            exit(StrSubstNo(PageCaptionTxt, Format("Source Record ID")));

        exit('');
    end;
}

