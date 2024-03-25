page 6184540 "NPR IT Setup POS Unit Step"
{
    Extensible = False;
    Caption = 'IT POS Unit Mapping';
    PageType = ListPart;
    SourceTable = "NPR IT POS Unit Mapping";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(POSStoreMappingLines)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the POS Unit Name field.';
                }
                field("Fiscal Printer IP Address"; Rec."Fiscal Printer IP Address")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Fiscal Printer IP Address field.';
                }
                field("Fiscal Printer Password"; Rec."Fiscal Printer Password")
                {
                    ApplicationArea = NPRITFiscal;
                    ToolTip = 'Specifies the value of the Fiscal Printer Password field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Init")
            {
                ApplicationArea = NPRITFiscal;
                Caption = 'Init POS Units';
                Image = Start;
                ToolTip = 'Initialize IT POS Unit Mapping with non existing POS Units.';

                trigger OnAction()
                var
                    POSUnit: Record "NPR POS Unit";
                begin
                    if not POSUnit.FindFirst() then
                        exit;

                    repeat
                        if not Rec.Get(POSUnit."No.") then begin
                            Rec.Init();
                            Rec."POS Unit No." := POSUnit."No.";
                            Rec.Insert();
                        end;
                    until POSUnit.Next() = 0;
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        if not ITPOSUnitMapping.Get(Rec."POS Unit No.") then
            exit;
        ITPOSUnitMapping.Delete();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if not ITPOSUnitMapping.Get(Rec."POS Unit No.") then
            exit;
        ITPOSUnitMapping.TransferFields(Rec);
        ITPOSUnitMapping.Modify();
    end;

    internal procedure CopyRealToTemp()
    begin
        if not ITPOSUnitMapping.FindSet() then
            exit;
        repeat
            Rec.TransferFields(ITPOSUnitMapping);
            if not Rec.Insert() then
                Rec.Modify();
        until ITPOSUnitMapping.Next() = 0;
    end;

    internal procedure ITPOSUnitMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure ITPOSUnitMappingDataToModify(): Boolean
    begin
        exit(CheckIsDataChanged());
    end;

    internal procedure CreatePOSUnitMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            ITPOSUnitMapping.TransferFields(Rec);
            if not ITPOSUnitMapping.Insert() then
                ITPOSUnitMapping.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if ((Rec."POS Unit No." <> '')
                and (Rec."Fiscal Printer IP Address" <> '')
                and (Rec."Fiscal Printer Password" <> '')) then
                exit(true);
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataChanged(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if ((Rec."POS Unit No." <> xRec."POS Unit No.")
                or (Rec."Fiscal Printer IP Address" <> xRec."Fiscal Printer IP Address")
                or (Rec."Fiscal Printer Password" <> xRec."Fiscal Printer Password")) then
                exit(true);
        until Rec.Next() = 0;
    end;

    var
        ITPOSUnitMapping: Record "NPR IT POS Unit Mapping";
}