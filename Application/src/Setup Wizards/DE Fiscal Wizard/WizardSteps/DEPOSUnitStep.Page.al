page 6184745 "NPR DE POS Unit Step"
{
    Caption = 'DE POS Unit Profile Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR DE POS Unit Aux. Info";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }
                field("Cash Register Brand"; Rec."Cash Register Brand")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Cash Register Brand field.';
                }
                field("Cash Register Model"; Rec."Cash Register Model")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Cash Register Model field.';
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the TSS Code field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create Client")
            {
                Caption = 'Create Fiskaly Client';
                Image = InsertFromCheckJournal;
                ToolTip = 'Creates Client ID on Fiskaly for DE fiscalization.';
                ApplicationArea = NPRDEFiscal;

                trigger OnAction()
                var
                    DETSS: Record "NPR DE TSS";
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                    TSSNotSyncedQst: Label 'It looks that assigned TSS hasn''t been created at Fiskaly yet. If you continue, it will be created automatically.\Are you sure you want to continue?';
                begin
                    Rec.TestField("Serial Number");
                    Rec.TestField("TSS Code");
                    DETSS.Get(Rec."TSS Code");
                    if DETSS."Fiskaly TSS Created at" = 0DT then
                        if not Confirm(TSSNotSyncedQst, false) then
                            exit;

                    DEFiskalyCommunication.CreateClient(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnDeleteRecord(): Boolean
    begin
        if not DEPOSUnitMapping.Get(Rec."POS Unit No.") then
            exit;
        DEPOSUnitMapping.Delete();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if not DEPOSUnitMapping.Get(Rec."POS Unit No.") then
            exit;
        DEPOSUnitMapping.TransferFields(Rec);
        DEPOSUnitMapping.Modify();
    end;

    internal procedure CopyRealToTemp()
    begin
        if not DEPOSUnitMapping.FindSet() then
            exit;
        repeat
            Rec.TransferFields(DEPOSUnitMapping);
            if not Rec.Insert() then
                Rec.Modify();
        until DEPOSUnitMapping.Next() = 0;
    end;

    internal procedure DEPOSUnitMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure DEPOSUnitMappingDataToModify(): Boolean
    begin
        exit(CheckIsDataChanged());
    end;

    internal procedure CreatePOSUnitMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            DEPOSUnitMapping.TransferFields(Rec);
            if not DEPOSUnitMapping.Insert() then
                DEPOSUnitMapping.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if ((Rec."POS Unit No." <> '')
                and (Rec."Cash Register Brand" <> '')
                and (Rec."Cash Register Model" <> '')
                and (Rec."TSS Code" <> '')) then
                exit(true);
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataChanged(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);

        repeat
            if ((Rec."POS Unit No." <> xRec."POS Unit No.")
                or (Rec."Cash Register Brand" <> xRec."Cash Register Brand")
                or (Rec."Cash Register Model" <> xRec."Cash Register Model")
                or (Rec."TSS Code" <> xRec."TSS Code")) then
                exit(true);
        until Rec.Next() = 0;
    end;

    var
        DEPOSUnitMapping: Record "NPR DE POS Unit Aux. Info";
}