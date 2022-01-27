page 6060091 "NPR MM Admis. Service Entries"
{
    Extensible = False;

    Caption = 'MM Admission Service Entries';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Admis. Service Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date"; Rec."Created Date")
                {

                    ToolTip = 'Specifies the value of the Created Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Modify Date"; Rec."Modify Date")
                {

                    ToolTip = 'Specifies the value of the Modify Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Token; Rec.Token)
                {

                    ToolTip = 'Specifies the value of the Token field';
                    ApplicationArea = NPRRetail;
                }
                field("Key"; Rec.Key)
                {

                    ToolTip = 'Specifies the value of the Key field';
                    ApplicationArea = NPRRetail;
                }
                field("Scanner Station Id"; Rec."Scanner Station Id")
                {

                    ToolTip = 'Specifies the value of the Scanner Station Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Arrived; Rec.Arrived)
                {

                    ToolTip = 'Specifies the value of the Arrived field';
                    ApplicationArea = NPRRetail;
                }
                field("Admission Is Valid"; Rec."Admission Is Valid")
                {

                    ToolTip = 'Specifies the value of the Admission Is Valid field';
                    ApplicationArea = NPRRetail;
                }
                field("Card Entry No."; Rec."Card Entry No.")
                {

                    ToolTip = 'Specifies the value of the Card Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {

                    ToolTip = 'Specifies the value of the Member Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Card No."; Rec."External Card No.")
                {

                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Member No."; Rec."External Member No.")
                {

                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Entry No."; Rec."Ticket Entry No.")
                {

                    ToolTip = 'Specifies the value of the Ticket Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("External Ticket No."; Rec."External Ticket No.")
                {

                    ToolTip = 'Specifies the value of the External Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Message"; Rec.Message)
                {

                    ToolTip = 'Specifies the value of the Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Type Code"; Rec."Ticket Type Code")
                {

                    ToolTip = 'Specifies the value of the Ticket Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Type Description"; Rec."Ticket Type Description")
                {

                    ToolTip = 'Specifies the value of the Ticket Type Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Description"; Rec."Membership Description")
                {

                    ToolTip = 'Specifies the value of the Membership Description field';
                    ApplicationArea = NPRRetail;
                }
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
            action(Log)
            {
                Caption = 'Log';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Admission Service Log";
                RunPageLink = "Entry No." = FIELD("Entry No.");

                ToolTip = 'Executes the Log action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

