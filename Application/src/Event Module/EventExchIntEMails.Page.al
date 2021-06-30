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
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail field';
                }
                field(PasswordSet; Rec.Password.HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Password Set';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Password Set field';
                }
                field("Default Organizer E-Mail"; Rec."Default Organizer E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Organizer E-Mail field';
                }
                field("Time Zone No."; Rec."Time Zone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Zone No. field';
                }
                field("Time Zone Display Name"; Rec."Time Zone Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time Zone Display Name field';
                }
                field("Time Zone Custom Offset (Min)"; Rec."Time Zone Custom Offset (Min)")
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
                    Rec.SetPassword();
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
                    Rec.TestServerConnection();
                end;
            }
        }
    }
}

