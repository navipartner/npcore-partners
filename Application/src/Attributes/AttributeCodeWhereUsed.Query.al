query 6014510 "NPR Attribute Code Where-Used"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'Attribute Code Where-Used';

    elements
    {
        dataitem(NPRAttributeValueSet; "NPR Attribute Value Set")
        {
            column(AttributeCode; "Attribute Code") { }
            column(AttributeSetID; "Attribute Set ID") { }
            column(TextValue; "Text Value") { }
            dataitem(NPRAttributeKey; "NPR Attribute Key")
            {
                DataItemLink = "Attribute Set ID" = NPRAttributeValueSet."Attribute Set ID";
                SqlJoinType = InnerJoin;

                column(TableID; "Table ID") { }
                column(MDRCodePK; "MDR Code PK") { }
            }
        }
    }
}