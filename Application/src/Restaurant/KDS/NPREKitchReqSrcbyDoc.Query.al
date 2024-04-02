query 6014473 "NPR NPRE Kitch.Req.Src. by Doc"
{
    Access = Internal;
    Caption = 'Kitchen Request Source by Doc.';
    ReadState = ReadUncommitted;

    elements
    {
        dataitem(KitchenReqSourceLink; "NPR NPRE Kitchen Req.Src. Link")
        {
            column(Request_No_; "Request No.") { }
            column(Source_Document_Type; "Source Document Type") { }
            column(Source_Document_Subtype; "Source Document Subtype") { }
            column(Source_Document_No_; "Source Document No.") { }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            column(QuantityBase; "Quantity (Base)")
            {
                Method = Sum;
            }
        }
    }
}
