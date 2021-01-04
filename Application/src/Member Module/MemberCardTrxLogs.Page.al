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
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Transaction No."; "Transaction No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transaction No. field';
                }
                field("Card Code"; "Card Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Code field';
                }
                field("Remaining Points"; "Remaining Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Remaining points field';
                }
                field(Points; Points)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Value Entry No."; "Value Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Value Entry No. field';
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
                ToolTip = 'Executes the Edit action';

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

