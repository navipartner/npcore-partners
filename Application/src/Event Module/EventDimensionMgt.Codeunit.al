codeunit 6014411 "NPR Event Dimension Mgt"
{
    Access = Internal;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::DimensionManagement, 'OnAfterSetupObjectNoList', '', true, false)]
    local procedure DimensionMgtOnLoadDimensions(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    begin
        InsertObject(TempAllObjWithCaption, DATABASE::"Item Category");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR Mixed Discount");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR Period Discount");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR Quantity Discount Header");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR POS Store");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR POS Unit");
        InsertObject(TempAllObjWithCaption, DATABASE::"NPR NPRE Seating");
    end;

    local procedure InsertObject(var TempAllObjWithCaption: Record AllObjWithCaption temporary; TableID: Integer)
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if TempAllObjWithCaption.Get(TempAllObjWithCaption."Object Type"::Table, TableID) then
            exit;
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        AllObjWithCaption.SetRange("Object ID", TableID);
        if AllObjWithCaption.FindFirst() then begin
            TempAllObjWithCaption := AllObjWithCaption;
            TempAllObjWithCaption.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Create-Invoice", 'OnBeforeModifySalesLine', '', false, false)]
    local procedure JobCreateInvoiceOnBeforeModifySalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Job: Record Job; JobPlanningLine: Record "Job Planning Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        Customer: Record Customer;
        DimMgt: Codeunit DimensionManagement;
        DimSetIDArr: array[10] of Integer;
    begin
        Customer.Get(Job."Bill-to Customer No.");
        if not Customer."Prices Including VAT" then
            exit;

        if SalesLine."Job Task No." = '' then
            exit;

        SourceCodeSetup.Get();
        DimSetIDArr[1] := SalesLine."Dimension Set ID";
        DimSetIDArr[2] :=
          DimMgt.CreateDimSetFromJobTaskDim(
            SalesLine."Job No.", SalesLine."Job Task No.", SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
        DimSetIDArr[3] := GetLedgEntryDimSetID(JobPlanningLine);
        DimSetIDArr[4] := GetJobLedgEntryDimSetID(JobPlanningLine);
        DimMgt.CreateDimForSalesLineWithHigherPriorities(
          SalesLine,
          0,
          DimSetIDArr[5],
          SalesLine."Shortcut Dimension 1 Code",
          SalesLine."Shortcut Dimension 2 Code",
          SourceCodeSetup.Sales,
          DATABASE::Job);
        SalesLine."Dimension Set ID" :=
          DimMgt.GetCombinedDimensionSetID(
            DimSetIDArr, SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code");
    end;

    local procedure GetLedgEntryDimSetID(JobPlanningLine: Record "Job Planning Line"): Integer
    var
        ResLedgEntry: Record "Res. Ledger Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        GLEntry: Record "G/L Entry";
    begin
        if JobPlanningLine."Ledger Entry No." = 0 then
            exit(0);

        case JobPlanningLine."Ledger Entry Type" of
            JobPlanningLine."Ledger Entry Type"::Resource:
                begin
                    ResLedgEntry.Get(JobPlanningLine."Ledger Entry No.");
                    exit(ResLedgEntry."Dimension Set ID");
                end;
            JobPlanningLine."Ledger Entry Type"::Item:
                begin
                    ItemLedgEntry.Get(JobPlanningLine."Ledger Entry No.");
                    exit(ItemLedgEntry."Dimension Set ID");
                end;
            JobPlanningLine."Ledger Entry Type"::"G/L Account":
                begin
                    GLEntry.Get(JobPlanningLine."Ledger Entry No.");
                    exit(GLEntry."Dimension Set ID");
                end;
            else
                exit(0);
        end;
    end;

    local procedure GetJobLedgEntryDimSetID(JobPlanningLine: Record "Job Planning Line"): Integer
    var
        JobLedgerEntry: Record "Job Ledger Entry";
    begin
        if JobPlanningLine."Job Ledger Entry No." = 0 then
            exit(0);

        if JobLedgerEntry.Get(JobPlanningLine."Job Ledger Entry No.") then
            exit(JobLedgerEntry."Dimension Set ID");

        exit(0);
    end;
}

