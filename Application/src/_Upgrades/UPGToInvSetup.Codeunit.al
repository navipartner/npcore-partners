codeunit 6059904 "NPR UPG To Inv. Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG To Inv. Setup', 'OnUpgradePerCompany');

        // Run upgrade code
        Upgrade();

        LogMessageStopwatch.LogFinish();
    end;

#pragma warning disable AA0137
    procedure Upgrade()
    var
        InventorySetup: Record "Inventory Setup";
        VarietySetup: Record "NPR Variety Setup";
    begin
        //Variant Mandatory if exist
#IF NOT (BC17 or BC18 or BC19 or BC20)         
        if not InventorySetup.Get() then
            exit;
        if VarietySetup.Get() then begin
            if VarietySetup."Item Journal Blocking" <> VarietySetup."Item Journal Blocking"::AllowNonVariants then begin
                InventorySetup."Variant Mandatory if Exists" := true;
                InventorySetup.Modify();

                VarietySetup."Item Journal Blocking" := VarietySetup."Item Journal Blocking"::AllowNonVariants;
                VarietySetup.Modify();
            end;
        end;
#ENDIF
    end;
#pragma warning restore AA0137    
}
