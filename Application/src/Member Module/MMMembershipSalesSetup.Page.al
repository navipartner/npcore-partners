page 6060125 "NPR MM Membership Sales Setup"
{
    Extensible = False;

    Caption = 'Membership Sales Setup';
    PageType = List;
    SourceTable = "NPR MM Members. Sales Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Business Flow Type"; Rec."Business Flow Type")
                {
                    ToolTip = 'Specifies the value of the Business Flow Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From Base"; Rec."Valid From Base")
                {
                    ToolTip = 'Specifies the value of the Valid From Base field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Cut-Off Date Calculation"; Rec."Sales Cut-Off Date Calculation")
                {
                    ToolTip = 'Specifies the value of the Sales Cut-Off Date Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From Date Calculation"; Rec."Valid From Date Calculation")
                {
                    ToolTip = 'Specifies the value of the Valid From Date Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Until Calculation"; Rec."Valid Until Calculation")
                {
                    ToolTip = 'Specifies the value of the Valid Until Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ToolTip = 'Specifies the value of the Duration Formula field';
                    ApplicationArea = NPRRetail;
                }
                field("Suggested Membercount In Sales"; Rec."Suggested Membercount In Sales")
                {
                    ToolTip = 'Specifies the value of the Suggested Membercount In Sales field';
                    ApplicationArea = NPRRetail;
                }
                field("Assign Loyalty Points On Sale"; Rec."Assign Loyalty Points On Sale")
                {
                    ToolTip = 'Specifies the value of the Assign Loyalty Points On Sale field';
                    ApplicationArea = NPRRetail;
                }
                field("Mixed Sale Policy"; Rec."Mixed Sale Policy")
                {
                    ToolTip = 'Specifies the value of the Mixed Sale Policy field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto-Renew To"; Rec."Auto-Renew To")
                {
                    ToolTip = 'Specifies the value of the Auto-Renew To field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto-Admit Member On Sale"; Rec."Auto-Admit Member On Sale")
                {
                    ToolTip = 'Specifies the value of the Auto-Admit Member On Sale field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Card Type Selection"; Rec."Member Card Type Selection")
                {
                    ToolTip = 'Specifies the value of the Member Card Type Selection field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Card Type"; Rec."Member Card Type")
                {
                    ToolTip = 'Specifies the value of the Member Card Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Magento M2 Membership Sign-up"; Rec."Magento M2 Membership Sign-up")
                {
                    ToolTip = 'Specifies the value of the Magento M2 Membership Sign-up field';
                    ApplicationArea = NPRRetail;
                }
                field("Age Constraint Type"; Rec."Age Constraint Type")
                {
                    ToolTip = 'Specifies the value of the Age Constraint Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Age Constraint (Years)"; Rec."Age Constraint (Years)")
                {
                    ToolTip = 'Specifies the value of the Age Constraint (Years) field';
                    ApplicationArea = NPRRetail;
                }
                field("Requires Guardian"; Rec."Requires Guardian")
                {
                    ToolTip = 'Specifies the value of the Requires Guardian field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Membership")
            {
                Caption = 'Create Membership';
                Ellipsis = true;
                Image = NewCustomer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                ToolTip = 'Executes the Create Membership action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    CreateMembership(Rec);
                end;
            }
            separator(Separator6150632)
            {
            }
            action("Import Members From File")
            {
                Caption = 'Import Members From File';
                Image = Import;
                RunObject = Codeunit "NPR MM Import Members";

                ToolTip = 'Executes the Import Members From File action';
                ApplicationArea = NPRRetail;
            }
            action("Failed Import Worksheet")
            {
                Caption = 'Failed Import Worksheet';
                Image = ImportLog;

                ToolTip = 'Executes the Failed Import Worksheet action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MemberInfoCaptureListPage: Page "NPR MM Member Capture List";
                    MemberInfoCapture: Record "NPR MM Member Info Capture";
                begin

                    MemberInfoCapture.SetFilter("Originates From File Import", '=%1', true);
                    MemberInfoCaptureListPage.SetTableView(MemberInfoCapture);
                    MemberInfoCaptureListPage.SetShowImportAction();
                    MemberInfoCaptureListPage.Run();
                end;
            }
        }
        area(navigation)
        {
            action("Membership Setup")
            {
                Caption = 'Membership Setup';
                Image = SetupList;
                RunObject = Page "NPR MM Membership Setup";

                ToolTip = 'Executes the Membership Setup action';
                ApplicationArea = NPRRetail;
            }
            action("Item List")
            {
                Caption = 'Item List';
                Image = List;
                RunObject = Page "Item List";

                ToolTip = 'Executes the Item List action';
                ApplicationArea = NPRRetail;
            }
            action(Memberships)
            {
                Caption = 'Memberships';
                Image = List;
                RunObject = Page "NPR MM Memberships";
                RunPageLink = "Membership Code" = FIELD("Membership Code");

                ToolTip = 'Executes the Memberships action';
                ApplicationArea = NPRRetail;
            }
            action("Community Setup")
            {
                Caption = 'Community Setup';
                Image = Group;
                RunObject = Page "NPR MM Member Community";

                ToolTip = 'Executes the Community Setup action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin

        Rec.SetFilter(Blocked, '=%1', false);
    end;

    procedure CreateMembership(MembershipSalesSetup: Record "NPR MM Members. Sales Setup")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipPage: Page "NPR MM Membership Card";
        Membership: Record "NPR MM Membership";
        ExternalCardNumber: Text[100];
        MembershipMgt: Codeunit "NPR MM Membership Mgt.";
        FOREIGN_MEMBERSHIP_CREATED: Label 'Foreign membership created with card number %1';
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");

        MemberCommunity.Get(MembershipSetup."Community Code");
        MemberCommunity.CalcFields("Foreign Membership");

        MemberInfoCapture.Init();
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
#pragma warning disable AA0139
        MemberInfoCapture."Receipt No." := DelChr(Format(CurrentDateTime(), 0, 9), '<=>', DelChr(Format(CurrentDateTime(), 0, 9), '<=>', '01234567890'));
#pragma warning restore
        MemberInfoCapture."Line No." := 1;
        MemberInfoCapture.Insert();

        ExternalCardNumber := MembershipMgt.CreateMembershipInteractive(MemberInfoCapture);

        if (ExternalCardNumber <> '') then begin
            if (MemberCommunity."Foreign Membership") then
                Message(FOREIGN_MEMBERSHIP_CREATED, ExternalCardNumber);

            if (not MemberCommunity."Foreign Membership") then begin
                Membership.Get(MemberInfoCapture."Membership Entry No.");
                MembershipPage.SetRecord(Membership);
                MembershipPage.Run();
            end;
        end;

        if (MemberInfoCapture.Get(MemberInfoCapture."Entry No.")) then
            MemberInfoCapture.Delete();

    end;
}

