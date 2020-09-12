page 6060075 "NPR MM Members. Auto-Renew Log"
{
    // MM1.25/NPKNAV/20180122  CASE 300685 Transport MM1.25 - 22 January 2018
    // MM1.26/TSA /20180126 CASE 303696 Improved errors handling on auto-renew
    // #334163/JDH /20181109 CASE 334163 Added Caption to Object
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'Membership Auto-Renew Log';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
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

