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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';

                    trigger OnAssistEdit()
                    begin
                        NoAssistEdit();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Required; Rec.Required)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Required field';
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position field';
                }
                field("Max Length"; Rec."Max Length")
                {
                    ApplicationArea = All;
                    Editable = MaxLengthEditable;
                    ToolTip = 'Specifies the value of the Max Length field';
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                    Caption = 'Price';
                    Editable = PriceEditable;
                    ToolTip = 'Specifies the value of the Price field';
                }
                field("Price Type"; Rec."Price Type")
                {
                    ApplicationArea = All;
                    Editable = PriceTypeEditable;
                    ToolTip = 'Specifies the value of the Price Type field';
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ApplicationArea = All;
                    Editable = SalesTypeEditable;
                    ToolTip = 'Specifies the value of the Sales Type field';
                }
                field("Sales No."; Rec."Sales No.")
                {
                    ApplicationArea = All;
                    Editable = SalesNoEditable;
                    ToolTip = 'Specifies the value of the Sales No. field';
                }
                field("Item Count"; Rec."Item Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Count field';
                }
                field("Price Includes VAT"; Rec."Price Includes VAT")
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