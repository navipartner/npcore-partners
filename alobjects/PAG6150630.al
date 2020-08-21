page 6150630 "POS Tax Checkpoint"
{
    // NPR5.48/TSA /20180228 CASE 282251 Initial Version
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object
    // NPR5.55/TSA /20200511 CASE 400098 Added "Tax Jurisdiction Code", "Tax Group Code"

    Caption = 'POS Tax Checkpoint';
    Editable = false;
    PageType = Card;
    SourceTable = "POS Workshift Tax Checkpoint";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                }
                field("Tax Jurisdiction Code"; "Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                }
                field("VAT Identifier"; "VAT Identifier")
                {
                    ApplicationArea = All;
                }
                field("Tax Calculation Type"; "Tax Calculation Type")
                {
                    ApplicationArea = All;
                }
                field("Tax Type"; "Tax Type")
                {
                    ApplicationArea = All;
                }
                field("Tax %"; "Tax %")
                {
                    ApplicationArea = All;
                }
                field("Tax Base Amount"; "Tax Base Amount")
                {
                    ApplicationArea = All;
                }
                field("Tax Amount"; "Tax Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount Including Tax"; "Amount Including Tax")
                {
                    ApplicationArea = All;
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Workshift Checkpoint Entry No."; "Workshift Checkpoint Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

