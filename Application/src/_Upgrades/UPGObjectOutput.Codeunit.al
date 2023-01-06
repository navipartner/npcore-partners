codeunit 6059857 "NPR UPG Object Output"
{
    Access = Internal;
    Subtype = Upgrade;

    //In older versions of np retail we had manually replaced a lot of our Report.Run() calls with calls to a wrapper that checked Object Output table and 
    //supported a different route of Report.SaveAs (Pdf) into a completely custom silent print flow. 
    //Now that BC has built in universal report print event publishers, we are removing all our custom code and replacing with subscribers to those. 
    //Not only is the code simpler, but the report handling will finally be universal across all calls to Report.Run(), even those in the baseapp.

    trigger OnRun()
    begin
        UpgradeDirectPrint();
        UpgradePrintNodePdf();
    end;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Object Output', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Object Output")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        UpgradeDirectPrint();
        UpgradePrintNodePdf();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Object Output"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeDirectPrint()
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        ObjectOutputSelection2: Record "NPR Object Output Selection";
        HWCPrinter: Record "NPR HWC Printer";
        PrinterSelection: Record "Printer Selection";
        CreatedPrinters: List of [Text];
    begin
        ObjectOutputSelection.SetRange("Output Type", ObjectOutputSelection."Output Type"::"Printer Name");
        ObjectOutputSelection.SetRange("Object Type", ObjectOutputSelection."Object Type"::Report);
        ObjectOutputSelection.SetFilter("Output Path", '<>%1', '');
        if ObjectOutputSelection.FindSet() then begin
            repeat
                if not CreatedPrinters.Contains(HWCPrinter.Name) then begin
                    HWCPrinter.Init();
                    HWCPrinter.ID := ObjectOutputSelection."Output Path";
                    HWCPrinter.Name := ObjectOutputSelection."Output Path";
                    if HWCPrinter.Insert() then; //skip if duplicate
                    CreatedPrinters.Add(HWCPrinter.Name);
                end;

                PrinterSelection.Init();
                PrinterSelection."Printer Name" := CopyStr('NPR_HWC_' + ObjectOutputSelection."Output Path", 1, 250);
                PrinterSelection."Report ID" := ObjectOutputSelection."Object ID";
                PrinterSelection."User ID" := ObjectOutputSelection."User ID";
                if PrinterSelection.Insert() then; //skip if duplicate

                ObjectOutputSelection2 := ObjectOutputSelection;
                ObjectOutputSelection2.Delete();
            until ObjectOutputSelection.Next() = 0;
        end;
    end;

    local procedure UpgradePrintNodePdf()
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        ObjectOutputSelection2: Record "NPR Object Output Selection";
        PrinterSelection: Record "Printer Selection";
        PrintNodePrinter: Record "NPR PrintNode Printer";
    begin
        ObjectOutputSelection.SetRange("Output Type", ObjectOutputSelection."Output Type"::"PrintNode PDF");
        ObjectOutputSelection.SetRange("Object Type", ObjectOutputSelection."Object Type"::Report);
        ObjectOutputSelection.SetFilter("Output Path", '<>%1', '');
        if ObjectOutputSelection.FindSet() then begin
            repeat
                //if both user ID and object ID was a wildcard before we skip upgrading because everyone will be surprised if the new report subscribers handle EVERY SINGLE report in the application.
                if (ObjectOutputSelection."User ID" <> '') or (ObjectOutputSelection."Object ID" <> 0) then begin
                    PrinterSelection.Init();
                    PrinterSelection."Printer Name" := CopyStr('NPR_PRINTNODE_' + ObjectOutputSelection."Output Path", 1, 250);
                    PrinterSelection."Report ID" := ObjectOutputSelection."Object ID";
                    PrinterSelection."User ID" := ObjectOutputSelection."User ID";
                    if PrinterSelection.Insert() then; //skip if duplicate
                end;
                ObjectOutputSelection2 := ObjectOutputSelection;
                ObjectOutputSelection2.Delete();
            until ObjectOutputSelection.Next() = 0;
        end;

        if PrintNodePrinter.FindSet(true) then begin
            repeat
                PrintNodePrinter."BC Paper Source" := PrintNodePrinter."BC Paper Source"::AutomaticFeed;
                PrintNodePrinter."BC Paper Size" := PrintNodePrinter."BC Paper Size"::A4;
                PrintNodePrinter.Modify();
            until PrintNodePrinter.Next() = 0;
        end;
    end;
}