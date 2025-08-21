page 6184871 "NPR MM Sub Pay Req Log Entries"
{
    Extensible = false;
    Caption = 'Subscription Payment Request Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR MM Subs Pay Req Log Entry";
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies a unique entry number, assigned by the system to this record according to an automatically maintained number series.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Processing Status field.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Error Message field.';
                    trigger OnDrillDown()
                    begin
                        Message(Rec."Error Message");
                    end;
                }
                field("Subs. Payment Gateway Code"; Rec."Subs. Payment Gateway Code")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Subscriptions Payment Gateway Code field.';

                }
                field(Manual; Rec.Manual)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Manual field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Created Date Time';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Created Date Time field.';
                }
                field(CreatedByUserName; GetCreatedByUserName())
                {
                    Caption = 'Created by User Name';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Created by User Name.';
                    Editable = false;
                }
                field("Webhook Request Entry No."; Rec."Webhook Request Entry No.")
                {
                    Caption = 'Webhook Request Entry No.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Webhook Request Entry No.';
                    Editable = false;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'Created by';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Created by field.';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'Modified Date Time';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Modified Date Time field.';
                }
                field("Modif iedByUserName"; GetModifiedByUserName())
                {
                    Caption = 'Modified by User Name';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Modified by User Name.';
                    Editable = false;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'Modified by';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Modified by field.';
                }


            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowRequest)
            {
                Caption = 'Show Request';
                ToolTip = 'Displays the request used to make the action.';
                Image = Document;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;


#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif

                trigger OnAction()
                var
                    RequestText: Text;
                begin
                    RequestText := Rec.GetRequest();
                    Message(RequestText);
                end;
            }
            action(ShowResponse)
            {
                Caption = 'Show Response';
                ToolTip = 'Displays the response received from the action.';
                Image = Document;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;


#if BC17 or BC18 or BC19 or BC20
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
#endif

                trigger OnAction()
                var
                    ResponseText: Text;
                begin
                    ResponseText := Rec.GetResponse();
                    Message(ResponseText);
                end;
            }
        }

#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            actionref(ShowRequest_Promoted; ShowRequest) { }
            actionref(ShowResponse_Promoted; ShowResponse) { }
        }
#endif
    }

    local procedure GetCreatedByUserName() CreatedByUserNameOut: Text;
    var
        User: Record User;
    begin
        User.SetLoadFields("User Name");
        if not User.Get(Rec.SystemCreatedBy) then
            exit;
        CreatedByUserNameOut := User."User Name";
    end;

    local procedure GetModifiedByUserName() ModifiedByUserName: Text;
    var
        User: Record User;
    begin
        User.SetLoadFields("User Name");
        if not User.Get(Rec.SystemModifiedBy) then
            exit;
        ModifiedByUserName := User."User Name";
    end;
}

