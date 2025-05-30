﻿codeunit 6014451 "NPR POS Setup Safety Check"
{
    Access = Internal;
    // The purpose of this codeunit is to validate configuration of standard BC
    // setup tables that could cause the POS to run sub-optimally with a clear indication
    // of the cause. Instead we hard error on POS launch, to prevent misunderstandings again.    

    // Note: This approach should NOT be used to validate OUR setup as we can fix
    // the code we own so that it can never be poorly configured.
    // Having no setup is better than forcing a human to do correct setup.

    // It should also not be used if there is a better place for the setup validation.
    // For example, a payment button is the best place to validate correct pos payment method
    // field setup. It will feel more logical to the user than erroring if a single
    // pos payment method is missing account no. when POS launches, etc.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", 'OnInitialize', '', false, false)]
    local procedure OnInitialize()
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if not ValidateSetup() then
            POSSession.SetErrorOnInitialize(true);
    end;

    [TryFunction]
    local procedure ValidateSetup()
    begin
        //Receipt Number should always be non-blocking. In the past we had commit immediately after pulling 
        //a number, so this is not a functional difference - just slightly more efficient.
        //We have fiscal receipt number when sale ENDS for numbering without gaps, not when sale starts!                
        ValidateSalesTicketNumberSeriesGapAllowed();

        //Automatic item costing and adjusting can both batch up and cause huge slowdowns for customers that mainly use the POS with rare sales document export+post
        //as the trigger blocking the POS in the process.
        //Both should always be via job queue, report 795 and 1002
        ValidateNotAutoCostMgt();

        //Field "POS Sales Rounding Account" is mandatory in some processes and it must be checked on POS Initialization
        CheckPostingProfile();

        //Field "Return Payment Method" is mandatory
        CheckPOSPaymentMethods();

        OnAfterValidateSetup();
    end;

    local procedure ValidateSalesTicketNumberSeriesGapAllowed()
    var
        POSSession: Codeunit "NPR POS Session";
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
        AllowGapsInNosErr: Label 'Field "Implementation" must be set to "Sequence" in %1 No. Series, Line No.: %2', Comment = '%1 = No. Series Code, %2 - No. Series Line No.';
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSession(POSSession, true);
        POSSession.GetSetup(POSSetup);

        POSUnit.Get(POSSetup.GetPOSUnitNo());
        POSUnit.TestField("POS Audit Profile");
        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        POSAuditProfile.TestField("Sales Ticket No. Series");

        NoSeries.Get(POSAuditProfile."Sales Ticket No. Series");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement.GetNoSeriesLine(NoSeriesLine, POSAuditProfile."Sales Ticket No. Series", Today, false);
        if not NoSeriesManagement.MayProduceGaps(NoSeriesLine) then
            Error(AllowGapsInNosErr, NoSeriesLine."Series Code", NoSeriesLine."Line No.");
#ELSE
        NoSeriesManagement.SetNoSeriesLineFilter(NoSeriesLine, POSAuditProfile."Sales Ticket No. Series", Today);
        NoSeriesLine.FindFirst();
        NoSeriesLine.TestField("Allow Gaps in Nos.", true);
#ENDIF
    end;

    local procedure ValidateNotAutoCostMgt()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if InventorySetup.Get() then begin
            InventorySetup.TestField("Automatic Cost Posting", false);
            InventorySetup.TestField("Automatic Cost Adjustment", InventorySetup."Automatic Cost Adjustment"::Never);
        end
    end;

    local procedure CheckPostingProfile()
    var
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        POSUnit.Get(POSSetup.GetPOSUnitNo());
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;
        if not POSPostingProfile.Get(POSStore."POS Posting Profile") then
            exit;
        POSPostingProfile.TestField("POS Sales Rounding Account");
    end;

    [InternalEvent(false)]
    local procedure OnAfterValidateSetup()
    begin
    end;

    local procedure CheckPOSPaymentMethods()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        LocVersion: Version;
    begin
        if POSPaymentMethod.IsEmpty() then
            exit;
        POSPaymentMethod.FindSet();
        repeat
            if POSPaymentMethod."Created by Version" <> '' then begin
                LocVersion := Version.Create(POSPaymentMethod."Created by Version");
                if (LocVersion.Minor >= 10) and (LocVersion.Build >= 0) then //Compare with version 10.0
                    POSPaymentMethod.TestField("Return Payment Method Code");
            end;
        until POSPaymentMethod.Next() = 0;
    end;
}
