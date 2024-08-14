page 6151399 "NPR RS POS Unit Step"
{
    Extensible = False;
    Caption = 'RS POS Unit Setup';
    PageType = ListPart;
    SourceTable = "NPR RS POS Unit Mapping";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(POSUnitMappingLines)
            {
                field("POS Unit Code"; Rec."POS Unit Code")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the POS Unit Code field.';
                    trigger OnValidate()
                    begin
                        Rec.CalcFields("POS Unit Name");
                    end;
                }
                field("POS Unit Name"; Rec."POS Unit Name")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the POS Unit Code field.';
                }
                field("RS Sandbox JID"; Rec."RS Sandbox JID")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Sandbox JID field.';
                }
                field("RS Sandbox PIN"; Rec."RS Sandbox PIN")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Sandbox PIN field.';
                }
                field("RS Sandbox Token"; Rec."RS Sandbox Token")
                {
                    ApplicationArea = NPRRSFiscal;
                    ToolTip = 'Specifies the value of the Sandbox Token field.';
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
                ApplicationArea = NPRRSFiscal;
                Caption = 'Init POS Units';
                Image = Start;
                ToolTip = 'Initialize POS Unit Mapping with non existing POS Units';
                trigger OnAction()
                var
                    POSUnit: Record "NPR POS Unit";
                    RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
                begin
                    if POSUnit.IsEmpty() then
                        exit;
                    POSUnit.FindSet();
                    repeat
                        if not RSPOSUnitMapping.Get(POSUnit."No.") then begin
                            RSPOSUnitMapping.Init();
                            RSPOSUnitMapping."POS Unit Code" := POSUnit."No.";
                            RSPOSUnitMapping.Insert();
                        end;
                    until POSUnit.Next() = 0;
                end;
            }
            action(VerifyPIN)
            {
                ApplicationArea = NPRRSFiscal;
                Caption = 'RS Fiscal Verify PIN';
                Image = Administration;
                ToolTip = 'Executes the RS Fiscal Verify PIN action.';
                trigger OnAction()
                var
                    RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
                begin
                    Message(RSTaxCommunicationMgt.VerifyPIN(Rec."POS Unit Code"));
                end;
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        InsertOrModifyNonTemp();
    end;

    internal procedure CopyRealToTemp()
    begin
        if not RSPOSUnitMapping.FindSet() then
            exit;
        repeat
            Rec.TransferFields(RSPOSUnitMapping);
            if not Rec.Insert() then
                Rec.Modify();
        until RSPOSUnitMapping.Next() = 0;
    end;

    internal procedure RSPOSUnitMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePOSUnitMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            RSPOSUnitMapping."POS Unit Code" := Rec."POS Unit Code";
            RSPOSUnitMapping."POS Unit Name" := Rec."POS Unit Name";
            RSPOSUnitMapping."RS Sandbox JID" := Rec."RS Sandbox JID";
            RSPOSUnitMapping."RS Sandbox PIN" := Rec."RS Sandbox PIN";
            RSPOSUnitMapping."RS Sandbox Token" := Rec."RS Sandbox Token";
            if not RSPOSUnitMapping.Insert() then
                RSPOSUnitMapping.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    var
        RSFiscalizationSetup: Record "NPR RS Fiscalisation Setup";
    begin
        if not Rec.FindSet() then
            exit(false);
        repeat
            if RSPOSUnitMapping.Get(Rec."POS Unit Code") then
                if (RSPOSUnitMapping."RS Sandbox JID" <> '') and (RSPOSUnitMapping."RS Sandbox PIN" <> 0) then begin
                    RSFiscalizationSetup.Get();
                    if RSFiscalizationSetup."Exclude Token from URL" then
                        exit(true);
                    if (Format(RSPOSUnitMapping."RS Sandbox Token") <> '') then
                        exit(true);
                end;
            exit(true);
        until Rec.Next() = 0;
    end;

    local procedure InsertOrModifyNonTemp()
    begin
        if not RSPOSUnitMapping.Get(Rec."POS Unit Code") then
            RSPOSUnitMapping.Init();
        RSPOSUnitMapping."POS Unit Code" := Rec."POS Unit Code";
        RSPOSUnitMapping."POS Unit Name" := Rec."POS Unit Name";
        RSPOSUnitMapping."RS Sandbox PIN" := Rec."RS Sandbox PIN";
        RSPOSUnitMapping."RS Sandbox JID" := Rec."RS Sandbox JID";
        RSPOSUnitMapping."RS Sandbox Token" := Rec."RS Sandbox Token";
        if not RSPOSUnitMapping.Insert() then
            RSPOSUnitMapping.Modify();
    end;

    var
        RSPOSUnitMapping: Record "NPR RS POS Unit Mapping";
}