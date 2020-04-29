page 6150904 "HC Payment Types"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object
    // NPR5.38/BR  /20171128 CASE 297946 Added field 600 HQ Processing

    Caption = 'HC Payment Types';
    PageType = List;
    SourceTable = "HC Payment Type POS";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Account Type";"Account Type")
                {
                }
                field("G/L Account No.";"G/L Account No.")
                {
                }
                field("Bank Acc. No.";"Bank Acc. No.")
                {
                }
                field("HQ Processing";"HQ Processing")
                {
                }
                field("HQ Post Sales Document";"HQ Post Sales Document")
                {
                }
                field("HQ Post Payment";"HQ Post Payment")
                {
                }
                field("Payment Method Code";"Payment Method Code")
                {
                }
            }
        }
    }

    actions
    {
    }
}

