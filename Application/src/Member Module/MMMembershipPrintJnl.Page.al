page 6060074 "NPR MM Membership Print Jnl"
{

    Caption = 'Membership Offline Print Journal';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Member Info Capture";
    SourceTableView = SORTING("Entry No.")
                      WHERE("Source Type" = CONST(PRINT_JNL));
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Member Entry No"; Rec."Member Entry No")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Member Entry No field';
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Card Entry No."; Rec."Card Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Card Entry No. field';
                }
                field("Information Context"; Rec."Information Context")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Information Context field';
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("External Member No"; Rec."External Member No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("External Card No."; Rec."External Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("External Card No. Last 4"; Rec."External Card No. Last 4")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Member Account Card action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Member Card action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Card Owner action';

                trigger OnAction()
                var
                    MemberInfoCapture: Record "NPR MM Member Info Capture";
                begin

                    CurrPage.SetSelectionFilter(MemberInfoCapture);
                    if (MemberInfoCapture.FindSet()) then begin
                        repeat
                            PrintOwner(MemberInfoCapture."Card Entry No.");
                        until (MemberInfoCapture.Next() = 0);
                    end;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Membership action';
            }
            action(OpenMembershipSetup)
            {
                Caption = 'MembershipSetup';
                Image = SetupList;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "NPR MM Membership Setup";
                ApplicationArea = All;
                ToolTip = 'Executes the MembershipSetup action';
            }
            action(Shipment)
            {
                Caption = 'Shipment';
                Image = Shipment;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Shipment action';

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

    local procedure PrintOwner(CardEntryNo: Integer)
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

