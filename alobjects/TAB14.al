tableextension 6014418 tableextension6014418 extends Location 
{
    // NPR4.16/TJ/20151103 CASE 222281 Added new field Store Group Code
    fields
    {
        field(6014473;"Store Group Code";Code[20])
        {
            Caption = 'Store Group Code';
            Description = '#222281';
            TableRelation = "Store Group";
        }
    }
}

