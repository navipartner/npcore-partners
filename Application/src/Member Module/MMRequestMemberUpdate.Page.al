page 6059803 "NPR MM Request Member Update"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Request Member Update";
    InsertAllowed = false;
    ModifyAllowed = false;
    Caption = 'Request Member Update';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ToolTip = 'Specifies the value of the Member Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member No."; Rec."Member No.")
                {
                    ToolTip = 'Specifies the value of the Member No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Handled; Rec.Handled)
                {
                    ToolTip = 'Specifies the value of the Handled field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Field No."; Rec."Field No.")
                {
                    ToolTip = 'Specifies the value of the Field No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Caption; Rec.Caption)
                {
                    ToolTip = 'Specifies the value of the Caption field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Current Value"; Rec."Current Value")
                {
                    ToolTip = 'Specifies the value of the Current Value field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("New Value"; Rec."New Value")
                {
                    ToolTip = 'Specifies the value of the New Value field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Request Datetime"; Rec."Request Datetime")
                {
                    ToolTip = 'Specifies the value of the Request Datetime field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Response Datetime"; Rec."Response Datetime")
                {
                    ToolTip = 'Specifies the value of the Response Datetime field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateEmail)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Request E-Mail Update';

                Image = MailSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Add update request for E-Mail field.';

                trigger OnAction();
                var
                    MemberEntryNo: Integer;
                    Member: Record "NPR MM Member";
                    MemberFieldUpdateMgr: Codeunit "NPR MM Request Member Upd Mgr";
                begin
                    if (not Evaluate(MemberEntryNo, Rec.GetFilter("Member Entry No."))) then
                        Error(NO_MEMBER_FILTER, Rec."Member Entry No.");

                    MemberFieldUpdateMgr.AddFieldUpdateRequest(MemberEntryNo, Member.FieldNo("E-Mail Address"));
                end;
            }

            action(UpdateAll)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Request Update';

                Image = UpdateDescription;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Add update request for selected fields.';

                trigger OnAction();
                var
                    MemberEntryNo: Integer;
                    MemberFieldUpdateMgr: Codeunit "NPR MM Request Member Upd Mgr";
                begin
                    if (not Evaluate(MemberEntryNo, Rec.GetFilter("Member Entry No."))) then
                        Error(NO_MEMBER_FILTER, Rec."Member Entry No.");

                    MemberFieldUpdateMgr.AddSelectedMemberFields(MemberEntryNo);
                end;
            }
        }
    }

    var
        NO_MEMBER_FILTER: Label 'Field %1 does not contain a valid filter. Request cannot be added.';

}
