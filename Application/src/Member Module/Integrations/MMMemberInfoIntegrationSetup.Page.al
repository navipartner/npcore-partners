page 6184877 "NPR MM Member Info. Int. Setup"
{
    Extensible = False;
    Caption = 'Member Info Integration Setup';
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    UsageCategory = Administration;
    DelayedInsert = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "NPR MM Member Info. Int. Setup";

    layout
    {
        area(Content)
        {
            group(Integrations)
            {
                ShowCaption = false;
                group("Customer Card")
                {
                    Caption = 'Customer Card';
                    field("CustCard RequestCustInfo Act."; Rec."CustCard RequestCustInfo Act.")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies the integration used for the Request Customer Information action.';
                    }
                }
                group("Member Info Capture Card")
                {
                    Caption = 'Member Info Capture Card';
                    field("MembCapt PhoneNo. OnAssistEdit"; Rec."MembCapt PhoneNo. OnAssistEdit")
                    {
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                        ToolTip = 'Specifies the integration used for the OnAssistEdit functionality of the Phone No. field.';
                    }
                }
                group("Return Request Info")
                {
                    Caption = 'Return Request Info';
                    field("Request Return Info"; Rec."Request Return Info")
                    {
                        ApplicationArea = NPRRetail;
                        Tooltip = 'Specifies the integration used for collection return information.';
                    }
                }
            }
            group(Setup)
            {
                ShowCaption = false;
                field("Implicit Phone No. Prefix"; Rec."Implicit Phone No. Prefix")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Tooltip = 'Specifies the implicit prefix for integrations using a phone number to send the request.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Return Information Collection Setup")
            {
                Caption = 'Return Information Collection Setup';
                RunObject = Page "NPR Return Info Collect Setup";
                ToolTip = 'Opens setup for collecting return information.';
                ApplicationArea = NPRRetail;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
