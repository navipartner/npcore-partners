codeunit 6014606 "Dimension Lookup"
{
    // NPR5.22/VB/20160413 CASE 235391 Codeunit created to support dimension lookup
    // NPR5.22/AP/20160414 CASE 235391 Added triggering of UpdateAllLineDim

    TableNo = "Sale POS";

    trigger OnRun()
    begin
        LookupDimension(Rec);
    end;

    var
        Marshaller: Codeunit "POS Event Marshaller";
        Text001: Label 'There are no dimension values defined for %1 %2.';
        Text002: Label '%1 %2 does not exist. Please define it first.';

    local procedure LookupDimension(var Sale: Record "Sale POS")
    var
        Dim: Record Dimension;
        DimVal: Record "Dimension Value";
        DimSetEntryTmp: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        DimValues: Page "Dimension Values";
        OldDimSetID: Integer;
    begin
        if not Dim.Get(Sale.Parameters) then
          Marshaller.DisplayError('',StrSubstNo(Text002,Dim.TableCaption,Sale.Parameters),true);

        DimVal.SetRange("Dimension Code",Dim.Code);
        if DimVal.IsEmpty then
          Marshaller.DisplayError('',StrSubstNo(Text001,Dim.TableCaption,Dim.Code),true);

        DimMgt.GetDimensionSet(DimSetEntryTmp,Sale."Dimension Set ID");
        DimSetEntryTmp.SetRange("Dimension Code",Dim.Code);
        if DimSetEntryTmp.FindFirst then begin
          DimVal."Dimension Code" := Dim.Code;
          DimVal.Code := DimSetEntryTmp."Dimension Value Code";
          DimVal.Find();
        end;

        DimValues.SetRecord(DimVal);
        DimValues.SetTableView(DimVal);
        DimValues.LookupMode := true;
        if DimValues.RunModal = ACTION::LookupOK then begin
          DimValues.GetRecord(DimVal);
          DimSetEntryTmp."Dimension Code" := Dim.Code;
          DimSetEntryTmp."Dimension Value Code" := DimVal.Code;
          DimSetEntryTmp."Dimension Value ID" := DimVal."Dimension Value ID";
          if not DimSetEntryTmp.Insert() then
            DimSetEntryTmp.Modify();

          OldDimSetID := Sale."Dimension Set ID";
          Sale."Dimension Set ID" := DimSetEntryTmp.GetDimensionSetID(DimSetEntryTmp);
          Sale.Modify();

          if (OldDimSetID <> Sale."Dimension Set ID") and Sale.SalesLinesExist then
            Sale.UpdateAllLineDim(Sale."Dimension Set ID",OldDimSetID);

          Commit();
        end;
    end;
}

