page 6151194 "NPR Ticket App. Area Setup"
{


    Caption = 'Ticket Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'Ticket Setup';
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                }
                field("Profile ID"; "Profile ID")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("NPR Ticket Essential"; "NPR Ticket Essential")
                {
                    ApplicationArea = All;
                }
                field("NPR Ticket Advanced"; "NPR Ticket Advanced")
                {
                    ApplicationArea = All;
                }
                field("NPR Ticket Dynamic Price"; "NPR Ticket Dynamic Price")
                {
                    ApplicationArea = All;
                }
                field("NPR Ticket Wallet"; "NPR Ticket Wallet")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
