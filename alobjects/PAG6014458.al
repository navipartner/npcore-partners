page 6014458 "Alternative Number"
{
    // NPR5.29/MMV /20161216 CASE 241549 Removed deprecated print/report code.

    Caption = 'Alt. Item No.';
    DelayedInsert = true;
    Editable = true;
    PageType = List;
    SourceTable = "Alternative No.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Editable = FieldCodeed;
                    Visible = FieldCode;
                }
                field("Alt. No."; "Alt. No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Editable = fieldvarianted;
                    Visible = FieldVariant;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Created the"; "Created the")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Variant Code" := GetFilter("Variant Code");
    end;

    trigger OnOpenPage()
    begin
        setTypeView;
        if Type = Type::Item then
            FieldVariant := true
        else
            FieldVariant := false;
    end;

    var
        RetailFormCode: Codeunit "Retail Form Code";
        item: Record Item;
        [InDataSet]
        FieldCode: Boolean;
        [InDataSet]
        FieldVariant: Boolean;
        [InDataSet]
        FieldCodeEd: Boolean;
        [InDataSet]
        FieldVariantEd: Boolean;
        [InDataSet]
        FieldAlt: Boolean;

    procedure setTypeView()
    begin

        //CurrForm.Code.VISIBLE(FALSE);
        FieldCode := false;

        case Type of
            Type::Item:
                begin
                    if GetFilter("Variant Code") <> '' then begin
                        //CurrForm."Alt. No.".ACTIVATE;
                        //CurrForm.Code.EDITABLE(FALSE);
                        // CurrForm."Variant Code".EDITABLE(FALSE);
                        FieldAlt := true;
                        FieldCodeEd := false;
                        FieldVariantEd := false;
                        FieldVariant := true;
                    end;
                end;
            Type::Customer:
                begin
                    //CurrForm."Variant Code".VISIBLE(FALSE);
                    FieldVariant := false;
                end;
            Type::"CRM Customer":
                begin
                    //CurrForm."Variant Code".VISIBLE(FALSE);
                    FieldVariant := false;
                end;
            Type::Register:
                begin
                    //CurrForm."Variant Code".VISIBLE(FALSE);
                    FieldVariant := false;
                end;
            Type::SalesPerson:
                begin
                    // CurrForm."Variant Code".VISIBLE(FALSE);
                    FieldVariant := false;
                end;
        end;
        CurrPage.Update(false);
    end;
}

