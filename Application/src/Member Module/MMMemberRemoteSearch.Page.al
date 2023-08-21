page 6151189 "NPR MM MemberRemoteSearch"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR MM Member Info Capture";
    SourceTableTemporary = true;
    ShowFilter = false;
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Member Remote Search';
    DataCaptionExpression = '';
    Extensible = False;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'Member Filter';
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(References)
            {
                Caption = 'Reference Number Filters';

                field("External Member No"; Rec."External Member No")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("External Card No."; _CardNumber)
                {
                    Caption = 'External Card No.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the External Card No. field';
                    trigger OnValidate()
                    begin
                        Rec."External Card No." := _CardNumber;
                    end;
                }
            }
            group(Limits)
            {
                Caption = 'Limits';
                field(LimitResultSetTo; Rec.Quantity)
                {
                    Caption = 'Limit ResultSet to Max Lines';
                    ToolTip = 'Specifies the value of the Limit ResultSet to Max Lines field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }

    }

    var
        _CommunityCode: Code[20];
        _CardNumber: Text[100];
        TempMemberInfoCaptureSelected: Record "NPR MM Member Info Capture" temporary;

    trigger OnInit()
    begin
        if (not Rec.IsTemporary()) then
            Error('This page must operate on a temporary table.');

        Rec."Entry No." := 1;
        Rec.Quantity := 50;
        Rec.Insert();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NPRMembership: Codeunit "NPR MM NPR Membership";
        MemberRemoteSearchResult: Page "NPR MM RemoteSearchResult";
        TempMemberInfoCaptureResult: Record "NPR MM Member Info Capture" temporary;
        ReasonText: Text;
        PageAction: Action;
    begin

        if (not (CloseAction = Action::LookupOK)) then
            exit(true);

        if (TempMemberInfoCaptureResult.IsTemporary()) then
            TempMemberInfoCaptureResult.DeleteAll();

        if (not NPRMembership.SearchRemoteMember(_CommunityCode, Rec, TempMemberInfoCaptureResult, ReasonText)) then begin
            if (ReasonText = '') then
                ReasonText := 'There was an unknown issue with remote search.';
            exit(not Confirm(StrSubstNo('%1\\Do you want to search again?', ReasonText)));
        end;

        MemberRemoteSearchResult.AddResult(TempMemberInfoCaptureResult);
        MemberRemoteSearchResult.SetCommunity(_CommunityCode);
        MemberRemoteSearchResult.LookupMode(true);
        PageAction := MemberRemoteSearchResult.RunModal();
        if (not (PageAction = Action::LookupOK)) then
            exit(false);

        MemberRemoteSearchResult.GetRecord(TempMemberInfoCaptureSelected);
        exit(true);
    end;

    internal procedure SetCommunity(CommunityCodeIn: Code[20])
    begin
        _CommunityCode := CommunityCodeIn;
    end;

    internal procedure GetSelectedRecord(var TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary)
    begin
        TmpMemberInfoCapture.Copy(TempMemberInfoCaptureSelected, true);
    end;

}