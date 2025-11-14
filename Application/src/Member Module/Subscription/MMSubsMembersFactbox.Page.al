page 6150896 "NPR MM SubsMembersFactbox"
{
    Extensible = False;
    Caption = 'SubsMembersFactbox';
    PageType = ListPart;
    SourceTable = "Name/Value Buffer";
    UsageCategory = None;
    SourceTableTemporary = true;
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Members)
            {
                field(MemberDisplayName; Rec.Name)
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the member';
                    ApplicationArea = NPRRetail;
                    trigger OnDrillDown()
                    begin
                        ShowMember();
                    end;
                }
            }
        }
    }

    procedure FillData(PaymentMethodId: Guid; Data: Dictionary of [Text, Text])
    var
        DictionaryKey: Text;
    begin
        Rec.DeleteAll();
        foreach DictionaryKey in Data.Keys() do
            if Evaluate(Rec.ID, DictionaryKey) then begin
                Rec.Name := CopyStr(Data.Get(DictionaryKey), 1, MaxStrLen(Rec.Name));
                Rec.Insert();
            end;
        CurrPage.Update(false);
    end;

    local procedure ShowMember()
    var
        Member: Record "NPR MM Member";
    begin
        Member.SetRange("Entry No.", Rec.ID);
        Page.RunModal(Page::"NPR MM Member Card", Member)
    end;

}
