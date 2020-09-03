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

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Related Ticket Type"; "Related Ticket Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Print Ticket"; "Print Ticket")
                {
                    ApplicationArea = All;
                }
                field("Print Object Type"; "Print Object Type")
                {
                    ApplicationArea = All;
                }
                field("RP Template Code"; "RP Template Code")
                {
                    ApplicationArea = All;
                }
                field("Print Object ID"; "Print Object ID")
                {
                    ApplicationArea = All;
                }
                field("Admission Registration"; "Admission Registration")
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
                field("External Ticket Pattern"; "External Ticket Pattern")
                {
                    ApplicationArea = All;
                }
                field("Activation Method"; "Activation Method")
                {
                    ApplicationArea = All;
                }
                field("Ticket Configuration Source"; "Ticket Configuration Source")
                {
                    ApplicationArea = All;
                }
                field("Duration Formula"; "Duration Formula")
                {
                    ApplicationArea = All;
                }
                field("Ticket Entry Validation"; "Ticket Entry Validation")
                {
                    ApplicationArea = All;
                }
                field("Max No. Of Entries"; "Max No. Of Entries")
                {
                    ApplicationArea = All;
                }
                field("Is Ticket"; "Is Ticket")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Membership Sales Item No."; "Membership Sales Item No.")
                {
                    ApplicationArea = All;
                }
                field("DIY Print Layout Code"; "DIY Print Layout Code")
                {
                    ApplicationArea = All;
                }
                field("eTicket Activated"; "eTicket Activated")
                {
                    ApplicationArea = All;
                }
                field("eTicket Type Code"; "eTicket Type Code")
                {
                    ApplicationArea = All;
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
                Caption = 'Ticket Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR TM Ticket Setup";
            }
            action(Items)
            {
                Caption = 'Items';
                Image = ItemLines;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR Retail Item List";
                RunPageLink = "NPR Ticket Type" = FIELD(Code);
            }
            action(Admissions)
            {
                Caption = 'Admissions';
                Image = WorkCenter;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket Admissions";
            }
            action("Ticket BOM")
            {
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
                Caption = 'E-Mail Templates';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6060110));
            }
            action("SMS Template")
            {
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060110));
            }
            action("Edit Pass Template")
            {
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

