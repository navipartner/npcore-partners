page 6014438 "NPR Posted Documents"
{
    // NPR5.53/ALPO/20191010 CASE 360297 Prepayment/layaway functionality additions

    Caption = 'Posted Documents';
    DataCaptionExpression = GetCaptionText;
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Source Record ID field';
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Sell-to/Buy-from No."; "Sell-to/Buy-from No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to/Buy-from No. field';
                }
                field("Sell-to/Buy-from Name"; "Sell-to/Buy-from Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to/Buy-from Name field';
                }
                field("Bill-to/Pay-to No."; "Bill-to/Pay-to No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Bill-to/Pay-to No. field';
                }
                field("Bill-to/Pay-to Name"; "Bill-to/Pay-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Bill-to/Pay-to Name field';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including VAT field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Card action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the &Navigate action';

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

