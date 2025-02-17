codeunit 6248258 "NPR POS Member Session"
{
    SingleInstance = true;

    var
        _MemberCard: Record "NPR MM Member Card";
        _Initialized: Boolean;

    procedure SetMember(MemberCardEntryNo: Integer)
    begin
        ClearAll();
        if (not _MemberCard.Get(MemberCardEntryNo)) then
            exit;

        _Initialized := true;
    end;

    procedure SetMember(MemberExternalCardNo: Text[100])
    begin
        if (MemberExternalCardNo = '') then
            exit;

        ClearAll();
        _MemberCard.SetRange("External Card No.", MemberExternalCardNo);
        if (not _MemberCard.FindFirst()) then
            exit;

        _Initialized := true;
    end;

    procedure GetMemberCardEntryNo(): Integer
    begin
        exit(_MemberCard."Entry No.");
    end;

    procedure GetMemberCardExternalCardNo(): Text[100]
    begin
        exit(_MemberCard."External Card No.");
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(_Initialized);
    end;

    internal procedure ClearAll()
    begin
        Clear(_Initialized);
        Clear(_MemberCard);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', false, false)]
    local procedure "NPR POS Sale_OnAfterEndSale"(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale")
    var
        POSMemberSession: Codeunit "NPR POS Member Session";
    begin
        POSMemberSession.ClearAll();
    end;
}