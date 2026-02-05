page 6150831 "NPR HL MultiChoice Fld Options"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = false;
    Caption = 'HL MultiChoice Field Options';
    PageType = List;
    SourceTable = "NPR HL MultiChoice Fld Option";
    SourceTableView = sorting("Field Code", "Sort Order");
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Field Code"; Rec."Field Code")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the code of the HeyLoyalty multiple choice field.';
                    Visible = false;
                }
                field("Option ID"; Rec."Option ID")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies a BC internal identifier of this HeyLoyalty multiple choice field option value.';
                    Visible = false;
                }
                field("Sort Order"; Rec."Sort Order")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the sort order of the option value. The lower the number, the higher in the list the option value will appear.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies an explanation of the HeyLoyalty multiple choice field option value.';
                }
                field("Magento Description"; Rec."Magento Description")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the id used for the field option value at Magento.';
                }
                field("HeyLoyalty Field Name"; HeyLoyaltyName)
                {
                    ApplicationArea = NPRHeyLoyalty;
                    Caption = 'HeyLoyalty Field Name';
                    ToolTip = 'Specifies the id used for the field option value at HeyLoyalty.';

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

    trigger OnAfterGetRecord()
    begin
        HeyLoyaltyName := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), Rec.FieldNo(Description), false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.GetNextSortSequenceNo();
        HeyLoyaltyName := '';
    end;

    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        HeyLoyaltyName: Text[100];
}
