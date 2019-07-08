codeunit 6014593 "Change Log Auto Enabler"
{
    // NPR5.29/NPKNAV/20170127  CASE 262678 Transport NPR5.29 - 27 januar 2017
    // NPR5.38/LS  /20171218 CASE 300124 Set property OnMissingLicense to Skip for function OnAfterCompanyOpen
    // NPR5.38/MMV /20180119 CASE 300683 Skip subscriber when installing extension
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit


    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterCompanyOpen', '', true, false)]
    local procedure OnAfterCompanyOpen()
    var
        RetailSetup: Record "Retail Setup";
        NavAppMgt: Codeunit "Nav App Mgt";
    begin
        //-NPR5.38 [300683]
        if NavAppMgt.NavAPP_IsInstalling then
          exit;
        //+NPR5.38 [300683]

        if not (CurrentClientType in [CLIENTTYPE::Windows,CLIENTTYPE::Web,CLIENTTYPE::Tablet,CLIENTTYPE::Phone,CLIENTTYPE::Desktop]) then
          exit;

        if not RetailSetup.ReadPermission then
          exit;

        if not RetailSetup.Get then
          exit;

        TestChangeLogSetup(RetailSetup);
    end;

    procedure TestChangeLogSetup(var RetailSetup: Record "Retail Setup")
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        ChangeLogSetup: Record "Change Log Setup";
    begin
        if RetailSetup."Auto Changelog Level" = RetailSetup."Auto Changelog Level"::None then
          exit;

        if not (ChangeLogSetup.WritePermission and ChangeLogSetupTable.WritePermission) then
          exit;

        if not ChangeLogSetup.Get then begin
          ChangeLogSetup.Init;
          ChangeLogSetup.Insert(true);
        end;

        if not ChangeLogSetup."Change Log Activated" then begin
          ChangeLogSetup."Change Log Activated" := true;
          ChangeLogSetup.Modify(true);
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
        TestTable(DATABASE::"Retail Setup");
        TestTable(DATABASE::Register);
        TestTable(DATABASE::"Object Output Selection");
        TestTable(DATABASE::"Report Selection Retail");
        TestTable(DATABASE::"Dependency Management Setup");

        if RetailSetup."Auto Changelog Level" = RetailSetup."Auto Changelog Level"::Extended then begin
          TestTable(DATABASE::"Payment Terms");
          TestTable(DATABASE::Currency);
          TestTable(DATABASE::"Finance Charge Terms");
          TestTable(DATABASE::Location);
          TestTable(DATABASE::"G/L Account");
          TestTable(DATABASE::"Payment Type POS");
          TestTable(DATABASE::"Item Group");
          TestTable(DATABASE::"Payment Type - Prefix");
        end;
    end;

    local procedure TestTable(TableID: Integer)
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        ModifyRec: Boolean;
    begin
        with ChangeLogSetupTable do
          if Get(TableID) then begin
            if "Log Deletion" <> "Log Deletion"::"All Fields" then begin
              "Log Deletion" := "Log Deletion"::"All Fields";
              ModifyRec := true;
            end;

            if "Log Insertion" <> "Log Insertion"::"All Fields" then begin
              "Log Insertion" := "Log Insertion"::"All Fields";
              ModifyRec := true;
            end;

            if "Log Modification" <> "Log Modification"::"All Fields" then begin
              "Log Modification" := "Log Modification"::"All Fields";
              ModifyRec := true;
            end;

            if ModifyRec then
              if Modify then;
          end else begin
            Init;
            "Table No." := TableID;
            "Log Deletion" := "Log Deletion"::"All Fields";
            "Log Insertion" := "Log Insertion"::"All Fields";
            "Log Modification" := "Log Modification"::"All Fields";
            if Insert then;
          end;
    end;

    procedure ValidateChangeLogLevel(var Rec: Record "Retail Setup";var xRec: Record "Retail Setup")
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
                                  DATABASE::"Retail Setup",
                                  DATABASE::Register,
                                  DATABASE::"Object Output Selection",
                                  DATABASE::"Report Selection Retail",
                                  DATABASE::"Dependency Management Setup",
                                  DATABASE::"Payment Terms",
                                  DATABASE::Currency,
                                  DATABASE::"Finance Charge Terms",
                                  DATABASE::Location,
                                  DATABASE::"G/L Account",
                                  DATABASE::"Payment Type POS",
                                  DATABASE::"Item Group",
                                  DATABASE::"Payment Type - Prefix");

        ChangeLogSetupTable.SetFilter("Table No.", FilterString);
        ChangeLogSetupTable.ModifyAll("Log Deletion", ChangeLogSetupTable."Log Deletion"::" ");
        ChangeLogSetupTable.ModifyAll("Log Insertion", ChangeLogSetupTable."Log Insertion"::" ");
        ChangeLogSetupTable.ModifyAll("Log Modification", ChangeLogSetupTable."Log Modification"::" ");

        TestChangeLogSetup(Rec);
    end;
}

