page 6151586 "NPR Event Exch. Int. E-Mails"
{
    Caption = 'Event Exch. Int. E-Mails';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Event Exch. Int. E-Mail";
    SourceTableView = SORTING("Search E-Mail");
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field("Password.HASVALUE"; Password.HasValue)
                {
                    ApplicationArea = All;
                    Caption = 'Password Set';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Password Set field';
                }
                field("Default Organizer E-Mail"; "Default Organizer E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Organizer E-Mail field';
                }
                field("Time Zone No."; "Time Zone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Zone No. field';
                }
                field("Time Zone Display Name"; "Time Zone Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Zone Display Name field';
                }
                field("Time Zone Custom Offset (Min)"; "Time Zone Custom Offset (Min)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Zone Custom Offset (Min) field';
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Set Password action';

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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Test Server Connection action';

                trigger OnAction()
                begin
                    TestServerConnection();
                end;
            }
        }
    }
}

