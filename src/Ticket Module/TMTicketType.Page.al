page 6059784 "NPR TM Ticket Type"
{
    // TM1.00/TSA/20150804  CASE 219658 - Added new fields
    // TM1.00/TSA/20151217  CASE 219658-01 NaviPartner Ticket Management
    // TM1.03/TSA/20160113  CASE 231260 Added new fields "Admission Registration"
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15/TSA/20160530  CASE 240831 Field 40 default true, hidden
    // TM1.16/TSA/20160816  CASE 245455 Transport TM1.16 - 19 July 2016
    // #258974/TSA/20161121  CASE 258974 Page Navigation enhancements -
    // TM1.18/TSA/20161220  CASE 261405 Added support for ticket to membership cross reference
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.27/TSA /20180125 CASE 269456 Print template support in Ticket module.
    // TM1.38/TSA /20181012 CASE 332109 Added NP-Pass fields/Functions

    Caption = 'Ticket Type';
    PageType = List;
    SourceTable = "NPR TM Ticket Type";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Related Ticket Type"; "Related Ticket Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Print Ticket"; "Print Ticket")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Print Object Type"; "Print Object Type")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("RP Template Code"; "RP Template Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Print Object ID"; "Print Object ID")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Admission Registration"; "Admission Registration")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("External Ticket Pattern"; "External Ticket Pattern")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Activation Method"; "Activation Method")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Configuration Source"; "Ticket Configuration Source")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Duration Formula"; "Duration Formula")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Ticket Entry Validation"; "Ticket Entry Validation")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Max No. Of Entries"; "Max No. Of Entries")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Is Ticket"; "Is Ticket")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Visible = false;
                }
                field("Membership Sales Item No."; "Membership Sales Item No.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("DIY Print Layout Code"; "DIY Print Layout Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("eTicket Activated"; "eTicket Activated")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("eTicket Type Code"; "eTicket Type Code")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Ticket Setup")
            {
                ToolTip = 'Navigate to ticket setup.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Setup";

            }
            action(Items)
            {
                ToolTip = 'Navigate to Item List.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Items';
                Image = ItemLines;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR Retail Item List";
                RunPageLink = "NPR Ticket Type" = FIELD(Code);

            }
            action(Admissions)
            {
                ToolTip = 'Navigate to Admission List.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Admissions';
                Image = WorkCenter;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket Admissions";

            }
            action("Ticket BOM")
            {
                ToolTip = 'Navigate to ticket contents setup.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Admission BOM';
                Image = BOM;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket BOM";

            }
            separator(Separator6014412)
            {
            }
            action("E-Mail Templates")
            {
                ToolTip = 'Setup templates for ticket e-mail.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'E-Mail Templates';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6060110));

            }
            action("SMS Template")
            {
                ToolTip = 'Setup templates for ticket SMS.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060110));

            }
            action("Edit Pass Template")
            {
                ToolTip = 'Define information sent to wallet.';
                ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                Caption = 'Edit Pass Template';
                Image = Template;
                Promoted = true;
                PromotedIsBig = true;


                trigger OnAction()
                begin
                    EditPassTemplate();
                end;
            }
        }
    }

    var
        FileManagement: Codeunit "File Management";

    procedure HideTickets()
    begin
        SetRange("Is Ticket", false);
    end;

    local procedure EditPassTemplate()
    begin

        Rec.EditPassTemplate();
        CurrPage.Update(true);
    end;
}

