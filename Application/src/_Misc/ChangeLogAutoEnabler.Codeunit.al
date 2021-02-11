codeunit 6014593 "NPR Change Log Auto Enabler"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterInitialization', '', true, false)]
    local procedure OnAfterInitialization()
    var
        ChangeLogSetup: Record "Change Log Setup";
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
    begin
        if NavApp.IsInstalling() then
            exit;

        if not GuiAllowed then
            exit;

        if not (ChangeLogSetup.WritePermission() and ChangeLogSetupTable.WritePermission()) then
            exit;

        SetChangeLogSetup();
    end;

    procedure SetChangeLogSetup()
    var
        ChangeLogSetup: Record "Change Log Setup";
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
    begin
        if not ChangeLogSetup.Get() then begin
            ChangeLogSetup.Init();
            if not ChangeLogSetup.Insert(true) then
                exit;
        end;

        if not ChangeLogSetup."Change Log Activated" then begin
            ChangeLogSetup."Change Log Activated" := true;
            if ChangeLogSetup.Modify(true) then;
        end;

        TestTable(DATABASE::"Report Selections");
        TestTable(DATABASE::"Printer Selection");
        TestTable(DATABASE::"Company Information");
        TestTable(DATABASE::"User Setup");
        TestTable(DATABASE::"General Ledger Setup");
        TestTable(DATABASE::"Source Code Setup");
        TestTable(DATABASE::"General Posting Setup");
        TestTable(DATABASE::"Sales & Receivables Setup");
        TestTable(DATABASE::"Purchases & Payables Setup");
        TestTable(DATABASE::"Inventory Setup");
        TestTable(DATABASE::"VAT Posting Setup");
        TestTable(DATABASE::"NPR Retail Setup");
        TestTable(DATABASE::"NPR Register");
        TestTable(DATABASE::"NPR Object Output Selection");
        TestTable(DATABASE::"NPR Report Selection Retail");
        TestTable(DATABASE::"NPR Dependency Mgt. Setup");
        TestTable(DATABASE::"NPR POS Unit");
        TestTable(DATABASE::"NPR POS Store");
        TestTable(DATABASE::"NPR POS Audit Profile");
        TestTable(DATABASE::"NPR POS View Profile");
        TestTable(DATABASE::"NPR POS Posting Profile");
        TestTable(DATABASE::"NPR POS End of Day Profile");
        TestTable(DATABASE::"NPR POS Payment Method");
        TestTable(DATABASE::"NPR POS Payment Bin");
        TestTable(DATABASE::"NPR RP Template Header");
        TestTable(DATABASE::"NPR EFT BIN Group");
        TestTable(DATABASE::"NPR Item Group");
        TestTable(DATABASE::"NPR Payment Type POS");
    end;

    local procedure TestTable(TableID: Integer)
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        ModifyRec: Boolean;
    begin
        if ChangeLogSetupTable.Get(TableID) then begin
            if ChangeLogSetupTable."Log Deletion" <> ChangeLogSetupTable."Log Deletion"::"All Fields" then begin
                ChangeLogSetupTable."Log Deletion" := ChangeLogSetupTable."Log Deletion"::"All Fields";
                ModifyRec := true;
            end;

            if ChangeLogSetupTable."Log Insertion" <> ChangeLogSetupTable."Log Insertion"::"All Fields" then begin
                ChangeLogSetupTable."Log Insertion" := ChangeLogSetupTable."Log Insertion"::"All Fields";
                ModifyRec := true;
            end;

            if ChangeLogSetupTable."Log Modification" <> ChangeLogSetupTable."Log Modification"::"All Fields" then begin
                ChangeLogSetupTable."Log Modification" := ChangeLogSetupTable."Log Modification"::"All Fields";
                ModifyRec := true;
            end;

            if ModifyRec then
                if ChangeLogSetupTable.Modify() then;
        end else begin
            ChangeLogSetupTable.Init();
            ChangeLogSetupTable."Table No." := TableID;
            ChangeLogSetupTable."Log Deletion" := ChangeLogSetupTable."Log Deletion"::"All Fields";
            ChangeLogSetupTable."Log Insertion" := ChangeLogSetupTable."Log Insertion"::"All Fields";
            ChangeLogSetupTable."Log Modification" := ChangeLogSetupTable."Log Modification"::"All Fields";
            if ChangeLogSetupTable.Insert() then;
        end;
    end;
}

