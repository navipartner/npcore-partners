codeunit 6014451 "Set Dimension POS"
{
    // #235391/RA/20160509 CASE 235391 Add demension to Sales POS lines

    TableNo = "Sale POS";

    trigger OnRun()
    begin
        SetDimension(Rec);
    end;

    var
        Text001: Label 'Function parameter wrong configured';
        Text002: Label 'Dimension %1 does not exist';
        Text003: Label 'Dimension Value %1 does not exist for demension %2';

    local procedure SetDimension(var Sale: Record "Sale POS")
    var
        Dim: Record Dimension;
        DimVal: Record "Dimension Value";
        DimSetEntryTmp: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        DimValues: Page "Dimension Values";
        DimText: Code[20];
        DimValueText: Code[20];
        OldDimSetID: Integer;
    begin
        if (Sale.Parameters <> '') and (StrPos(Sale.Parameters, ',') <> 0) then begin
          DimText      := CopyStr(Sale.Parameters, 1, StrPos(Sale.Parameters, ',') -1);
          DimValueText := CopyStr(Sale.Parameters, StrPos(Sale.Parameters, ',') + 1);
          if Dim.Get(DimText) then begin
            if DimVal.Get(Dim.Code, DimValueText) then begin
              DimMgt.GetDimensionSet(DimSetEntryTmp, Sale."Dimension Set ID");
              DimSetEntryTmp.SetRange("Dimension Code", Dim.Code);
              if DimSetEntryTmp.FindFirst then;
              DimSetEntryTmp."Dimension Code"       := Dim.Code;
              DimSetEntryTmp."Dimension Value Code" := DimVal.Code;
              DimSetEntryTmp."Dimension Value ID"   := DimVal."Dimension Value ID";
              if not DimSetEntryTmp.Insert() then
                DimSetEntryTmp.Modify();
              OldDimSetID := Sale."Dimension Set ID";
              Sale."Dimension Set ID" := DimSetEntryTmp.GetDimensionSetID(DimSetEntryTmp);
              Sale.Modify();
              if (OldDimSetID <> Sale."Dimension Set ID") and Sale.SalesLinesExist then
                Sale.UpdateAllLineDim(Sale."Dimension Set ID", OldDimSetID);
              Commit();
            end else
              Error(StrSubstNo(Text003, DimValueText, DimText));
          end else
            Error(StrSubstNo(Text002, DimText));
        end else
          Error(Text001);
    end;
}

