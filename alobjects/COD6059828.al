codeunit 6059828 "Upgrade NPR5.53"
{
    // NPR5.53/MMV /20191025 CASE 349793 Moved warranty sales workflow step to another codeunit.
    // NPR5.53/ALPO/20191024 CASE 371955 Rrounding related fields moved to POS Posting Profiles
    // NPR5.53/ALPO/20191024 CASE 371956 Dimensions: POS Store & POS Unit integration. Copy all dimensins from Cash Registers to respective POS Units
    // NPR5.53/ALPO/20191022 CASE 373743 Field "Sales Ticket Series" moved from "Cash Register" to "POS Audit Profile"
    // NPR5.53/ALPO/20191031 CASE 375258 Restore posted dimension consistency
    // NPR5.53/BHR /20191008 CASE 369354 Delete Fields in the "Salesperson/Purchaser" table
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements
    // NPR5.53/THRO/20191216 CASE 382232 Minimum Amount for issuing Retial voucher moved from Payment Type POS to NpRv Voucher Type
    // NPR5.53/ALPO/20200102 CASE 360258 NPRE Waiter Pad Line: fields "Sent to. Kitchen Print" and "Print Category" moved to a subtable
    // NPR5.53/ALPO/20200204 CASE 387750 Table "POS Info POS Entry": added fields: "Document No.", "Entry Date", "POS Unit No.", "Salesperson Code"

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    var
        GLSetup: Record "General Ledger Setup";
        POSPostingControl: Codeunit "POS Posting Control";

    //[TableSyncSetup]
    procedure UpgradeTables(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        //DataUpgradeMgt.SetTableSyncSetup(DATABASE::"",DATABASE::"",TableSynchSetup.Mode::Force);
        //-NPR5.53 [349793]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"POS Audit Profile", 0, TableSynchSetup.Mode::Force);
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"POS Entry Output Log", 0, TableSynchSetup.Mode::Force);
        //+NPR5.53 [349793]
        //-NPR5.53 [371955]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::Register, DATABASE::"Upgrade Register", TableSynchSetup.Mode::Copy);  //371955,373743
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Retail Setup", DATABASE::"Upgrade Retail Setup", TableSynchSetup.Mode::Copy);
        //+NPR5.53 [371955]
        //-NPR5.53 [369354]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"Salesperson/Purchaser", 0, TableSynchSetup.Mode::Force);  //Remove Fields from Salesperson/Purchaser
        //+NPR5.53 [369354]
        //-NPR5.53 [360258]
        DataUpgradeMgt.SetTableSyncSetup(DATABASE::"NPRE Waiter Pad Line", DATABASE::"Upgrade NPRE Waiter Pad Line", TableSynchSetup.Mode::Copy);  //Field "Print Category" moved to a subtable
        //+NPR5.53 [360258]
    end;

    //[UpgradePerCompany]
    procedure UpgradeData()
    begin
        MoveWarrantyPrintStep(); //NPR5.53 [349793]
        ProcessRoundingFields;  //NPR5.53 [371955], NPR5.53 [373743]
        CopyCashRegisterDimsToPOSUnitDims;  //NPR5.53 [371956]
        RestorePostedPOSDimConsistency();  //NPR5.53 [375258]
        GeneratRaptorDefaultActions;  //NPR5.53 [377727]
        UpdateRetailVoucherType; //NPR5.53 [382232]
        //-NPR5.53 [360258]
        WPadLineDataUpgrade;
        NPREPrintTemplateSelectionUpgrade;
        PrintTemplateUpgrade;
        //+NPR5.53 [360258]
        UpdatePOSInfoPOSEntry;  //NPR5.53 [388666]
    end;

    procedure MoveWarrantyPrintStep()
    var
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
        POSSalesWorkflowStep2: Record "POS Sales Workflow Step";
    begin
        //-NPR5.53 [349793]
        with POSSalesWorkflowStep do begin
            SetRange("Subscriber Codeunit ID", 6014576);
            if FindSet(true, true) then
                repeat
                    POSSalesWorkflowStep2 := POSSalesWorkflowStep;
                    POSSalesWorkflowStep2.Rename("Set Code", "Workflow Code", 6150737, "Subscriber Function");
                until Next = 0;
        end;
        //+NPR5.53 [349793]
    end;

    local procedure RestorePostedPOSDimConsistency()
    var
        AuditRoll: Record "Audit Roll";
        POSEntry: Record "POS Entry";
        POSPaymentLine: Record "POS Payment Line";
        POSSalesLine: Record "POS Sales Line";
    begin
        //-NPR5.53 [375258]
        GLSetup.Get;
        with POSEntry do
            if FindSet(true) then
                repeat
                    if DimSetIDUpdated("Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID") then
                        Modify;
                until Next = 0;

        with POSSalesLine do
            if FindSet(true) then
                repeat
                    if DimSetIDUpdated("Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID") then
                        Modify;
                until Next = 0;

        with POSPaymentLine do
            if FindSet(true) then
                repeat
                    if DimSetIDUpdated("Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID") then
                        Modify;
                until Next = 0;

        with AuditRoll do
            if FindSet(true) then
                repeat
                    if DimSetIDUpdated("Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", "Dimension Set ID") then
                        Modify;
                until Next = 0;
        //+NPR5.53 [375258]
    end;

    local procedure DimSetIDUpdated(var GlobalDim1: Code[20]; var GlobalDim2: Code[20]; var DimSetID: Integer): Boolean
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
    begin
        //-NPR5.53 [375258]
        if POSPostingControl.DimUsageIsConsistent(GlobalDim1, GlobalDim2, DimSetID) then
            exit(false);

        DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);

        if GLSetup."Global Dimension 1 Code" = '' then
            GlobalDim1 := ''
        else
            UpdateDimSet(TempDimSetEntry, GLSetup."Global Dimension 1 Code", GlobalDim1);

        if GLSetup."Global Dimension 2 Code" = '' then
            GlobalDim2 := ''
        else
            UpdateDimSet(TempDimSetEntry, GLSetup."Global Dimension 2 Code", GlobalDim2);

        DimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
        exit(true);
        //+NPR5.53 [375258]
    end;

    local procedure UpdateDimSet(var DimSetEntry: Record "Dimension Set Entry"; DimCode: Code[20]; DimValueCode: Code[20])
    var
        DimValue: Record "Dimension Value";
    begin
        //-NPR5.53 [375258]
        if DimSetEntry.Get(DimSetEntry."Dimension Set ID", DimCode) then begin
            if (DimSetEntry."Dimension Value Code" <> DimValueCode) or (DimValueCode = '') then
                DimSetEntry.Delete
            else
                exit;
        end;
        if DimValueCode <> '' then begin
            DimSetEntry."Dimension Code" := DimCode;
            DimSetEntry."Dimension Value Code" := DimValueCode;
            if not DimValue.Get(DimSetEntry."Dimension Code", DimSetEntry."Dimension Value Code") then begin
                DimValue.Init;
                DimValue."Dimension Code" := DimSetEntry."Dimension Code";
                DimValue.Code := DimSetEntry."Dimension Value Code";
                DimValue.Insert(true);
            end;
            DimSetEntry."Dimension Value ID" := DimValue."Dimension Value ID";
            DimSetEntry.Insert;
        end;
        //+NPR5.53 [375258]
    end;

    local procedure ProcessRoundingFields()
    var
        POSAuditProfile: Record "POS Audit Profile";
        POSAuditProfile2: Record "POS Audit Profile";
        POSPostingProfile: Record "POS Posting Profile";
        POSUnit: Record "POS Unit";
        CashRegister: Record Register;
        RetailSetup: Record "Retail Setup";
        UpgradeCashRegister: Record "Upgrade Register";
        UpgradeRetailSetup: Record "Upgrade Retail Setup";
    begin
        //-NPR5.53 [371955]
        if POSPostingProfile.IsEmpty then begin
            POSPostingProfile.Init;
            POSPostingProfile.Code := 'DEFAULT';
            POSPostingProfile.Description := 'Created by upgrade process';
            POSPostingProfile.Insert;
        end;

        if UpgradeRetailSetup.Get then begin
            POSPostingProfile.ModifyAll("POS Sales Amt. Rndng Precision", UpgradeRetailSetup."Amount Rounding Precision");
            UpgradeRetailSetup.DeleteAll;
        end;

        if UpgradeCashRegister.FindSet then
            repeat
                if UpgradeCashRegister.Rounding <> '' then begin
                    POSPostingProfile.SetFilter("POS Sales Rounding Account", '%1|%2', '', UpgradeCashRegister.Rounding);
                    if POSPostingProfile.FindFirst then begin
                        if POSPostingProfile."POS Sales Rounding Account" = '' then begin
                            POSPostingProfile."POS Sales Rounding Account" := UpgradeCashRegister.Rounding;
                            POSPostingProfile.Modify;
                        end;
                    end else begin
                        POSPostingProfile.SetRange("POS Sales Rounding Account");
                        POSPostingProfile.FindFirst;
                        POSPostingProfile.Code := UpgradeCashRegister.Rounding;
                        POSPostingProfile."POS Sales Rounding Account" := UpgradeCashRegister.Rounding;
                        POSPostingProfile.Insert;
                    end;
                    if POSUnit.Get(UpgradeCashRegister."Register No.") then
                        if POSUnit."POS Posting Profile" <> POSPostingProfile.Code then begin
                            POSUnit."POS Posting Profile" := POSPostingProfile.Code;
                            POSUnit.Modify;
                        end;
                end;

                //-NPR5.53 [373743]
                //Move Sales Ticket No. Series to POS Audit Profile
                if UpgradeCashRegister."Sales Ticket Series" <> '' then
                    if POSUnit.Get(UpgradeCashRegister."Register No.") then begin
                        case true of
                            (POSUnit."POS Audit Profile" = '') or not POSAuditProfile.Get(POSUnit."POS Audit Profile"):
                                begin
                                    POSAuditProfile.Init;
                                    POSAuditProfile.Code := POSUnit."POS Audit Profile";
                                    if POSAuditProfile.Code = '' then
                                        POSAuditProfile.Code := UpgradeCashRegister."Sales Ticket Series";
                                    if not POSAuditProfile.Find then
                                        POSAuditProfile.Insert;
                                    POSAuditProfile."Sales Ticket No. Series" := UpgradeCashRegister."Sales Ticket Series";
                                    POSAuditProfile.Modify;
                                end;

                            POSAuditProfile.Get(POSUnit."POS Audit Profile"):
                                begin
                                    if POSAuditProfile."Sales Ticket No. Series" = '' then begin
                                        POSAuditProfile."Sales Ticket No. Series" := UpgradeCashRegister."Sales Ticket Series";
                                        POSAuditProfile.Modify;
                                    end else
                                        if POSAuditProfile."Sales Ticket No. Series" <> UpgradeCashRegister."Sales Ticket Series" then begin
                                            POSAuditProfile2 := POSAuditProfile;
                                            POSAuditProfile.Code := StrSubstNo('%1-01', CopyStr(POSAuditProfile.Code, 1, MaxStrLen(POSAuditProfile.Code) - 3));
                                            while POSAuditProfile.Find do
                                                POSAuditProfile.Code := IncStr(POSAuditProfile.Code);
                                            POSAuditProfile.TransferFields(POSAuditProfile2, false);
                                            POSAuditProfile.Insert;
                                            POSAuditProfile."Sales Ticket No. Series" := UpgradeCashRegister."Sales Ticket Series";
                                            POSAuditProfile.Modify;
                                        end;
                                end;
                        end;
                        if POSUnit."POS Audit Profile" <> POSAuditProfile.Code then begin
                            POSUnit."POS Audit Profile" := POSAuditProfile.Code;
                            POSUnit.Modify;
                        end;
                    end;
                //+NPR5.53 [373743]
                UpgradeCashRegister.Delete;
            until UpgradeCashRegister.Next = 0;
        //+NPR5.53 [371955]
    end;

    local procedure CopyCashRegisterDimsToPOSUnitDims()
    var
        DefaultDim: Record "Default Dimension";
        DefaultDim2: Record "Default Dimension";
        CashRegister: Record Register;
        POSUnit: Record "POS Unit";
    begin
        //-NPR5.53 [371956]
        if CashRegister.FindSet then
            repeat
                DefaultDim.SetRange("Table ID", DATABASE::Register);
                DefaultDim.SetRange("No.", CashRegister."Register No.");
                if DefaultDim.FindSet then begin
                    if not POSUnit.Get(CashRegister."Register No.") then begin
                        POSUnit.Init;
                        POSUnit."No." := CashRegister."Register No.";
                        POSUnit.Name := 'Created by Dimension Upgrade Process';
                        POSUnit.Insert;
                    end;
                    DefaultDim2.SetRange("Table ID", DATABASE::"POS Unit");
                    DefaultDim2.SetRange("No.", POSUnit."No.");
                    DefaultDim2.DeleteAll;
                    repeat
                        DefaultDim2 := DefaultDim;
                        DefaultDim2."Table ID" := DATABASE::"POS Unit";
                        DefaultDim2.Insert;
                    until DefaultDim.Next = 0;
                    POSUnit."Global Dimension 1 Code" := CashRegister."Global Dimension 1 Code";
                    POSUnit."Global Dimension 2 Code" := CashRegister."Global Dimension 2 Code";
                    POSUnit.Modify;
                    DefaultDim.DeleteAll;
                end;
            until CashRegister.Next = 0;
        //+NPR5.53 [371956]
    end;

    local procedure GeneratRaptorDefaultActions()
    var
        RaptorSetup: Record "Raptor Setup";
        RaptorManagement: Codeunit "Raptor Management";
    begin
        //-NPR5.53 [377727]
        if RaptorSetup.Get then
            RaptorManagement.InitializeDefaultActions(false, true);
        //+NPR5.53 [377727]
    end;

    procedure UpdateRetailVoucherType()
    var
        NpRvVoucherType: Record "NpRv Voucher Type";
        PaymentTypePOS: Record "Payment Type POS";
    begin
        //-NPR5.53 [382232]
        if NpRvVoucherType.IsEmpty then
            exit;
        NpRvVoucherType.FindSet;
        repeat
            if (NpRvVoucherType."Minimum Amount Issue" = 0) and (NpRvVoucherType."Payment Type" <> '') then
                if PaymentTypePOS.Get(NpRvVoucherType."Payment Type") then
                    if PaymentTypePOS."Minimum Amount" > 0 then begin
                        NpRvVoucherType."Minimum Amount Issue" := PaymentTypePOS."Minimum Amount";
                        NpRvVoucherType.Modify;
                    end;
        until NpRvVoucherType.Next = 0;
        //+NPR5.53 [382232]
    end;

    local procedure WPadLineDataUpgrade()
    var
        FlowStatus: Record "NPRE Flow Status";
        PrintCategory: Record "NPRE Print Category";
        PrintTemplate: Record "NPRE Print Template";
        WaiterPadLine: Record "NPRE Waiter Pad Line";
        UpgradeWaiterPadLine: Record "Upgrade NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPRE Restaurant Print";
        WaiterPadPOSMgt: Codeunit "NPRE Waiter Pad POS Management";
    begin
        //-NPR5.53 [360258]
        with UpgradeWaiterPadLine do
            if FindSet then
                repeat
                    if WaiterPadLine.Get("Waiter Pad No.", "Line No.") then begin
                        if "Sent To. Kitchen Print" then
                            RestaurantPrint.LogWaiterPadLinePrint(WaiterPadLine, PrintTemplate."Print Type"::"Kitchen Order", FlowStatus."Status Object"::WaiterPadLineMealFlow, '', "Print Category", 0DT);
                        if "Print Category" <> '' then begin
                            PrintCategory.Code := "Print Category";
                            if not PrintCategory.Find then
                                PrintCategory.Init;
                            WaiterPadPOSMgt.AddWPadLinePrintCategory(WaiterPadLine, PrintCategory);
                        end;
                    end;
                    Delete;
                until Next = 0;
        //+NPR5.53 [360258]
    end;

    local procedure NPREPrintTemplateSelectionUpgrade()
    var
        PrintTemplate: Record "NPRE Print Template";
        PrintTemplate2: Record "NPRE Print Template";
    begin
        //-NPR5.53 [360258]
        PrintTemplate.SetRange("Print Type", PrintTemplate."Print Type"::"Pre Receipt");
        if not PrintTemplate.IsEmpty then
            exit;  //Already upgraded

        PrintTemplate.SetRange("Print Type", PrintTemplate."Print Type"::"Serving Request");
        if PrintTemplate.FindSet then
            repeat
                PrintTemplate2 := PrintTemplate;
                PrintTemplate2."Print Type" := PrintTemplate2."Print Type"::"Pre Receipt";
                PrintTemplate2.Insert;

                PrintTemplate.Delete;
            until PrintTemplate.Next = 0;
        //+NPR5.53 [360258]
    end;

    local procedure PrintTemplateUpgrade()
    var
        RPDataItemLinks: Record "RP Data Item Links";
        RPDataItemLinks2: Record "RP Data Item Links";
        RPTemplateHeader: Record "RP Template Header";
        RPTemplateMgt: Codeunit "RP Template Mgt.";
    begin
        //-NPR5.53 [360258]
        RPDataItemLinks.SetRange("Table ID", DATABASE::"NPRE Waiter Pad Line");
        RPDataItemLinks.SetRange("Field ID", 5);  //Removed field "Sent to. Kitchen Print"
        if RPDataItemLinks.FindSet then
            repeat
                if RPTemplateHeader.Get(RPDataItemLinks."Data Item Code") then begin
                    if not RPTemplateHeader.Archived then
                        RPDataItemLinks.Delete(true)
                    else begin
                        RPTemplateMgt.CreateNewVersion(RPTemplateHeader);
                        RPTemplateHeader."Version Comments" := CopyStr('Cleared links to obsolete field "Sent to. Kitchen Print"', 1, MaxStrLen(RPTemplateHeader."Version Comments"));
                        RPTemplateHeader.Modify(true);
                        RPDataItemLinks2.CopyFilters(RPDataItemLinks);
                        RPDataItemLinks2.SetRange("Data Item Code", RPTemplateHeader.Code);
                        RPDataItemLinks2.DeleteAll;
                    end;
                end;
            until RPDataItemLinks.Next = 0;
        //+NPR5.53 [360258]
    end;

    local procedure UpdatePOSInfoPOSEntry()
    var
        POSEntry: Record "POS Entry";
        POSInfoPOSEntry: Record "POS Info POS Entry";
    begin
        //-NPR5.53 [388666]
        if POSInfoPOSEntry.FindSet(true) then
            repeat
                if POSEntry.Get(POSInfoPOSEntry."POS Entry No.") then begin
                    POSInfoPOSEntry."Document No." := POSEntry."Document No.";
                    POSInfoPOSEntry."Entry Date" := POSEntry."Entry Date";
                    POSInfoPOSEntry."POS Unit No." := POSEntry."POS Unit No.";
                    POSInfoPOSEntry."Salesperson Code" := POSEntry."Salesperson Code";
                    POSInfoPOSEntry.Modify;
                end;
            until POSInfoPOSEntry.Next = 0;
        //+NPR5.53 [388666]
    end;
}

