page 6184965 "NPR MM Pending Customer Update"
{
    Extensible = False;
    Caption = 'Scheduled Customer Updates';
    PageType = List;
    Editable = false;
    SourceTable = "NPR MM Pending Customer Update";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value for Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Entry No."; Rec.MembershipEntryNo)
                {
                    ToolTip = 'Specifies the value for Membership Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value for Customer No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ToolTip = 'Specifies the value for Customer Config. Template Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec.MembershipCode)
                {
                    ToolTip = 'Specifies the value for Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ToolTip = 'Specifies the value for Valid From Date field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Update Processed"; Rec."Update Processed")
                {
                    ToolTip = 'Specifies if the update has been processed for this entry';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApplyUpdate)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Apply Update';
                Image = UpdateUnitCost;
                ToolTip = 'Applies the pending updates to the customer and membership record.';
                Scope = Repeater;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                var
                    UpdateCustomerPending: Codeunit "NPR MM Update Customer Pending";
                begin
                    UpdateCustomerPending.ApplyUpdate(Rec);
                    Commit();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
