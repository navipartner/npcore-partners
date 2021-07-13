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
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        NoAssistEdit();
                    end;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Required; Rec.Required)
                {

                    ToolTip = 'Specifies the value of the Required field';
                    ApplicationArea = NPRRetail;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRRetail;
                }
                field("Max Length"; Rec."Max Length")
                {

                    Editable = MaxLengthEditable;
                    ToolTip = 'Specifies the value of the Max Length field';
                    ApplicationArea = NPRRetail;
                }
                field(Price; Rec.Price)
                {

                    Caption = 'Price';
                    Editable = PriceEditable;
                    ToolTip = 'Specifies the value of the Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Price Type"; Rec."Price Type")
                {

                    Editable = PriceTypeEditable;
                    ToolTip = 'Specifies the value of the Price Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Type"; Rec."Sales Type")
                {

                    Editable = SalesTypeEditable;
                    ToolTip = 'Specifies the value of the Sales Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales No."; Rec."Sales No.")
                {

                    Editable = SalesNoEditable;
                    ToolTip = 'Specifies the value of the Sales No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Count"; Rec."Item Count")
                {

                    ToolTip = 'Specifies the value of the Item Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
                {

                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6150628; "NPR Magento Custom Opt.Subform")
            {
                ShowFilter = false;
                SubPageLink = "Custom Option No." = FIELD("No.");
                Visible = CustomOptionValuesVisible;
                ApplicationArea = NPRRetail;

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
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        MagentoCustomOption.Copy(Rec);
        MagentoCustomOption.InitNoSeries();
        if NoSeriesMgt.SelectSeries(MagentoCustomOption."No. Series", xRec."No. Series", MagentoCustomOption."No. Series") then
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