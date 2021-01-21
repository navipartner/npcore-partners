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
            group(General)
            {
                field("Authorization Code Scheme"; "Authorization Code Scheme")
                {
                    ApplicationArea = NPRTicketEssentials, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Authorization Code Scheme field';
                }
            }
            group("Ticket Print")
            {
                field("Print Server Generator URL"; "Print Server Generator URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Generator URL field';
                }
                field("Print Server Gen. Username"; "Print Server Gen. Username")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Gen. Username field';
                }
                field("Print Server Gen. Password"; "Print Server Gen. Password")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Gen. Password field';
                }
                field("Print Server Ticket URL"; "Print Server Ticket URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Ticket URL field';
                }
                field("Print Server Order URL"; "Print Server Order URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Print Server Order URL field';
                }
                field("Default Ticket Language"; "Default Ticket Language")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Default Ticket Language field';
                }
                field("Timeout (ms)"; "Timeout (ms)")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Timeout (ms) field';
                }
                group("Description Selection")
                {
                    field("Store Code"; "Store Code")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Store Code field';
                    }
                    field("Ticket Title"; "Ticket Title")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Title field';
                    }
                    field("Ticket Sub Title"; "Ticket Sub Title")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Sub Title field';
                    }
                    field("Ticket Name"; "Ticket Name")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Name field';
                    }
                    field("Ticket Description"; "Ticket Description")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Description field';
                    }
                    field("Ticket Full Description"; "Ticket Full Description")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Ticket Full Description field';
                    }
                }
            }
            group(eTicket)
            {
                Caption = 'eTicket';
                field("NP-Pass Server Base URL"; "NP-Pass Server Base URL")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the NP-Pass Server Base URL field';
                }
                field("NP-Pass Notification Method"; "NP-Pass Notification Method")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the NP-Pass Notification Method field';
                }
                field("NP-Pass API"; "NP-Pass API")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the NP-Pass API field';
                }
                field("NP-Pass Token"; "NP-Pass Token")
                {
                    ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the NP-Pass Token field';
                }
                group(Control)
                {
                    Caption = 'Control';
                    field("Suppress Print When eTicket"; "Suppress Print When eTicket")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Suppress Print When eTicket field';
                    }
                    field("Show Send Fail Message In POS"; "Show Send Fail Message In POS")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Show Send Fail Message In POS field';
                    }
                    field("Show Message Body (Debug)"; "Show Message Body (Debug)")
                    {
                        ApplicationArea = NPRTicketWallet, NPRTicketAdvanced;
                        Visible = false;
                        ToolTip = 'Specifies the value of the Show Message Body (Debug) field';
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
                        ToolTip = 'Specifies the value of the Prepaid Excel Export Prompt field';
                    }
                    field("Prepaid Offline Valid. Prompt"; "Prepaid Offline Valid. Prompt")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Offline Valid. Prompt field';
                    }
                    field("Prepaid Ticket Result List"; "Prepaid Ticket Result List")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Ticket Result List field';
                    }
                    field("Prepaid Default Quantity"; "Prepaid Default Quantity")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Default Quantity field';
                    }
                    field("Prepaid Ticket Server Export"; "Prepaid Ticket Server Export")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Prepaid Ticket Server Export field';
                    }
                }
                group(Postpaid)
                {
                    Caption = 'Postpaid';
                    field("Postpaid Excel Export Prompt"; "Postpaid Excel Export Prompt")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Postpaid Excel Export Prompt field';
                    }
                    field("Postpaid Ticket Result List"; "Postpaid Ticket Result List")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Postpaid Ticket Result List field';
                    }
                    field("Postpaid Default Quantity"; "Postpaid Default Quantity")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Postpaid Default Quantity field';
                    }
                    field("Postpaid Ticket Server Export"; "Postpaid Ticket Server Export")
                    {
                        ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                        ToolTip = 'Specifies the value of the Postpaid Ticket Server Export field';
                    }
                }
            }
            group(Wizard)
            {
                Caption = 'Wizard';
                field("Wizard Ticket Type No. Series"; "Wizard Ticket Type No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Ticket Type No. Series field';
                }
                field("Wizard Ticket Type Template"; "Wizard Ticket Type Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Ticket Type Template field';
                }
                field("Wizard Ticket Bom Template"; "Wizard Ticket Bom Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Ticket Bom Template field';
                }
                field("Wizard Adm. Code No. Series"; "Wizard Adm. Code No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Adm. Code No. Series field';
                }
                field("Wizard Admission Template"; "Wizard Admission Template")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Admission Template field';
                }
                field("Wizard Sch. Code No. Series"; "Wizard Sch. Code No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Sch. Code No. Series field';
                }
                field("Wizard Item No. Series"; "Wizard Item No. Series")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Wizard Item No. Series field';
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
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Ticket Application Area';
                Ellipsis = true;
                RunObject = Page "NPR Ticket App. Area Setup";
                ToolTip = 'Executes the Ticket Application Area action';
                Image = SetupList;
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
				PromotedOnly = true;
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

