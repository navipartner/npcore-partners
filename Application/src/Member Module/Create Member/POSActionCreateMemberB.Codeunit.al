codeunit 6060106 "NPR POS Action Create Member B"
{
    Access = Internal;

    procedure CreateMembershipWrapper(POSSale: Codeunit "NPR POS Sale"; MembershipSalesSetupItemNumber: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
    begin
        POSSale.GetCurrentSale(SalePOS);

        if CreateMembershipAndAssignToSales(SalePOS, MembershipSalesSetupItemNumber) then begin
            POSSale.Refresh(SalePOS);
            POSSale.Modify(false, false);
        end;
    end;

    local procedure CreateMembershipAndAssignToSales(var POSSale: Record "NPR POS Sale"; ItemNumber: Code[20]): Boolean
    begin
        exit(AssignToSales(POSSale, CreateMembership(ItemNumber, POSSale."Register No.")));
    end;

    local procedure CreateMembership(ItemNumber: Code[20]; PosUnitNo: Code[10]) MembershipEntryNo: Integer
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        PageAction: Action;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        SelectMembershipPage: Page "NPR MM Create Membership";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
    begin

        if (ItemNumber <> '') then begin
            MembershipSalesSetup.SetRange(Type, MembershipSalesSetup.Type::ITEM);
            MembershipSalesSetup.SetRange("No.", ItemNumber);
        end;
        MembershipSalesSetup.SetRange("Business Flow Type", MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);

        if (MembershipSalesSetup.Count() = 1) then begin
            MembershipSalesSetup.FindFirst();
        end else begin
            SelectMembershipPage.SetTableView(MembershipSalesSetup);
            SelectMembershipPage.LookupMode(true);
            PageAction := SelectMembershipPage.RunModal();
            if (not (PageAction = Action::LookupOK)) then
                exit(0);

            SelectMembershipPage.GetRecord(MembershipSalesSetup);
        end;

        MemberInfoCapture.Init();
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";
        MemberInfoCapture.Insert();

        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapture.SetRange("Entry No.", MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);

        Commit();
        MemberInfoCapturePage.SetPOSUnit(PosUnitNo);
        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();
        if (not (PageAction = Action::LookupOK)) then
            exit(0);

        MemberInfoCapturePage.GetRecord(MemberInfoCapture);
        MembershipEntryNo := MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, true);
    end;

    local procedure AssignToSales(var POSSale: Record "NPR POS Sale"; MembershipEntryNo: Integer): Boolean
    var
        MemberCard: Record "NPR MM Member Card";
        POSActionMemberMgmt: Codeunit "NPR MM POS Action: MemberMgmt.";
    begin
        if (MembershipEntryNo = 0) then
            exit;

        MemberCard.SetRange("Membership Entry No.", MembershipEntryNo);
        if (not MemberCard.FindFirst()) then
            exit(false);

        exit(POSActionMemberMgmt.AssignMembershipToPOSSale(POSSale, MembershipEntryNo, MemberCard."External Card No."));
    end;
}