codeunit 6185072 "NPR POSAction:ChangePmtMethodB"
{
    Access = Internal;
    procedure ChangePaymentMethod(SalePOS: Record "NPR POS Sale"; InsertCommentLine: boolean; SaleLineMgr: codeunit "NPR POS Sale Line") Success: Boolean
    var
        SalesLinePOS: Record "NPR POS Sale Line";
        Membership: Record "NPR MM Membership";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        MMMemberPaymentMethod: Record "NPR MM Member Payment Method";
        MemberPaymentMethodChangeLbl: Label 'The default membership payment method for membership %1 was changed to %2.', Comment = '%1 - memberhsip no., mm payment method';
        MembershipHasNoPaymentMethodsAssociatedErr: Label 'The selected membership has no existing payment methods associated.';
        FilterString: Text;
    begin
        SalePOS.TestField("Customer No.");

        Membership.SetRange("Customer No.", SalePOS."Customer No.");
        Membership.SetLoadFields("Entry No.");
        if not Membership.FindFirst() then
            exit;

        MembershipPmtMethodMap.SetRange(MembershipId, Membership.SystemId);
        if (not MembershipPmtMethodMap.FindSet()) then
            Error(MembershipHasNoPaymentMethodsAssociatedErr);

        repeat
            if (FilterString <> '') then
                FilterString += '|';
            FilterString += MembershipPmtMethodMap.PaymentMethodId;
        until MembershipPmtMethodMap.Next() = 0;

        MMMemberPaymentMethod.SetFilter(SystemId, FilterString);

        if Page.RunModal(0, MMMemberPaymentMethod) <> Action::LookupOK then
            exit;

        MMMemberPaymentMethod.Validate(Status, MMMemberPaymentMethod.Status::Active);
        MMMemberPaymentMethod.Modify();

        MembershipPmtMethodMap.Get(MMMemberPaymentMethod.SystemId, Membership.SystemId);
        MembershipPmtMethodMap.Validate(Default, true);
        MembershipPmtMethodMap.Modify();

        if InsertCommentLine then begin
            SaleLineMgr.GetNewSaleLine(SalesLinePOS);
            SalesLinePOS."Line Type" := SalesLinePOS."Line Type"::Comment;
            SalesLinePOS.Description := CopyStr(StrSubstNo(MemberPaymentMethodChangeLbl, Membership."Entry No.", MMMemberPaymentMethod."Entry No."), 1, MaxStrLen(SalesLinePOS.Description));
            SaleLineMgr.InsertLineRaw(SalesLinePOS, false);
        end;

        Success := true;
    end;


}