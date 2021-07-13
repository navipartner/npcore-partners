page 6151586 "NPR Event Exch. Int. E-Mails"
{
    Caption = 'Event Exch. Int. E-Mails';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Event Exch. Int. E-Mail";
    SourceTableView = SORTING("Search E-Mail");
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("E-Mail"; Rec."E-Mail")
                {

                    ToolTip = 'Specifies the value of the E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field(PasswordSet; Rec.Password.HasValue())
                {

                    Caption = 'Password Set';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Password Set field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Organizer E-Mail"; Rec."Default Organizer E-Mail")
                {

                    ToolTip = 'Specifies the value of the Default Organizer E-Mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Time Zone No."; Rec."Time Zone No.")
                {

                    ToolTip = 'Specifies the value of the Time Zone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Time Zone Display Name"; Rec."Time Zone Display Name")
                {

                    ToolTip = 'Specifies the value of the Time Zone Display Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Time Zone Custom Offset (Min)"; Rec."Time Zone Custom Offset (Min)")
                {

                    ToolTip = 'Specifies the value of the Time Zone Custom Offset (Min) field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Set Password action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Test Server Connection action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.TestServerConnection();
                end;
            }
        }
    }
}

