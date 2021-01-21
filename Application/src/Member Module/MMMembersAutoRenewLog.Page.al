page 6060075 "NPR MM Members. Auto-Renew Log"
{

    Caption = 'Membership Auto-Renew Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Response Status"; "Response Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Status field';
                }
                field("Response Message"; "Response Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response Message field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Membership action';
            }
        }
    }
}

