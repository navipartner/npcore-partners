codeunit 85306 "NPR RS Retail Trans. R2R Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure RetailToRetail_MovesMarkup()
    var
        Lib: Codeunit "NPR Library - RS Retail Loc.";
        Item: Record Item;
        RetailA: Record Location;
        RetailB: Record Location;
        Transit: Record Location;
        CalcVATAcc: Code[20];
        CalcMarginAcc: Code[20];
        ShptNo: Code[20];
        RcptNo: Code[20];
    begin
        // [SCENARIO] Retail A -> retail B transfer must remove markup at the source and re-add it at the destination
        // [GIVEN] Two retail locations with different inventory accounts; item cost 600 / retail 1200 incl 20% VAT
        Lib.InitializeSetup();
        Lib.CreateRetailLocation(RetailA);
        Lib.CreateRetailLocationWithCalcAccounts(RetailB, CalcVATAcc, CalcMarginAcc);
        Lib.CreateInTransitLocation(Transit);
        Lib.CreateRetailItem(Item, 600, 1200, false, RetailA.Code);
        Lib.EnsureRetailPrice(Item."No.", RetailB.Code, 1200);
        Lib.PostRetailPurchaseInvoice(Item."No.", RetailA.Code, 10, 600);

        // [WHEN] Transferring 10 pcs retail A -> retail B
        Lib.PostRetailTransfer(RetailA.Code, RetailB.Code, Transit.Code, Item."No.", 10, ShptNo, RcptNo);

        // [THEN] Both retail locations end at retail value; markup moves from A's (global) accounts to B's per-location accounts
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.RetailInvAcc(RetailA.Code), -12000, 'Source retail A relieved at full retail');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.RetailInvAcc(RetailB.Code), 12000, 'Destination retail B at full retail');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.GlobalMarginAcc(), 4000, 'Source RUC reversed (debit)');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, Lib.GlobalVATAcc(), 2000, 'Source ukalkulisani PDV reversed (debit)');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, CalcMarginAcc, -4000, 'Destination B RUC added (credit)');
        Lib.AssertGLNetForTransfer(ShptNo, RcptNo, CalcVATAcc, -2000, 'Destination B ukalkulisani PDV added (credit)');
    end;
}
