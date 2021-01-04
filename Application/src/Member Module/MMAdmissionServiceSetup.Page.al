page 6060090 "NPR MM Admission Service Setup"
{

    Caption = 'MM Admission Service Setup';
    PageType = Card;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the Validate Members field';
                }
                field("Validate Tickes"; "Validate Tickes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Tickes field';
                }
                field("Validate Re-Scan"; "Validate Re-Scan")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Re-Scan field';
                }
                field("Validate Scanner Station"; "Validate Scanner Station")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Validate Scanner Station field';
                }
                field("Allowed Re-Scan Interval"; "Allowed Re-Scan Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allowed Re-Scan Interval field';
                }
                field("Web Service Is Published"; "Web Service Is Published")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Is Published field';
                }
                field("Guest Avatar"; "Guest Avatar")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Guest Avatar field';
                }
            }
            group(Turnstile)
            {
                Caption = 'Turnstile';
                field("Turnstile Default Image"; "Turnstile Default Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnstile Default Image field';
                }
                field("Turnstile Error Image"; "Turnstile Error Image")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Turnstile Error Image field';
                }
            }
            part(Turnstiles; "NPR MM Admis. Scanner Stations")
            {
                Caption = 'Turnstiles';
                ShowFilter = false;
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Published Webservice action';
            }
            action(Entries)
            {
                Caption = 'Entries';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Admis. Service Entries";
                ApplicationArea = All;
                ToolTip = 'Executes the Entries action';
            }
        }
    }
}

