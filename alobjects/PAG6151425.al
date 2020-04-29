page 6151425 "Magento Custom Option Card"
{
    // MAG1.22/TR/20160414  CASE 238563 Magento Custom Options
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.21/BHR/20190508 CASE 338087 Field 100 Price Excl. VAT

    Caption = 'Custom Option Card';
    PageType = Card;
    SourceTable = "Magento Custom Option";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No.";"No.")
                {

                    trigger OnAssistEdit()
                    begin
                        NoAssistEdit();
                    end;
                }
                field(Description;Description)
                {
                }
                field(Type;Type)
                {

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Required;Required)
                {
                }
                field(Position;Position)
                {
                }
                field("Max Length";"Max Length")
                {
                    Editable = MaxLengthEditable;
                }
                field(Price;Price)
                {
                    Caption = 'Price';
                    Editable = PriceEditable;
                }
                field("Price Type";"Price Type")
                {
                    Editable = PriceTypeEditable;
                }
                field("Sales Type";"Sales Type")
                {
                    Editable = SalesTypeEditable;
                }
                field("Sales No.";"Sales No.")
                {
                    Editable = SalesNoEditable;
                }
                field("Item Count";"Item Count")
                {
                }
                field("Price Includes VAT";"Price Includes VAT")
                {
                }
            }
            part(Control6150628;"Magento Custom Option Subform")
            {
                ShowFilter = false;
                SubPageLink = "Custom Option No."=FIELD("No.");
                Visible = CustomOptionValuesVisible;
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
        MagentoCustomOption: Record "Magento Custom Option";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        MagentoCustomOption.Copy(Rec);
        MagentoCustomOption.InitNoSeries();
        if NoSeriesMgt.SelectSeries(MagentoCustomOption."No. Series",xRec."No. Series",MagentoCustomOption."No. Series") then
          Rec := MagentoCustomOption;
    end;

    local procedure SetEditable()
    begin
        PriceEditable := (Type in [Type::TextField,Type::TextArea,Type::File,Type::Date,Type::DateTime,Type::Time]);
        PriceTypeEditable := (Type in [Type::TextField,Type::TextArea,Type::File,Type::Date,Type::DateTime,Type::Time]);
        SalesTypeEditable := (Type in [Type::TextField,Type::TextArea,Type::File,Type::Date,Type::DateTime,Type::Time]);
        SalesNoEditable := (Type in [Type::TextField,Type::TextArea,Type::File,Type::Date,Type::DateTime,Type::Time]);
        MaxLengthEditable := (Type in [Type::TextField,Type::TextArea]);
        CustomOptionValuesVisible := (Type in [Type::SelectDropDown,Type::SelectRadioButtons,Type::SelectCheckbox,Type::SelectMultiple]);
    end;
}

