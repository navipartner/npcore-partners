page 6151425 "NPR Magento Custom Option Card"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.21/BHR/20190508 CASE 338087 Field 100 Price Excl. VAT

    Caption = 'Custom Option Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Custom Option";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnAssistEdit()
                    begin
                        NoAssistEdit();
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Required; Required)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Required field';
                }
                field(Position; Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
                field("Max Length"; "Max Length")
                {
                    ApplicationArea = All;
                    Editable = MaxLengthEditable;
                    ToolTip = 'Specifies the value of the Max Length field';
                }
                field(Price; Price)
                {
                    ApplicationArea = All;
                    Caption = 'Price';
                    Editable = PriceEditable;
                    ToolTip = 'Specifies the value of the Price field';
                }
                field("Price Type"; "Price Type")
                {
                    ApplicationArea = All;
                    Editable = PriceTypeEditable;
                    ToolTip = 'Specifies the value of the Price Type field';
                }
                field("Sales Type"; "Sales Type")
                {
                    ApplicationArea = All;
                    Editable = SalesTypeEditable;
                    ToolTip = 'Specifies the value of the Sales Type field';
                }
                field("Sales No."; "Sales No.")
                {
                    ApplicationArea = All;
                    Editable = SalesNoEditable;
                    ToolTip = 'Specifies the value of the Sales No. field';
                }
                field("Item Count"; "Item Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Count field';
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price Includes VAT field';
                }
            }
            part(Control6150628; "NPR Magento Custom Opt.Subform")
            {
                ShowFilter = false;
                SubPageLink = "Custom Option No." = FIELD("No.");
                Visible = CustomOptionValuesVisible;
                ApplicationArea = All;
            }
        }
    }

    actions
    {
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
        PriceEditable := (Type in [Type::TextField, Type::TextArea, Type::File, Type::Date, Type::DateTime, Type::Time]);
        PriceTypeEditable := (Type in [Type::TextField, Type::TextArea, Type::File, Type::Date, Type::DateTime, Type::Time]);
        SalesTypeEditable := (Type in [Type::TextField, Type::TextArea, Type::File, Type::Date, Type::DateTime, Type::Time]);
        SalesNoEditable := (Type in [Type::TextField, Type::TextArea, Type::File, Type::Date, Type::DateTime, Type::Time]);
        MaxLengthEditable := (Type in [Type::TextField, Type::TextArea]);
        CustomOptionValuesVisible := (Type in [Type::SelectDropDown, Type::SelectRadioButtons, Type::SelectCheckbox, Type::SelectMultiple]);
    end;
}

