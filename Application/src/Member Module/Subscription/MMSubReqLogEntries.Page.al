page 6184892 "NPR MM Sub Req Log Entries"
{
    Extensible = false;
    Caption = 'Subscription Request Log Entries';
    Editable = false;
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR MM Subs Req Log Entry";
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
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Interaction Type field.';
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Status field.';
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
    local procedure GetCreatedByUserName() CreatedByUserName: Text;
    var
        User: Record User;
    begin
        User.SetLoadFields("User Name");
        if not User.Get(Rec.SystemCreatedBy) then
            exit;
        CreatedByUserName := User."User Name";
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

