page 6184869 "NPR MM Subs. Payment Gateways"
{
    Extensible = False;
    Caption = 'Subscription Payment Gateways';
    PageType = List;
    SourceTable = "NPR MM Subs. Payment Gateway";
    UsageCategory = Administration;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Integration Type"; Rec."Integration Type")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Integration Type field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Integration Type field.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ShowSetupCard)
            {
                Caption = 'Show Setup Card';
                ToolTip = 'Shows the setup card for the selected Payment Gateway';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ISubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
                begin
                    ISubscrPaymentIHandler := Rec."Integration Type";
                    ISubscrPaymentIHandler.RunSetupCard(Rec.Code);
                end;
            }
        }
    }
}
