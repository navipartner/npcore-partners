codeunit 6014593 "NPR Change Log Auto Enabler"
{
    // NPR5.29/NPKNAV/20170127  CASE 262678 Transport NPR5.29 - 27 januar 2017
    // NPR5.38/LS  /20171218 CASE 300124 Set property OnMissingLicense to Skip for function OnAfterInitialization
    // NPR5.38/MMV /20180119 CASE 300683 Skip subscriber when installing extension
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit


    trigger OnRun()
    begin
    end;

    var
        RunSilent: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterInitialization', '', true, false)]
    local procedure OnAfterInitialization()
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        if NavApp.IsInstalling() then
            exit;

        if not (CurrentClientType() in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            exit;

        if not RetailSetup.ReadPermission() then
            exit;

        if not RetailSetup.Get() then
            exit;

        RunSilent := true;
        TestChangeLogSetup(RetailSetup);
    end;

    procedure TestChangeLogSetup(var RetailSetup: Record "NPR Retail Setup")
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        ChangeLogSetup: Record "Change Log Setup";
    begin
        if RetailSetup."Auto Changelog Level" = RetailSetup."Auto Changelog Level"::None then
            exit;

        if not (ChangeLogSetup.WritePermission() and ChangeLogSetupTable.WritePermission()) then
            exit;

        if not ChangeLogSetup.Get() then begin
            ChangeLogSetup.Init();
            if not RunSilent then
                ChangeLogSetup.Insert(true)
            else
                if not ChangeLogSetup.Insert(true) then
                    exit;
        end;

        if not ChangeLogSetup."Change Log Activated" then begin
            ChangeLogSetup."Change Log Activated" := true;
            if not RunSilent then
                ChangeLogSetup.Modify(true)
            else
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

        if RetailSetup."Auto Changelog Level" = RetailSetup."Auto Changelog Level"::Extended then begin
            TestTable(DATABASE::"Payment Terms");
            TestTable(DATABASE::Currency);
            TestTable(DATABASE::"Finance Charge Terms");
            TestTable(DATABASE::Location);
            TestTable(DATABASE::"G/L Account");
            TestTable(DATABASE::"NPR Payment Type POS");
            TestTable(DATABASE::"NPR Item Group");
            TestTable(DATABASE::"NPR Payment Type - Prefix");
        end;
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

    procedure ValidateChangeLogLevel(var Rec: Record "NPR Retail Setup"; var xRec: Record "NPR Retail Setup")
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        FilterString: Text;
    begin
        //Disables everything on the tables that are managed by this codeunit and runs validation of the new level set.
        if Rec.IsTemporary or xRec.IsTemporary then
            exit;

        if Rec."Auto Changelog Level" = xRec."Auto Changelog Level" then
            exit;

        FilterString := StrSubstNo('%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11|%12|%13|%14|%15|%16|%17|%18|%19|%20|%21|%22|%23|%24',
                                  DATABASE::"Report Selections",
                                  DATABASE::"Printer Selection",
                                  DATABASE::"Company Information",
                                  DATABASE::"User Setup",
                                  DATABASE::"General Ledger Setup",
                                  DATABASE::"Source Code Setup",
                                  DATABASE::"General Posting Setup",
                                  DATABASE::"Sales & Receivables Setup",
                                  DATABASE::"Purchases & Payables Setup",
                                  DATABASE::"Inventory Setup",
                                  DATABASE::"VAT Posting Setup",
                                  DATABASE::"NPR Retail Setup",
                                  DATABASE::"NPR Register",
                                  DATABASE::"NPR Object Output Selection",
                                  DATABASE::"NPR Report Selection Retail",
                                  DATABASE::"NPR Dependency Mgt. Setup",
                                  DATABASE::"Payment Terms",
                                  DATABASE::Currency,
                                  DATABASE::"Finance Charge Terms",
                                  DATABASE::Location,
                                  DATABASE::"G/L Account",
                                  DATABASE::"NPR Payment Type POS",
                                  DATABASE::"NPR Item Group",
                                  DATABASE::"NPR Payment Type - Prefix");

        ChangeLogSetupTable.SetFilter("Table No.", FilterString);
        ChangeLogSetupTable.ModifyAll("Log Deletion", ChangeLogSetupTable."Log Deletion"::" ");
        ChangeLogSetupTable.ModifyAll("Log Insertion", ChangeLogSetupTable."Log Insertion"::" ");
        ChangeLogSetupTable.ModifyAll("Log Modification", ChangeLogSetupTable."Log Modification"::" ");

        TestChangeLogSetup(Rec);
    end;
}

