page 6014687 "NPR POS Pmt. Method List Step"
{
    Extensible = False;
    Caption = 'POS Payment Methods';
    PageType = ListPart;
    SourceTable = "NPR POS Payment Method";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {

                    ToolTip = 'Specifies the value of the Processing Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code2"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Vouched By"; Rec."Vouched By")
                {

                    ToolTip = 'Specifies the value of the Vouched By field';
                    ApplicationArea = NPRRetail;
                }
                field("Include In Counting"; Rec."Include In Counting")
                {

                    ToolTip = 'Specifies the value of the Include In Counting field';
                    ApplicationArea = NPRRetail;
                }
                field("Bin for Virtual-Count"; Rec."Bin for Virtual-Count")
                {

                    ToolTip = 'Specifies the value of the Bin for Virtual-Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Condensed"; Rec."Post Condensed")
                {

                    ToolTip = 'Specifies the value of the Post Condensed field';
                    ApplicationArea = NPRRetail;
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {

                    ToolTip = 'Specifies the value of the Condensed Posting Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {

                    ToolTip = 'Specifies the value of the Rounding Precision field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Type"; Rec."Rounding Type")
                {

                    ToolTip = 'Specifies the value of the Rounding Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {

                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {

                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    procedure CopyRealAndTemp(var TempPOSPaymentMethod: Record "NPR POS Payment Method")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        TempPOSPaymentMethod.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempPOSPaymentMethod := Rec;
                TempPOSPaymentMethod.Insert();
            until Rec.Next() = 0;

        if POSPaymentMethod.FindSet() then
            repeat
                TempPOSPaymentMethod := POSPaymentMethod;
                TempPOSPaymentMethod.Insert();
            until POSPaymentMethod.Next() = 0;
    end;

    procedure POSPaymentMethodsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CreatePOSPaymentMethodData()
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin
        if Rec.FindSet() then
            repeat
                POSPaymentMethod := Rec;
                if not POSPaymentMethod.Insert() then
                    POSPaymentMethod.Modify();
            until Rec.Next() = 0;
    end;
}
