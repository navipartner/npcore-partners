page 6151264 "NPR POS Unit Rcpt.Txt Profiles"
{
    // NPR5.54/BHR /20200210 CASE 389444 Page 'POS Unit Receipt Text Profile'

    Caption = 'POS Unit Receipt Text Profiles';
    CardPageID = "NPR POS Unit Rcpt.Text Profile";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Unit Rcpt.Txt Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text off"; "Sales Ticket Line Text off")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    var
                        RetailComment: Record "NPR Retail Comment";
                    begin
                        if "Sales Ticket Line Text off" = "Sales Ticket Line Text off"::Comment then begin
                            RetailComment.SetRange("Table ID", DATABASE::"NPR POS Unit");
                            RetailComment.SetRange("No.", Code);
                            RetailComment.SetRange(Integer, 1000);
                            PAGE.RunModal(PAGE::"NPR Retail Comments", RetailComment);
                        end;
                    end;
                }
                field("Sales Ticket Line Text1"; "Sales Ticket Line Text1")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text2"; "Sales Ticket Line Text2")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text3"; "Sales Ticket Line Text3")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text4"; "Sales Ticket Line Text4")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text5"; "Sales Ticket Line Text5")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text6"; "Sales Ticket Line Text6")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text7"; "Sales Ticket Line Text7")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text8"; "Sales Ticket Line Text8")
                {
                    ApplicationArea = All;
                }
                field("Sales Ticket Line Text9"; "Sales Ticket Line Text9")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

