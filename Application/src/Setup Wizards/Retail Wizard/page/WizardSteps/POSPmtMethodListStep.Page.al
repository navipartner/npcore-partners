page 6014687 "NPR POS Pmt. Method List Step"
{
    Caption = 'POS Payment Methods';
    DelayedInsert = true;
    Extensible = False;
    PageType = ListPart;
    SourceTable = "NPR POS Payment Method";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Processing Type"; Rec."Processing Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Currency Code2"; Rec."Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Fixed Rate"; Rec."Fixed Rate")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'You can specify the Fixed Rate which will be used to convert 100 units of foreign currency into local currency. For example 1 FCY = 6.15 LCY , hence the value to be inserted = 100 x 6.15 = 615 instead of 6.15.';
                }
                field("Vouched By"; Rec."Vouched By")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Vouched By field';
                }
                field("Include In Counting"; Rec."Include In Counting")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Include In Counting field';
                }
                field("Bin for Virtual-Count"; Rec."Bin for Virtual-Count")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Bin for Virtual-Count field';
                }
                field("Post Condensed"; Rec."Post Condensed")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Post Condensed field';
                }
                field("Condensed Posting Description"; Rec."Condensed Posting Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Condensed Posting Description field';
                }
                field("Rounding Precision"; Rec."Rounding Precision")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Rounding Precision field';
                }
                field("Rounding Type"; Rec."Rounding Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Rounding Type field';
                }
                field("Rounding Gains Account"; Rec."Rounding Gains Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Rounding Gains Account field';
                }
                field("Rounding Losses Account"; Rec."Rounding Losses Account")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Rounding Losses Account field';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Denominations)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Denominations';
                Image = Currency;
                RunObject = Page "NPR Payment Method Denom";
                RunPageLink = "POS Payment Method Code" = field(Code);
                ShortCutKey = 'Ctrl+F5';
                ToolTip = 'Executes the Denominations action';

                trigger OnAction()
                begin
                    DenominationSetupOpened := true;
                end;
            }
            action(EFTSetup)
            {
                ApplicationArea = NPRRetail;
                Caption = 'EFT Setup';
                Image = SetupLines;
                ToolTip = 'Executes the EFT Setup action.';

                trigger OnAction()
                var
                    EFTSetup: Record "NPR EFT Setup";
                    EFTSetupPage: Page "NPR EFT Setup";
                begin
                    EFTSetupOpened := true;
                    EFTSetup.SetRange("Payment Type POS", Rec.Code);

                    EFTSetupPage.SetRecord(EFTSetup);
                    EFTSetupPage.SetTableView(EFTSetup);

                    EFTSetupPage.RunModal();
                end;
            }
        }
    }

    var
        EFTSetupOpened: Boolean;
        DenominationSetupOpened: Boolean;

    internal procedure CopyRealAndTemp(var TempPOSPaymentMethod: Record "NPR POS Payment Method")
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

    [Obsolete('Please use procedure POSPaymentMethodsToModify()', 'NPR23.0')]
    internal procedure POSPaymentMethodsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure POSPaymentMethodsToModify(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    [Obsolete('Please use procedure ModifyPOSPaymentMethodData()', 'NPR23.0')]
    internal procedure CreatePOSPaymentMethodData()
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

    internal procedure ModifyPOSPaymentMethodData()
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

    internal procedure EFTSetupVisited(): Boolean
    begin
        exit(EFTSetupOpened);
    end;

    internal procedure DenominationSetupVisited(): Boolean
    begin
        exit(DenominationSetupOpened);
    end;
}