page 6151265 "POS Unit Receipt Text Profile"
{
    // NPR5.54/JAKUBV/20200408  CASE 389444 Transport NPR5.54 - 8 April 2020

    Caption = 'POS Unit Receipt Text Profile';
    PageType = Card;
    SourceTable = "POS Unit Receipt Text Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field("Sales Ticket Line Text off";"Sales Ticket Line Text off")
                {

                    trigger OnAssistEdit()
                    var
                        RetailComment: Record "Retail Comment";
                    begin
                        if "Sales Ticket Line Text off" = "Sales Ticket Line Text off"::Comment then begin
                          RetailComment.SetRange("Table ID",DATABASE::"POS Unit");
                          RetailComment.SetRange("No.",Code);
                          RetailComment.SetRange(Integer,1000);
                          PAGE.RunModal(PAGE::"Retail Comments",RetailComment);
                        end;
                    end;
                }
                field("Sales Ticket Line Text1";"Sales Ticket Line Text1")
                {
                }
                field("Sales Ticket Line Text2";"Sales Ticket Line Text2")
                {
                }
                field("Sales Ticket Line Text3";"Sales Ticket Line Text3")
                {
                }
                field("Sales Ticket Line Text4";"Sales Ticket Line Text4")
                {
                }
                field("Sales Ticket Line Text5";"Sales Ticket Line Text5")
                {
                }
                field("Sales Ticket Line Text6";"Sales Ticket Line Text6")
                {
                }
                field("Sales Ticket Line Text7";"Sales Ticket Line Text7")
                {
                }
                field("Sales Ticket Line Text8";"Sales Ticket Line Text8")
                {
                }
                field("Sales Ticket Line Text9";"Sales Ticket Line Text9")
                {
                }
            }
        }
    }

    actions
    {
    }
}

