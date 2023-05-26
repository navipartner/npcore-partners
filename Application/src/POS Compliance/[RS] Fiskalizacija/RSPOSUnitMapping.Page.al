page 6150715 "NPR RS POS Unit Mapping"
{
    ApplicationArea = NPRRSFiscal;
    Caption = 'RS POS Unit Mapping';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR RS POS Unit Mapping";
    UsageCategory = Administration;

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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
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
}