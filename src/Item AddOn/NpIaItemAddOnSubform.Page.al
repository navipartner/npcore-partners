page 6151127 "NPR NpIa Item AddOn Subform"
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
    SourceTable = "NPR NpIa Item AddOn Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    Enabled = (Type = 0);
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Enabled = (Type = 0);
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Per Unit"; "Per Unit")
                {
                    ApplicationArea = All;
                }
                field("Fixed Quantity"; "Fixed Quantity")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Use Unit Price"; "Use Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Discount %"; "Discount %")
                {
                    ApplicationArea = All;
                }
                field("Comment Enabled"; "Comment Enabled")
                {
                    ApplicationArea = All;
                }
                field("Before Insert Function"; "Before Insert Function")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-NPR5.48 [334922]
                        CurrPage.Update(true);
                        //+NPR5.48 [334922]
                    end;
                }
                field("Before Insert Codeunit ID"; "Before Insert Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        //-NPR5.48 [334922]
                        CurrPage.Update(true);
                        //+NPR5.48 [334922]
                    end;
                }
                field("Before Insert Codeunit Name"; "Before Insert Codeunit Name")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR NpIa ItemAddOn Line Opt.";
                RunPageLink = "AddOn No." = FIELD("AddOn No."),
                              "AddOn Line No." = FIELD("Line No.");
                ShortCutKey = 'Ctrl+F7';
                Visible = (Type = 1);
                ApplicationArea=All;
            }
            action("Before Insert Setup")
            {
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = HasBeforeInsertSetup;
                ApplicationArea=All;

                trigger OnAction()
                var
                    NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
                    Handled: Boolean;
                begin
                    //-NPR5.48 [334922]
                    NpIaItemAddOnMgt.RunBeforeInsertSetup(Rec, Handled);
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
        NpIaItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        //-NPR5.48 [334922]
        HasBeforeInsertSetup := false;
        NpIaItemAddOnMgt.HasBeforeInsertSetup(Rec, HasBeforeInsertSetup);
        //+NPR5.48 [334922]
    end;
}

