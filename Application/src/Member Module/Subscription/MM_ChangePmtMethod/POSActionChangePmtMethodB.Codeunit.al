codeunit 6185072 "NPR POSAction:ChangePmtMethodB"
{
    Access = Internal;
    procedure ChangePaymentMethod(SalePOS: Record "NPR POS Sale"; InsertCommentLine: boolean; SaleLineMgr: codeunit "NPR POS Sale Line") Success: Boolean
    var
        SalesLinePOS: Record "NPR POS Sale Line";
        Membership: Record "NPR MM Membership";
        MMMemberPaymentMethod: Record "NPR MM Member Payment Method";
        MemberPaymentMethodChangeLbl: Label 'The default membership payment method for membership %1 was changed to %2.', Comment = '%1 - memberhsip no., mm payment method';
    begin
        SalePOS.TestField("Customer No.");

        Membership.SetRange("Customer No.", SalePOS."Customer No.");
        Membership.SetLoadFields("Entry No.");
        if not Membership.FindFirst() then
            exit;

        MMMemberPaymentMethod.SetRange("Table No.", Database::"NPR MM Membership");
        MMMemberPaymentMethod.SetRange("BC Record ID", Membership.RecordId());

        if Page.RunModal(0, MMMemberPaymentMethod) <> Action::LookupOK then
            exit;

        MMMemberPaymentMethod.Validate(Default, true);
        MMMemberPaymentMethod.Validate(Status, MMMemberPaymentMethod.Status::Active);
        MMMemberPaymentMethod.Modify();

        if InsertCommentLine then begin
            SaleLineMgr.GetNewSaleLine(SalesLinePOS);
            SalesLinePOS."Line Type" := SalesLinePOS."Line Type"::Comment;
            SalesLinePOS.Description := CopyStr(StrSubstNo(MemberPaymentMethodChangeLbl, Membership."Entry No.", MMMemberPaymentMethod."Entry No."), 1, MaxStrLen(SalesLinePOS.Description));
            SaleLineMgr.InsertLineRaw(SalesLinePOS, false);
        end;

        Success := true;
    end;


}