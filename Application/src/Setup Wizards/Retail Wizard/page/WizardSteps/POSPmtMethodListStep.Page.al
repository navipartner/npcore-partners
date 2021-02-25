page 6014687 "NPR POS Pmt. Method List Step"
{
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Processing Type"; Rec."Processing Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Currency Code2"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Vouched By"; Rec."Vouched By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vouched By field';
                }
                field("Include In Counting"; Rec."Include In Counting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include In Counting field';
                }
                field("Bin for Virtual-Count"; Rec."Bin for Virtual-Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bin for Virtual-Count field';
                }
                field("Post Condensed"; Rec."Post Condensed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Condensed field';
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Condensed Posting Description field';
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Precision field';
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Type field';
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
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