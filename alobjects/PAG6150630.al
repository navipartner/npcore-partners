page 6150630 "POS Tax Checkpoint"
{
    // NPR5.48/TSA /20180228 CASE 282251 Initial Version
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

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
                field("Entry No.";"Entry No.")
                {
                    Visible = false;
                }
                field("Tax Area Code";"Tax Area Code")
                {
                }
                field("VAT Identifier";"VAT Identifier")
                {
                }
                field("Tax Calculation Type";"Tax Calculation Type")
                {
                }
                field("Tax Type";"Tax Type")
                {
                }
                field("Tax %";"Tax %")
                {
                }
                field("Tax Base Amount";"Tax Base Amount")
                {
                }
                field("Tax Amount";"Tax Amount")
                {
                }
                field("Amount Including Tax";"Amount Including Tax")
                {
                }
                field("Line Amount";"Line Amount")
                {
                    Visible = false;
                }
                field("Workshift Checkpoint Entry No.";"Workshift Checkpoint Entry No.")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

