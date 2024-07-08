page 6151190 "NPR MM RemoteSearchResult"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Member Info Capture";
    SourceTableTemporary = true;
    ShowFilter = false;
    Editable = false;
    Caption = 'Member Remote Search Result';
    DataCaptionExpression = '';
    Extensible = False;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("External Card No."; Rec."External Card No.")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
                field("External Member No"; Rec."External Member No")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RequestUpdate)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ToolTip = 'This action sends a requests to the server that the member data needs to be updated.';
                Image = UpdateDescription;

                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                begin
                    RequestFieldUpdate(_CommunityCode, Rec."External Card No.");
                end;
            }
        }
    }

    var
        _CommunityCode: Code[20];

    internal procedure AddResult(var TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary)
    begin
        Rec.Copy(TmpMemberInfoCapture, true);
    end;

    internal procedure SetCommunity(CommunityCode: Code[20])
    begin
        _CommunityCode := CommunityCode;
    end;

    local procedure RequestFieldUpdate(CommunityCode: Code[20]; CardNumber: Code[100])
    var
        NPRMembership: Codeunit "NPR MM NPR Membership";
        NotValidReason: Text;
    begin
        if not (NPRMembership.RequestMemberUpdate(CommunityCode, CardNumber, NotValidReason)) then
            Error(NotValidReason);
    end;
}