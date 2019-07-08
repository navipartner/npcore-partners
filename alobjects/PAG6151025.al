page 6151025 "NpRv Ext. Voucher Sales Lines"
{
    // NPR5.48/MHA /20180921  CASE 302179 Object created

    Caption = 'External Retail Voucher Sales Lines';
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Ext. Voucher Sales Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Document No.";"External Document No.")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Document Line No.";"Document Line No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Voucher Type";"Voucher Type")
                {
                }
                field("Voucher No.";"Voucher No.")
                {
                }
                field("Reference No.";"Reference No.")
                {
                }
                field(Description;Description)
                {
                }
            }
        }
    }

    actions
    {
    }
}

