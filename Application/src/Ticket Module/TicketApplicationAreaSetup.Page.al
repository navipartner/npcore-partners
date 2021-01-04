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
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Profile ID"; "Profile ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Profile ID field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("NPR Ticket Essential"; "NPR Ticket Essential")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Ticket Essential field';
                }
                field("NPR Ticket Advanced"; "NPR Ticket Advanced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Ticket Advanced field';
                }
                field("NPR Ticket Dynamic Price"; "NPR Ticket Dynamic Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Ticket Dynamic Price field';
                }
                field("NPR Ticket Wallet"; "NPR Ticket Wallet")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Ticket Wallet field';
                }
            }
        }
    }

}
