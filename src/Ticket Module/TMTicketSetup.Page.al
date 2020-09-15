page 6060079 "NPR TM Ticket Setup"
{
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.27/TSA /20171218 CASE 300395 added field "Timeout (ms)"
    // TM1.38/TSA /20181012 CASE 332109 Added NP-Pass fields
    // TM1.38/TSA /20181026 CASE 308962 Added setup fields for prepaid and postpaid ticket create process
    // TM1.46/TSA /20200326 CASE 397084 Added wizard fields
    // TM1.48/TSA /20200623 CASE 399259 Added description control

    Caption = 'Ticket Setup';
    PageType = Card;
    SourceTable = "NPR TM Ticket Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    AdditionalSearchTerms = 'Ticket Wizard, Ticket Application Area';

    layout
    {
        area(content)
        {
            group("Ticket Print")
            {
                field("Print Server Generator URL"; "Print Server Generator URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("Print Server Gen. Username"; "Print Server Gen. Username")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("Print Server Gen. Password"; "Print Server Gen. Password")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("Print Server Ticket URL"; "Print Server Ticket URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("Print Server Order URL"; "Print Server Order URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("Default Ticket Language"; "Default Ticket Language")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("Timeout (ms)"; "Timeout (ms)")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                group("Description Selection")
                {
                    field("Store Code"; "Store Code")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    }
                    field("Ticket Title"; "Ticket Title")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    }
                    field("Ticket Sub Title"; "Ticket Sub Title")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    }
                    field("Ticket Name"; "Ticket Name")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    }
                    field("Ticket Description"; "Ticket Description")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    }
                    field("Ticket Full Description"; "Ticket Full Description")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    }
                }
            }
            group(eTicket)
            {
                Caption = 'eTicket';
                field("NP-Pass Server Base URL"; "NP-Pass Server Base URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("NP-Pass Notification Method"; "NP-Pass Notification Method")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("NP-Pass API"; "NP-Pass API")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                field("NP-Pass Token"; "NP-Pass Token")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                }
                group(Control)
                {
                    Caption = 'Control';
                    field("Suppress Print When eTicket"; "Suppress Print When eTicket")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    }
                    field("Show Send Fail Message In POS"; "Show Send Fail Message In POS")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    }
                    field("Show Message Body (Debug)"; "Show Message Body (Debug)")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        Visible = false;
                    }
                }
            }
            group("Prepaid / Postpaid")
            {
                Caption = 'Prepaid / Postpaid';
                group(Prepaid)
                {
                    Caption = 'Prepaid';
                    field("Prepaid Excel Export Prompt"; "Prepaid Excel Export Prompt")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Prepaid Offline Valid. Prompt"; "Prepaid Offline Valid. Prompt")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Prepaid Ticket Result List"; "Prepaid Ticket Result List")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Prepaid Default Quantity"; "Prepaid Default Quantity")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Prepaid Ticket Server Export"; "Prepaid Ticket Server Export")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                }
                group(Postpaid)
                {
                    Caption = 'Postpaid';
                    field("Postpaid Excel Export Prompt"; "Postpaid Excel Export Prompt")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Postpaid Ticket Result List"; "Postpaid Ticket Result List")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Postpaid Default Quantity"; "Postpaid Default Quantity")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                    field("Postpaid Ticket Server Export"; "Postpaid Ticket Server Export")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    }
                }
            }
            group(Wizard)
            {
                Caption = 'Wizard';
                field("Wizard Ticket Type No. Series"; "Wizard Ticket Type No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Wizard Ticket Type Template"; "Wizard Ticket Type Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Wizard Ticket Bom Template"; "Wizard Ticket Bom Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Wizard Adm. Code No. Series"; "Wizard Adm. Code No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Wizard Admission Template"; "Wizard Admission Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Wizard Sch. Code No. Series"; "Wizard Sch. Code No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field("Wizard Item No. Series"; "Wizard Item No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(ApplicationArea)
            {

                Caption = 'Ticket Application Area';
                Ellipsis = true;
                RunObject = Page "NPR Ticket App. Area Setup";
            }

        }
        area(Processing)
        {
            action(TicketWizard)
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                ToolTip = 'Create all required setup for a ticket from a single page.';
                Caption = 'Ticket Wizard';
                Ellipsis = true;
                Image = Action;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    TicketWizardMgr: Codeunit "NPR TM Ticket Wizard";
                begin
                    TicketWizardMgr.Run();
                end;

            }

            action(DemoData)
            {
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'Create DEMO Data';
                ToolTip = 'Creates the NPR Demo Setup used when demonstrating ticketing.';
                Ellipsis = true;
                Image = CarryOutActionMessage;
                Promoted = false;
                trigger OnAction()
                var
                    TicketDemoSetup: Codeunit "NPR TM Ticket Create Demo Data";
                begin
                    TicketDemoSetup.CreateTicketDemoData(false);
                end;
            }
        }
    }
}

