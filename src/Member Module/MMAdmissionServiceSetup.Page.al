page 6060090 "NPR MM Admission Service Setup"
{
    // NPR5.31/NPKNAV/20170502  CASE 263737 Transport NPR5.31 - 2 May 2017
    // NPR5.43/CLVA  /20180627  CASE 318579 Added new fields "Ticket Type Code","Ticket Type Description","Membership Code" and "Membership Description"

    Caption = 'MM Admission Service Setup';
    PageType = Card;
    SourceTable = "NPR MM Admis. Service Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Validate Members"; "Validate Members")
                {
                    ApplicationArea = All;
                }
                field("Validate Tickes"; "Validate Tickes")
                {
                    ApplicationArea = All;
                }
                field("Validate Re-Scan"; "Validate Re-Scan")
                {
                    ApplicationArea = All;
                }
                field("Validate Scanner Station"; "Validate Scanner Station")
                {
                    ApplicationArea = All;
                }
                field("Allowed Re-Scan Interval"; "Allowed Re-Scan Interval")
                {
                    ApplicationArea = All;
                }
                field("Web Service Is Published"; "Web Service Is Published")
                {
                    ApplicationArea = All;
                }
                field("Guest Avatar"; "Guest Avatar")
                {
                    ApplicationArea = All;
                }
            }
            group(Turnstile)
            {
                Caption = 'Turnstile';
                field("Turnstile Default Image"; "Turnstile Default Image")
                {
                    ApplicationArea = All;
                }
                field("Turnstile Error Image"; "Turnstile Error Image")
                {
                    ApplicationArea = All;
                }
            }
            part(Turnstiles; "NPR MM Admis. Scanner Stations")
            {
                Caption = 'Turnstiles';
                ShowFilter = false;
                ApplicationArea=All;
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
        area(navigation)
        {
            action("Published Webservice")
            {
                Caption = 'Published Webservice';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Codeunit "NPR MM Admission Service WS";
                ApplicationArea=All;
            }
            action(Entries)
            {
                Caption = 'Entries';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Admis. Service Entries";
                ApplicationArea=All;
            }
        }
    }
}

