codeunit 6150819 "NPR POS Action: MM BackEnd B"
{
    Access = Internal;

    procedure CreateMember(ItemNumber: Code[20]; POSSetup: Codeunit "NPR POS Setup")
    var
        POSActionMemberMgmt: Codeunit "NPR MM POS Action: MemberMgmt.";
        POSSession: Codeunit "NPR POS Session";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSStore: Record "NPR POS Store";
        CardNumber: Text[100];
        AssignToSale: Label 'Assign created membership to sale?';
    begin

        POSSetup.GetSalespersonRecord(SalespersonPurchaser);
        POSSetup.GetPOSStore(POSStore);

        CardNumber := CreateMembership(ItemNumber, SalespersonPurchaser.Code, POSStore.Code);

        if (CardNumber <> '') then
            if (Confirm(AssignToSale, true)) then
                POSActionMemberMgmt.SelectMembership(POSSession, 2, CardNumber, ''); //2 == NoPrompt
    end;

    local procedure CreateMembership(MemberSalesSetupItemNumber: Code[20]; SalespersonCode: Code[20]; StoreCode: Code[20]) ExternalCardNumber: Text[100];
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipMgt: Codeunit "NPR MM Membership Mgt.";
    begin
        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberSalesSetupItemNumber);

        MemberInfoCapture.Init();
#pragma warning disable AA0139
        MemberInfoCapture."Receipt No." := DelChr(Format(CurrentDateTime(), 0, 9), '<=>', DelChr(Format(CurrentDateTime(), 0, 9), '<=>', '01234567890'));
#pragma warning restore
        MemberInfoCapture."Line No." := 1;
        MemberInfoCapture."Item No." := MemberSalesSetupItemNumber;
        MemberInfoCapture."Document No." := SalespersonCode;
        MemberInfoCapture."Store Code" := StoreCode;
        MemberInfoCapture.Quantity := 1;
        MemberInfoCapture.Insert();

        ExternalCardNumber := MembershipMgt.CreateMembershipInteractive(MemberInfoCapture);

        if (MemberInfoCapture.Get(MemberInfoCapture."Entry No.")) then
            MemberInfoCapture.Delete();

        Commit();

        exit(ExternalCardNumber);
    end;
}