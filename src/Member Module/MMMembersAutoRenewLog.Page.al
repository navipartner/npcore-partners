page 6060075 "NPR MM Members. Auto-Renew Log"
{

    Caption = 'Membership Auto-Renew Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Member Info Capture";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Response Status"; "Response Status")
                {
                    ApplicationArea = All;
                }
                field("Response Message"; "Response Message")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Membership)
            {
                Caption = 'Membership';
                Image = CustomerList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");
                ApplicationArea = All;
            }
        }
    }
}

