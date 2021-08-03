page 6014524 "NPR MM Member Search Fields"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR MM Member";
    SourceTableTemporary = true;
    ShowFilter = false;
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'Search Members';
    DataCaptionExpression = '';
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
                    ApplicationArea = NPRRetail;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }

            }
            group(Limits)
            {
                field(LimitResultSetTo; LimitResultSetTo)
                {
                    Caption = 'Limit ResultSet to Max Lines';
                    ToolTip = 'Specifies the value of the Limit ResultSet to Max Lines field';
                    ApplicationArea = NPRRetail;
                }
            }

        }
    }

    var
        LimitResultSetTo: Integer;
        TempSelectedMember: Record "NPR MM Member" temporary;

    trigger OnOpenPage()
    begin
        LimitResultSetTo := 50;
        Rec."Entry No." := 1;
        Rec.Insert();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        MemberListPage: Page "NPR MM Members TEMP";
        TempMember: Record "NPR MM Member" temporary;
        Member: Record "NPR MM Member";
        CappedResultSet: Label 'Only the first %1 members matching your query will be listed.';
        PageAction: Action;
    begin

        if (not (CloseAction = Action::LookupOK)) then
            exit(true);

        if (Rec."First Name" <> '') then
            Member.SetFilter("First Name", '%1', '@' + Rec."First Name");

        if (Rec."Last Name" <> '') then
            Member.SetFilter("Last Name", '%1', '@' + Rec."Last Name");

        if (Rec."E-Mail Address" <> '') then
            Member.SetFilter("E-Mail Address", '%1', LowerCase(ConvertStr(Rec."E-Mail Address", '@', '?')));

        if (Rec."Phone No." <> '') then
            Member.SetFilter("Phone No.", '%1', Rec."Phone No.");

        Member.SetFilter(Blocked, '=%1', false);

        if (Member.Find('-')) then begin
            repeat
                TempMember.TransferFields(Member, true);
                TempMember.Insert();
            until ((Member.Next() = 0) or (TempMember.Count() >= LimitResultSetTo));

            if (TempMember.Count() >= LimitResultSetTo) then
                Message(CappedResultSet, TempMember.Count());

            MemberListPage.FillPage(TempMember);
            MemberListPage.LookupMode(true);
            PageAction := MemberListPage.RunModal();
            if (PageAction = Action::LookupOK) then begin
                MemberListPage.GetRecord(TempSelectedMember);
                TempSelectedMember.Insert();
            end;

            exit(true);
        end;

    end;

    procedure GetSelectedMemberNumber(): Code[20]
    begin
        if (TempSelectedMember.FindFirst()) then
            exit(TempSelectedMember."External Member No.");
    end;

}