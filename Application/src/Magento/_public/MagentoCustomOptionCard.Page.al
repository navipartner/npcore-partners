page 6151425 "NPR Magento Custom Option Card"
{
    Caption = 'Custom Option Card';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Magento Custom Option";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRMagento;

                    trigger OnAssistEdit()
                    begin
                        NoAssistEdit();
                    end;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMagento;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRMagento;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Required; Rec.Required)
                {

                    ToolTip = 'Specifies the value of the Required field';
                    ApplicationArea = NPRMagento;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRMagento;
                }
                field("Max Length"; Rec."Max Length")
                {

                    Editable = MaxLengthEditable;
                    ToolTip = 'Specifies the value of the Max Length field';
                    ApplicationArea = NPRMagento;
                }
                field(Price; Rec.Price)
                {

                    Caption = 'Price';
                    Editable = PriceEditable;
                    ToolTip = 'Specifies the value of the Price field';
                    ApplicationArea = NPRMagento;
                }
                field("Price Type"; Rec."Price Type")
                {

                    Editable = PriceTypeEditable;
                    ToolTip = 'Specifies the value of the Price Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Sales Type"; Rec."Sales Type")
                {

                    Editable = SalesTypeEditable;
                    ToolTip = 'Specifies the value of the Sales Type field';
                    ApplicationArea = NPRMagento;
                }
                field("Sales No."; Rec."Sales No.")
                {

                    Editable = SalesNoEditable;
                    ToolTip = 'Specifies the value of the Sales No. field';
                    ApplicationArea = NPRMagento;
                }
                field("Item Count"; Rec."Item Count")
                {

                    ToolTip = 'Specifies the value of the Item Count field';
                    ApplicationArea = NPRMagento;
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {

                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                    ApplicationArea = NPRMagento;
                }
            }
            part(Control6150628; "NPR Magento Custom Opt.Subform")
            {
                ShowFilter = false;
                SubPageLink = "Custom Option No." = FIELD("No.");
                Visible = CustomOptionValuesVisible;
                ApplicationArea = NPRMagento;

            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetEditable();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetEditable();
    end;

    var
        PriceEditable: Boolean;
        PriceTypeEditable: Boolean;
        SalesTypeEditable: Boolean;
        SalesNoEditable: Boolean;
        MaxLengthEditable: Boolean;
        CustomOptionValuesVisible: Boolean;

    local procedure NoAssistEdit(): Boolean
    var
        MagentoCustomOption: Record "NPR Magento Custom Option";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        MagentoCustomOption.Copy(Rec);
        MagentoCustomOption.InitNoSeries();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        if NoSeriesMgt.LookupRelatedNoSeries(MagentoCustomOption."No. Series", xRec."No. Series", MagentoCustomOption."No. Series") then
#ELSE
        if NoSeriesMgt.SelectSeries(MagentoCustomOption."No. Series", xRec."No. Series", MagentoCustomOption."No. Series") then
#ENDIF
            Rec := MagentoCustomOption;
    end;

    local procedure SetEditable()
    begin
        PriceEditable := (Rec.Type in [Rec.Type::TextField, Rec.Type::TextArea, Rec.Type::File, Rec.Type::Date, Rec.Type::DateTime, Rec.Type::Time]);
        PriceTypeEditable := (Rec.Type in [Rec.Type::TextField, Rec.Type::TextArea, Rec.Type::File, Rec.Type::Date, Rec.Type::DateTime, Rec.Type::Time]);
        SalesTypeEditable := (Rec.Type in [Rec.Type::TextField, Rec.Type::TextArea, Rec.Type::File, Rec.Type::Date, Rec.Type::DateTime, Rec.Type::Time]);
        SalesNoEditable := (Rec.Type in [Rec.Type::TextField, Rec.Type::TextArea, Rec.Type::File, Rec.Type::Date, Rec.Type::DateTime, Rec.Type::Time]);
        MaxLengthEditable := (Rec.Type in [Rec.Type::TextField, Rec.Type::TextArea]);
        CustomOptionValuesVisible := (Rec.Type in [Rec.Type::SelectDropDown, Rec.Type::SelectRadioButtons, Rec.Type::SelectCheckbox, Rec.Type::SelectMultiple]);
    end;
}
