page 6060074 "NPR MM Membership Print Jnl"
{
    Extensible = False;

    Caption = 'Membership Offline Print Journal';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Member Info Capture";
    SourceTableView = SORTING("Entry No.")
                      WHERE("Source Type" = CONST(PRINT_JNL));
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Entry No"; Rec."Member Entry No")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Entry No field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Entry No."; Rec."Card Entry No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Card Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Information Context"; Rec."Information Context")
                {

                    ToolTip = 'Specifies the value of the Information Context field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("External Member No"; Rec."External Member No")
                {

                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;
                }
                field("First Name"; Rec."First Name")
                {

                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Name"; Rec."Last Name")
                {

                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Card No."; Rec."External Card No.")
                {

                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Card No. Last 4"; Rec."External Card No. Last 4")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action(PrintAccountCardAction)
            {
                Caption = 'Member Account Card';
                Ellipsis = true;
                Image = PrintCheck;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";

                ToolTip = 'Executes the Member Account Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MemberInfoCapture: Record "NPR MM Member Info Capture";
                begin

                    CurrPage.SetSelectionFilter(MemberInfoCapture);
                    if (MemberInfoCapture.FindSet()) then begin
                        repeat
                            PrintMemberAccount(MemberInfoCapture."Member Entry No");
                        until (MemberInfoCapture.Next() = 0);
                    end;
                end;
            }
            action(PrintCardAction)
            {
                Caption = 'Member Card';
                Ellipsis = true;
                Image = PrintVoucher;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                ToolTip = 'Executes the Member Card action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MemberInfoCapture: Record "NPR MM Member Info Capture";
                begin

                    CurrPage.SetSelectionFilter(MemberInfoCapture);
                    if (MemberInfoCapture.FindSet()) then begin
                        repeat
                            PrintCard(MemberInfoCapture."Card Entry No.");
                        until (MemberInfoCapture.Next() = 0);
                    end;
                end;
            }
            action(PrintCardOwnerAction)
            {
                Caption = 'Card Owner';
                Image = PrintAttachment;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                ToolTip = 'Executes the Card Owner action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    MemberInfoCapture: Record "NPR MM Member Info Capture";
                begin

                    CurrPage.SetSelectionFilter(MemberInfoCapture);
                    if MemberInfoCapture.FindSet() then
                        repeat
                            PrintOwner();
                        until MemberInfoCapture.Next() = 0;
                end;
            }
        }
        area(navigation)
        {
            action(OpenMembershipCard)
            {
                Caption = 'Membership';
                Ellipsis = true;
                Image = CustomerList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");

                ToolTip = 'Executes the Membership action';
                ApplicationArea = NPRRetail;
            }
            action(OpenMembershipSetup)
            {
                Caption = 'MembershipSetup';
                Image = SetupList;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "NPR MM Membership Setup";

                ToolTip = 'Executes the MembershipSetup action';
                ApplicationArea = NPRRetail;
            }
            action(Shipment)
            {
                Caption = 'Shipment';
                Image = Shipment;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Shipment action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    SalesShipmentHeader: Record "Sales Shipment Header";
                    PostedSalesShipment: Page "Posted Sales Shipment";
                begin

                    SalesShipmentHeader.SetFilter("External Document No.", '=%1', Rec."Document No.");
                    if (SalesShipmentHeader.IsEmpty()) then begin
                        SalesShipmentHeader.Reset();
                        SalesShipmentHeader.SetFilter("NPR External Order No.", '=%1', Rec."Document No.");
                    end;

                    if ((SalesShipmentHeader.FindFirst()) and (Rec."Document No." <> '')) then begin
                        PostedSalesShipment.SetRecord(SalesShipmentHeader);
                        PostedSalesShipment.Run();
                    end else begin
                        Error(NoShippingFound, Rec."Document No.");
                    end;

                end;
            }
        }
    }

    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        NoShippingFound: Label 'No shipments found for reference %1.';

    local procedure PrintMemberAccount(MemberEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        Member.Get(MemberEntryNo);
        Member.SetRecFilter();

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (MembershipRole.FindSet()) then begin
            repeat
                Membership.Get(MembershipRole."Membership Entry No.");
                MembershipSetup.Get(Membership."Membership Code");

                MemberRetailIntegration.PrintMemberAccountCardWorker(Member, MembershipSetup);
            until (MembershipRole.Next() = 0);
        end;
    end;

    local procedure PrintCard(CardEntryNo: Integer)
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        MemberCard.Get(CardEntryNo);
        MemberCard.SetRecFilter();
        Membership.Get(MemberCard."Membership Entry No.");
        MembershipSetup.Get(Membership."Membership Code");

        MemberRetailIntegration.PrintMemberCardWorker(MemberCard, MembershipSetup);
    end;

    local procedure PrintOwner()
    var
        MemberCardOwner: Report "NPR MM Member Card Owner";
        MemberCard: Record "NPR MM Member Card";
    begin

        MemberCard.Get(Rec."Card Entry No.");
        MemberCard.SetRecFilter();
        MemberCardOwner.SetTableView(MemberCard);

        MemberCardOwner.Run();
    end;
}

