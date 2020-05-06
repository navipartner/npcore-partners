page 6151264 "POS Unit Receipt Text Profiles"
{
    // NPR5.54/BHR /20200210 CASE 389444 Page 'POS Unit Receipt Text Profile'

    Caption = 'POS Unit Receipt Text Profiles';
    CardPageID = "POS Unit Receipt Text Profile";
    Editable = false;
    PageType = List;
    SourceTable = "POS Unit Receipt Text Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
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

