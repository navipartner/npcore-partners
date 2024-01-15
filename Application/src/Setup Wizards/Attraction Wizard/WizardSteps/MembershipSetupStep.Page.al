page 6151390 "NPR Membership Setup Step"
{
    Extensible = False;
    Caption = 'Membership Setup';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR MM Membership Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Member Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Membership Type"; Rec."Membership Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Membership Type field.';
                }
                field("Membership Member Cardinality"; Rec."Membership Member Cardinality")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Membership Member Cardinality field.';
                }
                field("Community Code"; Rec."Community Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Community Code field.';
                }
                field("Card Number Scheme"; Rec."Card Number Scheme")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Number Scheme field.';
                }
                field("Card Number Prefix"; Rec."Card Number Prefix")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Number Prefix field.';
                }
                field("Card Number Length"; Rec."Card Number Length")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Number Length field.';
                }
                field("Card Number No. Series"; Rec."Card Number No. Series")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Card Number No. Series field.';
                }
                field("Ticket Item Barcode"; Rec."Ticket Item Barcode")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ticket Item Barcode field.';
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        MembershipSetups: Record "NPR MM Membership Setup";
    begin
        Rec.DeleteAll();

        if MembershipSetups.FindSet() then
            repeat
                Rec := MembershipSetups;
                if not Rec.Insert() then
                    Rec.Modify();
            until MembershipSetups.Next() = 0;
    end;

    internal procedure MembershipSetupsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateMembershipSetups()
    var
        MembershipSetups: Record "NPR MM Membership Setup";
    begin
        if Rec.FindSet() then
            repeat
                MembershipSetups := Rec;
                if not MembershipSetups.Insert() then
                    MembershipSetups.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempMembershipSetups(var TempMembershipSetups: Record "NPR MM Membership Setup")
    begin
        TempMembershipSetups.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMembershipSetups := Rec;
                if not TempMembershipSetups.Insert() then
                    TempMembershipSetups.Modify();
            until Rec.Next() = 0;
    end;
}
