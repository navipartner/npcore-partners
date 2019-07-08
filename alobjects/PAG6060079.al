page 6060079 "TM Ticket Setup"
{
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.27/TSA /20171218 CASE 300395 added field "Timeout (ms)"
    // TM1.38/TSA /20181012 CASE 332109 Added NP-Pass fields
    // TM1.38/TSA /20181026 CASE 308962 Added setup fields for prepaid and postpaid ticket create process

    Caption = 'Ticket Setup';
    PageType = Card;
    SourceTable = "TM Ticket Setup";

    layout
    {
        area(content)
        {
            group("Ticket Print")
            {
                field("Print Server Generator URL";"Print Server Generator URL")
                {
                }
                field("Print Server Gen. Username";"Print Server Gen. Username")
                {
                }
                field("Print Server Gen. Password";"Print Server Gen. Password")
                {
                }
                field("Print Server Ticket URL";"Print Server Ticket URL")
                {
                }
                field("Print Server Order URL";"Print Server Order URL")
                {
                }
                field("Default Ticket Language";"Default Ticket Language")
                {
                }
                field("Timeout (ms)";"Timeout (ms)")
                {
                }
            }
            group(eTicket)
            {
                Caption = 'eTicket';
                field("NP-Pass Server Base URL";"NP-Pass Server Base URL")
                {
                }
                field("NP-Pass Notification Method";"NP-Pass Notification Method")
                {
                }
                field("NP-Pass API";"NP-Pass API")
                {
                }
                field("NP-Pass Token";"NP-Pass Token")
                {
                }
                group(Control)
                {
                    Caption = 'Control';
                    field("Suppress Print When eTicket";"Suppress Print When eTicket")
                    {
                    }
                    field("Show Send Fail Message In POS";"Show Send Fail Message In POS")
                    {
                    }
                    field("Show Message Body (Debug)";"Show Message Body (Debug)")
                    {
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
                    field("Prepaid Excel Export Prompt";"Prepaid Excel Export Prompt")
                    {
                    }
                    field("Prepaid Offline Valid. Prompt";"Prepaid Offline Valid. Prompt")
                    {
                    }
                    field("Prepaid Ticket Result List";"Prepaid Ticket Result List")
                    {
                    }
                    field("Prepaid Default Quantity";"Prepaid Default Quantity")
                    {
                    }
                    field("Prepaid Ticket Server Export";"Prepaid Ticket Server Export")
                    {
                    }
                }
                group(Postpaid)
                {
                    Caption = 'Postpaid';
                    field("Postpaid Excel Export Prompt";"Postpaid Excel Export Prompt")
                    {
                    }
                    field("Postpaid Ticket Result List";"Postpaid Ticket Result List")
                    {
                    }
                    field("Postpaid Default Quantity";"Postpaid Default Quantity")
                    {
                    }
                    field("Postpaid Ticket Server Export";"Postpaid Ticket Server Export")
                    {
                    }
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

