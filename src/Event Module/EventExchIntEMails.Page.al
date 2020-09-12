page 6151586 "NPR Event Exch. Int. E-Mails"
{
    // NPR5.38/NPKNAV/20180126  CASE 285194 Transport NPR5.38 - 26 January 2018
    // NPR5.46/TJ  /20180605  CASE 317448 New fields "Time Zone Id", "Time Zone Display Name" and "Time Zone Custom Offset (Min)"

    Caption = 'Event Exch. Int. E-Mails';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Event Exch. Int. E-Mail";
    SourceTableView = SORTING("Search E-Mail");
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                }
                field("Password.HASVALUE"; Password.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Password Set';
                    Editable = false;
                }
                field("Default Organizer E-Mail"; "Default Organizer E-Mail")
                {
                    ApplicationArea = All;
                }
                field("Time Zone No."; "Time Zone No.")
                {
                    ApplicationArea = All;
                }
                field("Time Zone Display Name"; "Time Zone Display Name")
                {
                    ApplicationArea = All;
                }
                field("Time Zone Custom Offset (Min)"; "Time Zone Custom Offset (Min)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Password")
            {
                Caption = 'Set Password';
                Ellipsis = true;
                Image = EncryptionKeys;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    SetPassword();
                end;
            }
            action("Test Server Connection")
            {
                Caption = 'Test Server Connection';
                Image = Link;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    TestServerConnection();
                end;
            }
        }
    }
}

