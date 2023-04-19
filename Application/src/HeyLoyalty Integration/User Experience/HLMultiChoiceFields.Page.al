page 6150830 "NPR HL MultiChoice Fields"
{
    Extensible = false;
    Caption = 'HL MultiChoice Fields';
    PageType = List;
    SourceTable = "NPR HL MultiChoice Field";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies a code to identify this HeyLoyalty multiple choice field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies an explanation of the HeyLoyalty multiple choice field.';
                }
                field("Magento Fields Name"; Rec."Magento Field Name")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the id used for the field at Magento.';
                }
                field("HeyLoyalty Field Name"; HeyLoyaltyName)
                {
                    Caption = 'HeyLoyalty Field Name';
                    ToolTip = 'Specifies the id used for the field at HeyLoyalty.';
                    ApplicationArea = NPRHeyLoyalty;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                        HLMappedValueMgt.SetMappedValue(Rec.RecordId(), Rec.FieldNo(Description), HeyLoyaltyName, true);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Options)
            {
                Caption = 'Options';
                ToolTip = 'Define option values for current HeyLoyalty multiple choice field.';
                ApplicationArea = NPRHeyLoyalty;
                Image = SelectMore;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR HL MultiChoice Fld Options";
                RunPageLink = "Field Code" = field(Code);
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        HeyLoyaltyName := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), Rec.FieldNo(Description), false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        HeyLoyaltyName := '';
    end;

    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        HeyLoyaltyName: Text[100];
}
