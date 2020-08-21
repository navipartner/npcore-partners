page 6060079 "TM Ticket Setup"
{
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.27/TSA /20171218 CASE 300395 added field "Timeout (ms)"
    // TM1.38/TSA /20181012 CASE 332109 Added NP-Pass fields
    // TM1.38/TSA /20181026 CASE 308962 Added setup fields for prepaid and postpaid ticket create process
    // TM1.46/TSA /20200326 CASE 397084 Added wizard fields
    // TM1.48/TSA /20200623 CASE 399259 Added description control

    Caption = 'Ticket Setup';
    PageType = Card;
    SourceTable = "TM Ticket Setup";

    layout
    {
        area(content)
        {
            group("Ticket Print")
            {
                field("Print Server Generator URL"; "Print Server Generator URL")
                {
                    ApplicationArea = All;
                }
                field("Print Server Gen. Username"; "Print Server Gen. Username")
                {
                    ApplicationArea = All;
                }
                field("Print Server Gen. Password"; "Print Server Gen. Password")
                {
                    ApplicationArea = All;
                }
                field("Print Server Ticket URL"; "Print Server Ticket URL")
                {
                    ApplicationArea = All;
                }
                field("Print Server Order URL"; "Print Server Order URL")
                {
                    ApplicationArea = All;
                }
                field("Default Ticket Language"; "Default Ticket Language")
                {
                    ApplicationArea = All;
                }
                field("Timeout (ms)"; "Timeout (ms)")
                {
                    ApplicationArea = All;
                }
                group("Description Selection")
                {
                    field("Store Code"; "Store Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Ticket Title"; "Ticket Title")
                    {
                        ApplicationArea = All;
                    }
                    field("Ticket Sub Title"; "Ticket Sub Title")
                    {
                        ApplicationArea = All;
                    }
                    field("Ticket Name"; "Ticket Name")
                    {
                        ApplicationArea = All;
                    }
                    field("Ticket Description"; "Ticket Description")
                    {
                        ApplicationArea = All;
                    }
                    field("Ticket Full Description"; "Ticket Full Description")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(eTicket)
            {
                Caption = 'eTicket';
                field("NP-Pass Server Base URL"; "NP-Pass Server Base URL")
                {
                    ApplicationArea = All;
                }
                field("NP-Pass Notification Method"; "NP-Pass Notification Method")
                {
                    ApplicationArea = All;
                }
                field("NP-Pass API"; "NP-Pass API")
                {
                    ApplicationArea = All;
                }
                field("NP-Pass Token"; "NP-Pass Token")
                {
                    ApplicationArea = All;
                }
                group(Control)
                {
                    Caption = 'Control';
                    field("Suppress Print When eTicket"; "Suppress Print When eTicket")
                    {
                        ApplicationArea = All;
                    }
                    field("Show Send Fail Message In POS"; "Show Send Fail Message In POS")
                    {
                        ApplicationArea = All;
                    }
                    field("Show Message Body (Debug)"; "Show Message Body (Debug)")
                    {
                        ApplicationArea = All;
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
                        ApplicationArea = All;
                    }
                    field("Prepaid Offline Valid. Prompt"; "Prepaid Offline Valid. Prompt")
                    {
                        ApplicationArea = All;
                    }
                    field("Prepaid Ticket Result List"; "Prepaid Ticket Result List")
                    {
                        ApplicationArea = All;
                    }
                    field("Prepaid Default Quantity"; "Prepaid Default Quantity")
                    {
                        ApplicationArea = All;
                    }
                    field("Prepaid Ticket Server Export"; "Prepaid Ticket Server Export")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Postpaid)
                {
                    Caption = 'Postpaid';
                    field("Postpaid Excel Export Prompt"; "Postpaid Excel Export Prompt")
                    {
                        ApplicationArea = All;
                    }
                    field("Postpaid Ticket Result List"; "Postpaid Ticket Result List")
                    {
                        ApplicationArea = All;
                    }
                    field("Postpaid Default Quantity"; "Postpaid Default Quantity")
                    {
                        ApplicationArea = All;
                    }
                    field("Postpaid Ticket Server Export"; "Postpaid Ticket Server Export")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Wizard)
            {
                Caption = 'Wizard';
                field("Wizard Ticket Type No. Series"; "Wizard Ticket Type No. Series")
                {
                    ApplicationArea = All;
                }
                field("Wizard Ticket Type Template"; "Wizard Ticket Type Template")
                {
                    ApplicationArea = All;
                }
                field("Wizard Ticket Bom Template"; "Wizard Ticket Bom Template")
                {
                    ApplicationArea = All;
                }
                field("Wizard Adm. Code No. Series"; "Wizard Adm. Code No. Series")
                {
                    ApplicationArea = All;
                }
                field("Wizard Admission Template"; "Wizard Admission Template")
                {
                    ApplicationArea = All;
                }
                field("Wizard Sch. Code No. Series"; "Wizard Sch. Code No. Series")
                {
                    ApplicationArea = All;
                }
                field("Wizard Item No. Series"; "Wizard Item No. Series")
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
        }
    }
}

