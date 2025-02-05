page 6184745 "NPR DE POS Unit Step"
{
    Caption = 'DE POS Unit Profile Setup';
    Extensible = false;
    ObsoleteReason = 'Introduced page NPR DE TSS Clients Step instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-02-09';
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
                ApplicationArea = NPRDEFiscal;
                Caption = 'Create Fiskaly Client';
                Image = InsertFromCheckJournal;
                ToolTip = 'Creates Client ID on Fiskaly for DE fiscalization.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    CurrPage.SaveRecord();
                    DEFiskalyCommunication.CreateClient(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnDeleteRecord(): Boolean
    begin
        if not DETSSClient.Get(Rec."POS Unit No.") then
            exit;
        DETSSClient.Delete();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if not DETSSClient.Get(Rec."POS Unit No.") then
            exit;
        DETSSClient.TransferFields(Rec);
        DETSSClient.Modify();
    end;

    internal procedure CopyRealToTemp()
    begin
        if not DETSSClient.FindSet() then
            exit;
        repeat
            Rec.TransferFields(DETSSClient);
            if not Rec.Insert() then
                Rec.Modify();
        until DETSSClient.Next() = 0;
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
            DETSSClient.TransferFields(Rec);
            if not DETSSClient.Insert() then
                DETSSClient.Modify();
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
        DETSSClient: Record "NPR DE POS Unit Aux. Info";
}