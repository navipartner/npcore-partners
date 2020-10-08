page 6059773 "NPR Member Card Trx Logs"
{

    Caption = 'Point Card - Transaction Logs';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Member Card Trx Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Card Code"; "Card Code")
                {
                    ApplicationArea = All;
                }
                field("Remaining Points"; "Remaining Points")
                {
                    ApplicationArea = All;
                }
                field(Points; Points)
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Value Entry No."; "Value Entry No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Editable")
            {
                Caption = 'Edit';
                Image = Edit;
                ShortCutKey = 'F2';
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CurrPage.Editable(true);
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

        if GetRangeMin("Card Code") = '' then exit;
        if GetRangeMin("Card Code") = GetRangeMax("Card Code") then begin
            "Card Code" := GetRangeMin("Card Code");
        end else
            Error('Sidste');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

        if Count = 0 then exit;
        if GetFilter("Card Code") = '' then exit;
        if GetRangeMin("Card Code") = GetRangeMax("Card Code") then begin
            "Card Code" := GetRangeMin("Card Code");
        end else
            Error('Sidste');
    end;

    trigger OnOpenPage()
    var
        PointCardIssuedCards: Record "NPR Member Card Issued Cards";
        PointCardTypes: Record "NPR Member Card Types";
    begin

        //PointCardIssuedCards.RESET;
        //IF PointCardIssuedCards.FindFirst THEN;
        //PointCardTypes.GET(PointCardIssuedCards."Card Type");
        //SETFILTER("Posting Date",'%1..%2',CALCDATE(PointCardTypes."Expiration Calculation",TODAY),TODAY);

    end;
}

