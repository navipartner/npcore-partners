page 6150848 "NPR POS Units Modify Step"
{
    Extensible = False;
    Caption = 'POS Units';
    PageType = ListPart;
    InsertAllowed = false;
    SourceTable = "NPR POS Unit";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Defines name of POS Unit';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Defines in which status POS is: 1. Open POS is active in the moment, 2. Closed POS is closed in the moment, end of day is done, 3. End of Day POS is in the process of end of day in the moment';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ToolTip = 'Defines to which store is assigned a POS unit';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"NPR POS Store List", TempPOSStores_) = Action::LookupOK then begin
                            Rec."POS Store Code" := TempPOSStores_.Code;
                        end;
                    end;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Dimension value of Global dimension 1 assigned to POS Unit';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ToolTip = 'Dimension value of Global dimension 2 assigned to POS Unit';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("POS Sales Workflow Set"; Rec."POS Sales Workflow Set")
                {
                    ToolTip = 'Defines Scenarios Profile attached to Unit. Depending on scenario profile will initiate defined actions in POS';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("POS Type"; Rec."POS Type")
                {
                    ToolTip = 'Specifies POS Type: 1. Full/Fixed normal cash register, 2. Unattended used for Self-service, 3. mPOS, 4. External';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin"; Rec."Default POS Payment Bin")
                {
                    ShowMandatory = true;
                    ToolTip = 'Defines Payment Bin attached to POS Unit';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Page.RunModal(Page::"NPR POS Payment Bins", TempPOSPaymentBin_) = Action::LookupOK then begin
                            Rec."Default POS Payment Bin" := TempPOSPaymentBin_."No.";
                        end;
                    end;
                }
                field("POS Audit Profile"; Rec."POS Audit Profile")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS Audit Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS View Profile"; Rec."POS View Profile")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS View Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("POS End of Day Profile"; Rec."POS End of Day Profile")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the POS End of Day Profile field.';
                    ApplicationArea = NPRRetail;
                }
                field("Ean Box Sales Setup"; Rec."Ean Box Sales Setup")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Ean Box Setup that will be used on Sales screen.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    var
        TempPOSStores_: Record "NPR POS Store" temporary;
        TempPOSPaymentBin_: Record "NPR POS Payment Bin" temporary;

    internal procedure CopyAllPOSStores(var TempPOSStores: Record "NPR POS Store")
    begin
        If TempPOSStores.FindSet() then
            repeat
                TempPOSStores_ := TempPOSStores;
                if TempPOSStores_.Insert() then;
            until TempPOSStores.Next() = 0;
    end;

    internal procedure CopyTemp(var TempPOSUnit: Record "NPR POS Unit")
    begin
        if TempPOSUnit.FindSet() then
            repeat
                Rec := TempPOSUnit;
                if Rec.Insert() then;
            until TempPOSUnit.Next() = 0;
    end;

    internal procedure CreatePOSUnitData()
    var
        POSUnit: Record "NPR POS Unit";
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        if Rec.FindSet() then
            repeat
                POSUnit := Rec;
                if not POSUnit.Insert() then
                    POSUnit.Modify();

                CreatePOSPaymentBin(POSPaymentBin, Rec);
            until Rec.Next() = 0;
    end;

    internal procedure CopyTempPOSPaymentBin(var POSPaymentBin: Record "NPR POS Payment Bin")
    begin
        if POSPaymentBin.FindSet() then
            repeat
                TempPOSPaymentBin_ := POSPaymentBin;
                if not TempPOSPaymentBin_.Insert() then
                    TempPOSPaymentBin_.Modify();

            until POSPaymentBin.Next() = 0;
    end;

    local procedure CreatePOSPaymentBin(var POSPaymentBin: Record "NPR POS Payment Bin"; POSUnit: Record "NPR POS Unit")
    var
        DescriptionLbl: Label 'Cash Drawer %1';
    begin
        POSPaymentBin.Init();
        POSPaymentBin."No." := POSUnit."No.";
        POSPaymentBin.Description := StrSubstNo(DescriptionLbl, POSUnit."No.");
        POSPaymentBin."POS Store Code" := POSUnit."POS Store Code";
        POSPaymentBin."Attached to POS Unit No." := POSUnit."No.";
        POSPaymentBin."Eject Method" := 'PRINTER';
        POSPaymentBin."Bin Type" := POSPaymentBin."Bin Type"::CASH_DRAWER;
        POSPaymentBin.Status := POSPaymentBin.Status::CLOSED;
        if not POSPaymentBin.Insert() then
            POSPaymentBin.Modify();
    end;
}
