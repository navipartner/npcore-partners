pageextension 6014482 pageextension6014482 extends "Sales Order List" 
{
    // NPR5.36/KENU/20170830 CASE 283379 Added field "Promised Delivery Date"
    // NPR5.36/THRO/20170908 CASE 285645 Added action PostAndSendPdf2Nav
    // NPR5.38/TS  /20171208 CASE 296960 Added Style if Notes is available.
    layout
    {
        modify("No.")
        {
            Style = Attention;
            StyleExpr = HasNotes;
        }
        addafter("Requested Delivery Date")
        {
            field("Promised Delivery Date";"Promised Delivery Date")
            {
            }
        }
    }
    actions
    {
        addafter(Post)
        {
            action(PostAndSendPdf2Nav)
            {
                Caption = 'Post and Pdf2Nav';
                Image = PostSendTo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Post and handle as set up in ''Document Processing''';
            }
        }
    }

    var
        [InDataSet]
        HasNotes: Boolean;


    //Unsupported feature: Code Insertion on "OnAfterGetRecord".

    //trigger OnAfterGetRecord()
    //var
        //RecordLink: Record "Record Link";
        //RecRef: RecordRef;
    //begin
        /*
        //-NPR5.38 [296960]
        HasNotes := false;
        RecRef.GetTable(Rec);
        RecordLink.SetRange("Record ID",RecRef.RecordId);
        if RecordLink.FindFirst then
          if RecordLink.Note.HasValue then
            HasNotes := true;
        //+NPR5.38 [296960]
        */
    //end;
}

