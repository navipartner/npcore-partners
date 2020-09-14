page 6151194 "NPR Ticket App. Area Setup"
{


    Caption = 'Ticket Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'Ticket Setup';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company Name"; "Company Name")
                {

                }
                field("Profile ID"; "Profile ID")
                {

                }
                field("User ID"; "User ID")
                {

                }
                field("NPR Ticket Essential"; "NPR Ticket Essential")
                {

                }
                field("NPR Ticket Advanced"; "NPR Ticket Advanced")
                {

                }
                field("NPR Ticket Dynamic Price"; "NPR Ticket Dynamic Price")
                {

                }
                field("NPR Ticket Wallet"; "NPR Ticket Wallet")
                {

                }
            }
        }
    }

}
