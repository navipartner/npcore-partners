pageextension 6014429 "NPR Countries/Regions" extends "Countries/Regions"
{
    layout
    {
        addafter("ISO Numeric Code")
        {
            field("NPR HL Country ID"; HeyLoyaltyCountryID)
            {
                Caption = 'HeyLoyalty Country ID';
                ToolTip = 'Specifies the id used for the country at HeyLoyalty.';
                ApplicationArea = NPRHeyLoyalty;

                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    HLMappedValueMgt.SetMappedValue(Rec.RecordId(), Rec.FieldNo(Code), HeyLoyaltyCountryID, true);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        HeyLoyaltyCountryID := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), Rec.FieldNo(Code), false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        HeyLoyaltyCountryID := '';
    end;

    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        HeyLoyaltyCountryID: Text[100];
}