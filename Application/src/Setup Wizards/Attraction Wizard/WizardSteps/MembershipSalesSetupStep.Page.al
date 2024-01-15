page 6151383 "NPR Membership SalesSetup Step"
{
    Extensible = False;
    Caption = 'Membership Sales Setup';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR MM Members. Sales Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Business Flow Type"; Rec."Business Flow Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Business Flow Type field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Valid From Base"; Rec."Valid From Base")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Valid From Base field';
                }
                field("Valid From Date Calculation"; Rec."Valid From Date Calculation")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Valid From Date Calculation field';
                }
                field("Duration Formula"; Rec."Duration Formula")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Duration Formula field';
                }
                field("Member Card Type"; Rec."Member Card Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Member Card Type field';
                }
            }
        }
    }

    internal procedure CopyLiveData()
    var
        MembershipSalesSetups: Record "NPR MM Members. Sales Setup";
    begin
        Rec.DeleteAll();

        if MembershipSalesSetups.FindSet() then
            repeat
                Rec := MembershipSalesSetups;
                if not Rec.Insert() then
                    Rec.Modify();
            until MembershipSalesSetups.Next() = 0;
    end;

    internal procedure MembershipSalesSetupsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateMembershipSalesSetups()
    var
        MembershipSalesSetups: Record "NPR MM Members. Sales Setup";
    begin
        if Rec.FindSet() then
            repeat
                MembershipSalesSetups := Rec;
                if not MembershipSalesSetups.Insert() then
                    MembershipSalesSetups.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempMembershipSalesSetups(var TempMembershipSalesSetups: Record "NPR MM Members. Sales Setup")
    begin
        TempMembershipSalesSetups.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempMembershipSalesSetups := Rec;
                if not TempMembershipSalesSetups.Insert() then
                    TempMembershipSalesSetups.Modify();
            until Rec.Next() = 0;
    end;
}
