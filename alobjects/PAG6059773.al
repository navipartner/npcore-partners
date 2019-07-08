page 6059773 "Member Card Transaction Logs"
{
    // NPR4.14/BHR/20150902 CASE 220758 Commented Code that does not make any sense
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Point Card - Transaction Logs';
    Editable = false;
    PageType = List;
    SourceTable = "Member Card Transaction Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Date";"Posting Date")
                {
                }
                field("Transaction No.";"Transaction No.")
                {
                }
                field("Card Code";"Card Code")
                {
                }
                field("Remaining Points";"Remaining Points")
                {
                }
                field(Points;Points)
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Value Entry No.";"Value Entry No.")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Editable)
            {
                Caption = 'Edit';
                Image = Edit;
                ShortCutKey = 'F2';

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
        end else Error('Sidste');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

        if Count = 0 then exit;
        if GetFilter("Card Code") = ''  then exit;
        if GetRangeMin("Card Code") = GetRangeMax("Card Code") then begin
          "Card Code" := GetRangeMin("Card Code");
        end else Error('Sidste');
    end;

    trigger OnOpenPage()
    var
        PointCardIssuedCards: Record "Member Card Issued Cards";
        PointCardTypes: Record "Member Card Types";
    begin
        //-NPR4.14
        //PointCardIssuedCards.RESET;
        //IF PointCardIssuedCards.FINDFIRST THEN;
        //PointCardTypes.GET(PointCardIssuedCards."Card Type");
        //SETFILTER("Posting Date",'%1..%2',CALCDATE(PointCardTypes."Expiration Calculation",TODAY),TODAY);
        //+NPR4.14
    end;
}

