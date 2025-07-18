page 6184835 "NPR MM Member Payment Methods"
{
    Extensible = false;
    Caption = 'Member Payment Method';
    PageType = List;
    SourceTable = "NPR MM Member Payment Method";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the payment method.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Default; _IsDefault)
                {
                    Caption = 'Default';
                    ToolTip = 'Specifies whether the payment method has been set up as default.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    Visible = (_DefaultFieldVisible);
                }
                field("Payment Method Alias"; Rec."Payment Method Alias")
                {
                    ToolTip = 'Specifies a short description that can be assigned to each payment method by the end user.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(PSP; Rec.PSP)
                {
                    ToolTip = 'Specifies the payment service provider of the payment method.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Instrument Type"; Rec."Payment Instrument Type")
                {
                    ToolTip = 'Specifies the payment instrument type.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Brand"; Rec."Payment Brand")
                {
                    ToolTip = 'Specifies the payment method brand.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Masked PAN"; Rec."Masked PAN")
                {
                    ToolTip = 'Specifies the masked PAN of the payment card.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("PAN Last 4 Digits"; Rec."PAN Last 4 Digits")
                {
                    ToolTip = 'Specifies the last 4 digits of the payment card number.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ToolTip = 'Specifies the expiry date of the payment methoid (card).';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies a unique entry number, assigned by the system to this record according to an automatically maintained number series.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    var
        _DefaultFieldVisible: Boolean;
        _MembershipId: Guid;
        _IsDefault: Boolean;

    trigger OnAfterGetRecord()
    var
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
    begin
        Clear(_IsDefault);
        if (MembershipPmtMethodMap.Get(Rec.SystemId, _MembershipId)) then
            _IsDefault := MembershipPmtMethodMap.Default;
    end;

    internal procedure SetMembershipId(MembershipId: Guid)
    begin
        _MembershipId := MembershipId;
        if (not IsNullGuid(MembershipId)) then
            _DefaultFieldVisible := true;
    end;
}