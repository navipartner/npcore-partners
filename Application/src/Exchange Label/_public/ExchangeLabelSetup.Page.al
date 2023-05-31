page 6014419 "NPR Exchange Label Setup"
{
    Extensible = true;
    Caption = 'Exchange Label Setup';
    PageType = Card;
    SourceTable = "NPR Exchange Label Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("EAN Prefix Exhange Label"; Rec."EAN Prefix Exhange Label")
                {

                    ToolTip = 'Specifies the prefix used in the EAN code for exchange labels.';
                    ApplicationArea = NPRRetail;
                }
                field("Exchange Label  No. Series"; Rec."Exchange Label  No. Series")
                {

                    ToolTip = 'Specifies which number series is used for exchange label entries.';
                    ApplicationArea = NPRRetail;
                }
                field("Purchace Price Code"; Rec."Purchace Price Code")
                {

                    ToolTip = 'Specifies the alphabetical code used to substitute numbers when displaying prices on the exchange label. A unique letter is chosen for each number from 0-9.';
                    ApplicationArea = NPRRetail;
                }
                field("Exchange Label Exchange Period"; Rec."Exchange Label Exchange Period")
                {

                    ToolTip = 'Specifies the period length that the exchange labels should be valid for.';
                    ApplicationArea = NPRRetail;
                }
                field("Exchange Label Default Date"; Rec."Exchange Label Default Date")
                {

                    ToolTip = 'Specifies a date to use as the default "valid from"-date. Leave blank to use the date of creation (ie. "today''s date").';
                    ApplicationArea = NPRRetail;
                }
                field("Insert Cross Ref. Finish Sale"; Rec."Insert Cross Ref. Finish Sale")
                {

                    ToolTip = 'Specifies if Cross Reference is inserted after finishing the sale';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
