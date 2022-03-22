page 6151194 "NPR Ticket App. Area Setup"
{
    Extensible = False;
    Caption = 'Ticket Application Area Setup';
    PageType = List;
    SourceTable = "Application Area Setup";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'Ticket Setup';
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Profile ID"; Rec."Profile ID")
                {

                    ToolTip = 'Specifies the value of the Profile ID field';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Ticket Essential"; Rec."NPR Ticket Essential")
                {

                    ToolTip = 'Specifies the value of the NPR Ticket Essential field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Ticket Advanced"; Rec."NPR Ticket Advanced")
                {

                    ToolTip = 'Specifies the value of the NPR Ticket Advanced field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Ticket Dynamic Price"; Rec."NPR Ticket Dynamic Price")
                {

                    ToolTip = 'Specifies the value of the NPR Ticket Dynamic Price field';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Ticket Wallet"; Rec."NPR Ticket Wallet")
                {

                    ToolTip = 'Specifies the value of the NPR Ticket Wallet field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
