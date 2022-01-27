page 6014438 "NPR Posted Documents"
{
    Extensible = False;
    // NPR5.53/ALPO/20191010 CASE 360297 Prepayment/layaway functionality additions

    Caption = 'Posted Documents';
    DataCaptionExpression = GetCaptionText();
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Posted Doc. Buffer";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Source Record ID"; Format(Rec."Source Record ID"))
                {

                    Caption = 'Source Record ID';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Record ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Type"; Rec."Document Type")
                {

                    ToolTip = 'Specifies the value of the Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Document No."; Rec."External Document No.")
                {

                    ToolTip = 'Specifies the value of the External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Date"; Rec."Document Date")
                {

                    ToolTip = 'Specifies the value of the Document Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to/Buy-from No."; Rec."Sell-to/Buy-from No.")
                {

                    ToolTip = 'Specifies the value of the Sell-to/Buy-from No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Sell-to/Buy-from Name"; Rec."Sell-to/Buy-from Name")
                {

                    ToolTip = 'Specifies the value of the Sell-to/Buy-from Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Bill-to/Pay-to No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to/Pay-to Name"; Rec."Bill-to/Pay-to Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Bill-to/Pay-to Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {

                    ToolTip = 'Specifies the value of the Amount Including VAT field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F7';

                ToolTip = 'Executes the Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowDocumentCard();
                end;
            }
            action("&Navigate")
            {
                Caption = '&Navigate';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the &Navigate action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.Navigate();
                end;
            }
        }
    }

    var
        PageCaptionTxt: Label '%1 - prepayments';

    local procedure GetCaptionText(): Text
    begin
        if Rec."Document Type" in [Rec."Document Type"::"Prepayment Invoice", Rec."Document Type"::"Prepayment Credit Memo"] then
            exit(StrSubstNo(PageCaptionTxt, Format(Rec."Source Record ID")));

        exit('');
    end;
}

