page 6014609 "NPR Attribute Value Lookup"
{
    Extensible = False;
    Caption = 'Client Attribute Value Lookup';
    DataCaptionFields = "Attribute Code";
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Attribute Lookup Value";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Code"; Rec."Attribute Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Attribute Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Value Code"; Rec."Attribute Value Code")
                {
                    ToolTip = 'Specifies the value of the Attribute Value Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Value Name"; Rec."Attribute Value Name")
                {
                    ToolTip = 'Specifies the value of the Attribute Value Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Value Description"; Rec."Attribute Value Description")
                {
                    ToolTip = 'Specifies the value of the Attribute Value Description field';
                    ApplicationArea = NPRRetail;
                }
                field("HeyLoyalty Name"; HeyLoyaltyName)
                {
                    Caption = 'HeyLoyalty Name';
                    ToolTip = 'Specifies the id used for the attribute value at HeyLoyalty.';
                    ApplicationArea = NPRHeyLoyalty;

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                        HLMappedValueMgt.SetMappedValue(Rec.RecordId(), Rec.FieldNo("Attribute Value Name"), HeyLoyaltyName, true);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        HeyLoyaltyName := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), Rec.FieldNo("Attribute Value Name"), false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        HeyLoyaltyName := '';
    end;

    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        HeyLoyaltyName: Text[100];
}
