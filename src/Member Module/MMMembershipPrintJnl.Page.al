page 6060074 "NPR MM Membership Print Jnl"
{
    // MM1.25/TSA /20180116 CASE 299537 Initial Version
    // MM1.26/TSA /20180213 CASE 299537 Added Document No. to Jnl for grouping per order
    // MM1.33/TSA /20180801 CASE 323652 Added the possibility to navigate to the NAV Shipment page
    // #334163/JDH /20181109 CASE 334163 Added Caption to Actions
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'Membership Offline Print Journal';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MM Member Info Capture";
    SourceTableView = SORTING("Entry No.")
                      WHERE("Source Type" = CONST(PRINT_JNL));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Member Entry No"; "Member Entry No")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Card Entry No."; "Card Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Information Context"; "Information Context")
                {
                    ApplicationArea = All;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field("External Member No"; "External Member No")
                {
                    ApplicationArea = All;
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = All;
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("External Card No."; "External Card No.")
                {
                    ApplicationArea = All;
                }
                field("External Card No. Last 4"; "External Card No. Last 4")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
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
                PromotedCategory = "Report";
                ApplicationArea=All;

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
                PromotedCategory = "Report";
                PromotedIsBig = true;
                ApplicationArea=All;

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
                PromotedCategory = "Report";
                PromotedIsBig = true;
                ApplicationArea=All;

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
            action(Membership)
            {
                Caption = 'Membership';
                Ellipsis = true;
                Image = CustomerList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Membership Card";
                RunPageLink = "Entry No." = FIELD("Membership Entry No.");
                ApplicationArea=All;
            }
            action(MembershipSetup)
            {
                Caption = 'MembershipSetup';
                Image = SetupList;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "NPR MM Membership Setup";
                ApplicationArea=All;
            }
            action(Shipment)
            {
                Caption = 'Shipment';
                Image = Shipment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    SalesShipmentHeader: Record "Sales Shipment Header";
                    PostedSalesShipment: Page "Posted Sales Shipment";
                    PostedSalesShipments: Page "Posted Sales Shipments";
                begin

                    //-MM1.33 [323652]
                    SalesShipmentHeader.SetFilter("External Document No.", '=%1', Rec."Document No.");
                    if (SalesShipmentHeader.IsEmpty()) then begin
                        SalesShipmentHeader.Reset;
                        SalesShipmentHeader.SetFilter("NPR External Order No.", '=%1', Rec."Document No.");
                    end;

                    if ((SalesShipmentHeader.FindFirst()) and (Rec."Document No." <> '')) then begin
                        PostedSalesShipment.SetRecord(SalesShipmentHeader);
                        PostedSalesShipment.Run();
                    end else begin
                        Error(NoShippingFound, Rec."Document No.");
                    end;
                    //+MM1.33 [323652]
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
        MembershipRole: Record "NPR MM Membership Role";
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

        MemberCard.Get("Card Entry No.");
        MemberCard.SetRecFilter();
        MemberCardOwner.SetTableView(MemberCard);

        MemberCardOwner.Run();
    end;
}

