page 6151127 "NpIa Item AddOn Subform"
{
    // NPR5.44/MHA /20180629  CASE 286547 Object created - Item AddOn
    // NPR5.48/MHA /20181109  CASE 334922 Extended type with Quantity and Selection
    // NPR5.52/ALPO/20190912  CASE 354309 Possibility to fix the quantity so user would not be able to change it on sale line
    //                                    Set whether or not specified quantity is per unit of main item
    //                                    (new controls: Quantity, "Fixed Quantity", "Per Unit")
    // NPR5.55/ALPO/20200506  CASE 402585 Define whether "Unit Price" should always be applied or only when it is not equal 0

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpIa Item AddOn Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("Item No.";"Item No.")
                {
                    Enabled = (Type = 0);
                }
                field("Variant Code";"Variant Code")
                {
                    Enabled = (Type = 0);
                }
                field(Description;Description)
                {
                }
                field("Description 2";"Description 2")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Per Unit";"Per Unit")
                {
                }
                field("Fixed Quantity";"Fixed Quantity")
                {
                }
                field("Unit Price";"Unit Price")
                {
                }
                field("Use Unit Price";"Use Unit Price")
                {
                }
                field("Discount %";"Discount %")
                {
                }
                field("Comment Enabled";"Comment Enabled")
                {
                }
                field("Before Insert Function";"Before Insert Function")
                {

                    trigger OnValidate()
                    begin
                        //-NPR5.48 [334922]
                        CurrPage.Update(true);
                        //+NPR5.48 [334922]
                    end;
                }
                field("Before Insert Codeunit ID";"Before Insert Codeunit ID")
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        //-NPR5.48 [334922]
                        CurrPage.Update(true);
                        //+NPR5.48 [334922]
                    end;
                }
                field("Before Insert Codeunit Name";"Before Insert Codeunit Name")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Select Options")
            {
                Caption = 'Select Options';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NpIa Item AddOn Line Options";
                RunPageLink = "AddOn No."=FIELD("AddOn No."),
                              "AddOn Line No."=FIELD("Line No.");
                ShortCutKey = 'Ctrl+F7';
                Visible = (Type = 1);
            }
            action("Before Insert Setup")
            {
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasBeforeInsertSetup;

                trigger OnAction()
                var
                    NpIaItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
                    Handled: Boolean;
                begin
                    //-NPR5.48 [334922]
                    NpIaItemAddOnMgt.RunBeforeInsertSetup(Rec,Handled);
                    //+NPR5.48 [334922]
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NPR5.48 [334922]
        SetHasBeforeInsertSetup();
        //+NPR5.48 [334922]
    end;

    var
        HasBeforeInsertSetup: Boolean;

    local procedure SetHasBeforeInsertSetup()
    var
        NpIaItemAddOnMgt: Codeunit "NpIa Item AddOn Mgt.";
    begin
        //-NPR5.48 [334922]
        HasBeforeInsertSetup := false;
        NpIaItemAddOnMgt.HasBeforeInsertSetup(Rec,HasBeforeInsertSetup);
        //+NPR5.48 [334922]
    end;
}

