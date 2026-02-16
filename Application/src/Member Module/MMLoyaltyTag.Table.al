table 6059887 "NPR MM Loyalty Tag"
{
    DataClassification = CustomerContent;
    Caption = 'Loyalty Tag';
    Extensible = False;
    Access = Internal;

    fields
    {
        field(1; "Key"; Code[20])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }

        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Key")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        MemberPointEntryTag: Record "NPR MM Member Point Entry Tag";
        LoyaltyJnlLineTag: Record "NPR MM Loyalty Jnl Line Tag";
        CannotDeleteInUseTagErr: Label 'Cannot delete loyalty tag with key "%1" because it is currently in use.', Comment = '%1 - Tag Key';
    begin
        MemberPointEntryTag.SetRange("Tag Key", Rec."Key");
        if not MemberPointEntryTag.IsEmpty() then
            Error(CannotDeleteInUseTagErr, Rec."Key");

        LoyaltyJnlLineTag.SetRange("Tag Key", Rec."Key");
        if not LoyaltyJnlLineTag.IsEmpty() then
            Error(CannotDeleteInUseTagErr, Rec."Key");
    end;
}
